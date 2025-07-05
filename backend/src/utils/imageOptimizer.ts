import sharp from 'sharp';
import crypto from 'crypto';
import fs from 'fs/promises';
import path from 'path';

// Configuration for image optimization
const OPTIMIZATION_CONFIG = {
  // Perceptual hash configuration
  HASH_SIZE: 8, // 8x8 grid for perceptual hash
  SIMILARITY_THRESHOLD: 0.85, // 85% similarity threshold
  
  // Image quality settings
  MAX_DIMENSIONS: { width: 1024, height: 1024 },
  QUALITY_LEVELS: {
    HIGH: { quality: 85, size: 'large' },
    MEDIUM: { quality: 75, size: 'medium' },
    LOW: { quality: 65, size: 'small' },
  },
  
  // Adaptive quality thresholds
  CONTENT_THRESHOLDS: {
    TEXT_HEAVY: 0.3, // More text = higher quality needed
    DETAIL_HEAVY: 0.4, // More details = higher quality needed
    SIMPLE: 0.6, // Simple content = lower quality ok
  },
  
  // Cache settings
  CACHE_TTL: 24 * 60 * 60 * 1000, // 24 hours
  MAX_CACHE_SIZE: 100, // Maximum number of cached hashes
};

interface ImageMetadata {
  width: number;
  height: number;
  channels: number;
  density?: number;
  hasAlpha?: boolean;
  format?: string;
}

interface OptimizationResult {
  buffer: Buffer;
  metadata: ImageMetadata;
  hash: string;
  quality: 'high' | 'medium' | 'low';
  compressionRatio: number;
  tokensEstimate: number;
}

interface CachedImageData {
  hash: string;
  timestamp: number;
  metadata: ImageMetadata;
  originalSize: number;
  optimizedSize: number;
}

// In-memory cache for image hashes and metadata
class ImageCache {
  private cache: Map<string, CachedImageData> = new Map();
  private hashToPath: Map<string, string> = new Map();
  
  set(key: string, data: CachedImageData): void {
    // Remove oldest entries if cache is full
    if (this.cache.size >= OPTIMIZATION_CONFIG.MAX_CACHE_SIZE) {
      const oldestKey = Array.from(this.cache.keys())[0];
      this.cache.delete(oldestKey);
      this.hashToPath.delete(oldestKey);
    }
    
    this.cache.set(key, data);
    this.hashToPath.set(data.hash, key);
  }
  
  get(key: string): CachedImageData | undefined {
    const data = this.cache.get(key);
    if (data && Date.now() - data.timestamp < OPTIMIZATION_CONFIG.CACHE_TTL) {
      return data;
    }
    if (data) {
      this.cache.delete(key);
      this.hashToPath.delete(data.hash);
    }
    return undefined;
  }
  
  findByHash(hash: string): CachedImageData | undefined {
    const key = this.hashToPath.get(hash);
    return key ? this.get(key) : undefined;
  }
  
  clear(): void {
    this.cache.clear();
    this.hashToPath.clear();
  }
  
  size(): number {
    return this.cache.size;
  }
}

const imageCache = new ImageCache();

/**
 * Generate perceptual hash for image comparison
 * Uses average hashing algorithm for fast similarity detection
 */
export async function generatePerceptualHash(imageBuffer: Buffer): Promise<string> {
  try {
    // Convert image to 8x8 grayscale for hashing
    const { data, info } = await sharp(imageBuffer)
      .greyscale()
      .resize(OPTIMIZATION_CONFIG.HASH_SIZE, OPTIMIZATION_CONFIG.HASH_SIZE, {
        fit: 'fill',
        kernel: sharp.kernel.nearest,
      })
      .raw()
      .toBuffer({ resolveWithObject: true });
    
    // Calculate average pixel value
    const pixelSum = Array.from(data).reduce((sum, pixel) => sum + pixel, 0);
    const average = pixelSum / data.length;
    
    // Generate binary hash based on average
    let hash = '';
    for (let i = 0; i < data.length; i++) {
      hash += data[i] >= average ? '1' : '0';
    }
    
    return hash;
  } catch (error) {
    console.error('Error generating perceptual hash:', error);
    throw error;
  }
}

/**
 * Compare two perceptual hashes for similarity
 */
export function compareHashes(hash1: string, hash2: string): number {
  if (hash1.length !== hash2.length) {
    return 0;
  }
  
  let matches = 0;
  for (let i = 0; i < hash1.length; i++) {
    if (hash1[i] === hash2[i]) {
      matches++;
    }
  }
  
  return matches / hash1.length;
}

/**
 * Analyze image content to determine optimal quality settings
 */
async function analyzeImageContent(imageBuffer: Buffer): Promise<{
  complexity: number;
  textLikelihood: number;
  recommendedQuality: 'high' | 'medium' | 'low';
}> {
  try {
    // Get image statistics
    const stats = await sharp(imageBuffer)
      .greyscale()
      .stats();
    
    // Calculate complexity based on standard deviation
    const complexity = stats.channels[0].stdev / 255;
    
    // Estimate text likelihood based on high contrast areas
    const edges = await sharp(imageBuffer)
      .greyscale()
      .convolve({
        width: 3,
        height: 3,
        kernel: [-1, -1, -1, -1, 8, -1, -1, -1, -1],
      })
      .raw()
      .toBuffer();
    
    const edgeStrength = Array.from(edges).reduce((sum, pixel) => sum + pixel, 0) / edges.length;
    const textLikelihood = Math.min(edgeStrength / 100, 1);
    
    // Determine recommended quality
    let recommendedQuality: 'high' | 'medium' | 'low';
    if (textLikelihood > OPTIMIZATION_CONFIG.CONTENT_THRESHOLDS.TEXT_HEAVY) {
      recommendedQuality = 'high';
    } else if (complexity > OPTIMIZATION_CONFIG.CONTENT_THRESHOLDS.DETAIL_HEAVY) {
      recommendedQuality = 'medium';
    } else {
      recommendedQuality = 'low';
    }
    
    return {
      complexity,
      textLikelihood,
      recommendedQuality,
    };
  } catch (error) {
    console.error('Error analyzing image content:', error);
    // Default to medium quality if analysis fails
    return {
      complexity: 0.5,
      textLikelihood: 0.3,
      recommendedQuality: 'medium',
    };
  }
}

/**
 * Optimize image with intelligent quality adjustment
 */
export async function optimizeImage(
  imageBuffer: Buffer,
  options: {
    forceQuality?: 'high' | 'medium' | 'low';
    maxDimensions?: { width: number; height: number };
    targetTokens?: number;
  } = {}
): Promise<OptimizationResult> {
  try {
    const originalSize = imageBuffer.length;
    
    // Get image metadata
    const metadata = await sharp(imageBuffer).metadata();
    
    // Analyze content for optimal quality
    const contentAnalysis = await analyzeImageContent(imageBuffer);
    const targetQuality = options.forceQuality || contentAnalysis.recommendedQuality;
    
    // Determine dimensions
    const maxDim = options.maxDimensions || OPTIMIZATION_CONFIG.MAX_DIMENSIONS;
    const qualitySettings = OPTIMIZATION_CONFIG.QUALITY_LEVELS[targetQuality.toUpperCase() as keyof typeof OPTIMIZATION_CONFIG.QUALITY_LEVELS];
    
    // Apply smart cropping to remove empty space
    const croppedBuffer = await smartCrop(imageBuffer);
    
    // Optimize image
    const optimizedBuffer = await sharp(croppedBuffer)
      .resize(maxDim.width, maxDim.height, {
        fit: 'inside',
        withoutEnlargement: true,
      })
      .jpeg({
        quality: qualitySettings.quality,
        progressive: true,
        mozjpeg: true, // Better compression
      })
      .toBuffer();
    
    // Generate perceptual hash
    const hash = await generatePerceptualHash(optimizedBuffer);
    
    // Calculate metrics
    const compressionRatio = originalSize / optimizedBuffer.length;
    const tokensEstimate = estimateTokenCost(optimizedBuffer, metadata);
    
    return {
      buffer: optimizedBuffer,
      metadata: {
        width: metadata.width || 0,
        height: metadata.height || 0,
        channels: metadata.channels || 3,
        density: metadata.density,
        hasAlpha: metadata.hasAlpha,
        format: metadata.format,
      },
      hash,
      quality: targetQuality,
      compressionRatio,
      tokensEstimate,
    };
  } catch (error) {
    console.error('Error optimizing image:', error);
    throw error;
  }
}

/**
 * Smart crop to remove empty space and focus on content
 */
async function smartCrop(imageBuffer: Buffer): Promise<Buffer> {
  try {
    // Get image dimensions
    const { width, height } = await sharp(imageBuffer).metadata();
    
    if (!width || !height) {
      return imageBuffer;
    }
    
    // Convert to grayscale for analysis
    const grayscaleBuffer = await sharp(imageBuffer)
      .greyscale()
      .raw()
      .toBuffer();
    
    // Find content boundaries
    const contentBounds = findContentBounds(grayscaleBuffer, width, height);
    
    // Apply crop if content bounds are significantly smaller than image
    const contentArea = (contentBounds.right - contentBounds.left) * (contentBounds.bottom - contentBounds.top);
    const totalArea = width * height;
    
    if (contentArea < totalArea * 0.8) {
      // Add small padding
      const padding = 20;
      const cropLeft = Math.max(0, contentBounds.left - padding);
      const cropTop = Math.max(0, contentBounds.top - padding);
      const cropWidth = Math.min(width - cropLeft, contentBounds.right - contentBounds.left + 2 * padding);
      const cropHeight = Math.min(height - cropTop, contentBounds.bottom - contentBounds.top + 2 * padding);
      
      return sharp(imageBuffer)
        .extract({
          left: cropLeft,
          top: cropTop,
          width: cropWidth,
          height: cropHeight,
        })
        .toBuffer();
    }
    
    return imageBuffer;
  } catch (error) {
    console.error('Error in smart crop:', error);
    return imageBuffer;
  }
}

/**
 * Find content boundaries in grayscale image
 */
function findContentBounds(
  grayscaleBuffer: Buffer,
  width: number,
  height: number
): { left: number; top: number; right: number; bottom: number } {
  const pixels = new Uint8Array(grayscaleBuffer);
  const threshold = 240; // Near-white threshold
  
  let left = width;
  let right = 0;
  let top = height;
  let bottom = 0;
  
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const pixelIndex = y * width + x;
      const pixelValue = pixels[pixelIndex];
      
      // If pixel is not near-white, it's content
      if (pixelValue < threshold) {
        left = Math.min(left, x);
        right = Math.max(right, x);
        top = Math.min(top, y);
        bottom = Math.max(bottom, y);
      }
    }
  }
  
  // Ensure valid bounds
  if (left >= width) left = 0;
  if (right <= 0) right = width - 1;
  if (top >= height) top = 0;
  if (bottom <= 0) bottom = height - 1;
  
  return { left, top, right, bottom };
}

/**
 * Estimate AI token cost based on image characteristics
 */
function estimateTokenCost(imageBuffer: Buffer, metadata: ImageMetadata): number {
  // Base token cost for image processing
  const baseTokens = 100;
  
  // Adjust based on image size and complexity
  const sizeMultiplier = Math.sqrt((metadata.width * metadata.height) / (512 * 512));
  const complexityMultiplier = metadata.channels > 3 ? 1.2 : 1.0;
  
  // File size influence
  const sizeFactor = Math.log(imageBuffer.length / 1024) / Math.log(2);
  
  return Math.round(baseTokens * sizeMultiplier * complexityMultiplier * Math.max(1, sizeFactor));
}

/**
 * Check if image has changed significantly compared to cached version
 */
export async function hasImageChanged(
  imageBuffer: Buffer,
  cacheKey: string,
  threshold: number = OPTIMIZATION_CONFIG.SIMILARITY_THRESHOLD
): Promise<{
  hasChanged: boolean;
  similarity: number;
  cachedHash?: string;
  newHash: string;
}> {
  try {
    // Generate hash for new image
    const newHash = await generatePerceptualHash(imageBuffer);
    
    // Check cache for previous version
    const cachedData = imageCache.get(cacheKey);
    
    if (!cachedData) {
      return {
        hasChanged: true,
        similarity: 0,
        newHash,
      };
    }
    
    // Compare hashes
    const similarity = compareHashes(cachedData.hash, newHash);
    const hasChanged = similarity < threshold;
    
    return {
      hasChanged,
      similarity,
      cachedHash: cachedData.hash,
      newHash,
    };
  } catch (error) {
    console.error('Error checking image changes:', error);
    return {
      hasChanged: true,
      similarity: 0,
      newHash: '',
    };
  }
}

/**
 * Process and cache image with optimization
 */
export async function processAndCacheImage(
  imageBuffer: Buffer,
  cacheKey: string,
  options: {
    forceQuality?: 'high' | 'medium' | 'low';
    maxDimensions?: { width: number; height: number };
    targetTokens?: number;
  } = {}
): Promise<OptimizationResult & { fromCache: boolean }> {
  try {
    // Check if image has changed
    const changeResult = await hasImageChanged(imageBuffer, cacheKey);
    
    if (!changeResult.hasChanged) {
      // Return cached data if available
      const cachedData = imageCache.get(cacheKey);
      if (cachedData) {
        return {
          buffer: imageBuffer, // Return original buffer for cached images
          metadata: cachedData.metadata,
          hash: cachedData.hash,
          quality: 'medium', // Default quality for cached
          compressionRatio: cachedData.originalSize / cachedData.optimizedSize,
          tokensEstimate: estimateTokenCost(imageBuffer, cachedData.metadata),
          fromCache: true,
        };
      }
    }
    
    // Process new or changed image
    const result = await optimizeImage(imageBuffer, options);
    
    // Cache the result
    imageCache.set(cacheKey, {
      hash: result.hash,
      timestamp: Date.now(),
      metadata: result.metadata,
      originalSize: imageBuffer.length,
      optimizedSize: result.buffer.length,
    });
    
    return {
      ...result,
      fromCache: false,
    };
  } catch (error) {
    console.error('Error processing and caching image:', error);
    throw error;
  }
}

/**
 * Clear expired cache entries
 */
export function clearExpiredCache(): void {
  const now = Date.now();
  const keysToDelete: string[] = [];
  
  for (const [key, data] of imageCache['cache']) {
    if (now - data.timestamp > OPTIMIZATION_CONFIG.CACHE_TTL) {
      keysToDelete.push(key);
    }
  }
  
  keysToDelete.forEach(key => {
    const data = imageCache.get(key);
    if (data) {
      imageCache['cache'].delete(key);
      imageCache['hashToPath'].delete(data.hash);
    }
  });
}

/**
 * Get cache statistics
 */
export function getCacheStats(): {
  size: number;
  maxSize: number;
  hitRate: number;
  oldestEntry: number;
} {
  const entries = Array.from(imageCache['cache'].values());
  const oldestEntry = entries.length > 0 ? Math.min(...entries.map(e => e.timestamp)) : 0;
  
  return {
    size: imageCache.size(),
    maxSize: OPTIMIZATION_CONFIG.MAX_CACHE_SIZE,
    hitRate: 0, // Would need to track hits vs misses
    oldestEntry,
  };
}

// Initialize cache cleanup interval
setInterval(clearExpiredCache, 60 * 60 * 1000); // Clean every hour