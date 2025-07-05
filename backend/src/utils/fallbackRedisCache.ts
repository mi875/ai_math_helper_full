import { generatePerceptualHash, compareHashes } from './imageOptimizer.js';

// Cache keys and TTL settings
const CACHE_SETTINGS = {
  IMAGE_HASH_PREFIX: 'img_hash:',
  CANVAS_HASH_PREFIX: 'canvas_hash:',
  PROBLEM_HASH_PREFIX: 'problem_hash:',
  USER_SESSION_PREFIX: 'user_session:',
  SIMILARITY_INDEX_PREFIX: 'similarity:',
  DEFAULT_TTL: 24 * 60 * 60, // 24 hours in seconds
  CANVAS_TTL: 2 * 60 * 60, // 2 hours for canvas images
  SESSION_TTL: 4 * 60 * 60, // 4 hours for user sessions
};

interface CachedImageData {
  hash: string;
  timestamp: number;
  metadata: {
    width: number;
    height: number;
    size: number;
    quality: string;
    compressionRatio: number;
  };
  userId?: string;
  problemId?: string;
  sessionId?: string;
  tokensEstimate: number;
}

interface SimilarityResult {
  hash: string;
  similarity: number;
  cacheKey: string;
  metadata: CachedImageData;
}

// Fallback in-memory implementation when Redis is not available
class FallbackImageCache {
  private cache: Map<string, CachedImageData> = new Map();
  private isConnected = false;

  constructor() {
    this.isConnected = true;
    console.log('Using fallback in-memory cache (Redis not available)');
  }

  async storeImageHash(
    cacheKey: string,
    imageBuffer: Buffer,
    metadata: CachedImageData,
    ttl: number = CACHE_SETTINGS.DEFAULT_TTL
  ): Promise<boolean> {
    try {
      const hash = await generatePerceptualHash(imageBuffer);
      
      const dataToStore = {
        ...metadata,
        hash,
        timestamp: Date.now(),
      };

      this.cache.set(cacheKey, dataToStore);
      
      // Schedule cleanup after TTL
      setTimeout(() => {
        this.cache.delete(cacheKey);
      }, ttl * 1000);

      return true;
    } catch (error) {
      console.error('Error storing image hash in fallback cache:', error);
      return false;
    }
  }

  async checkImageChange(
    cacheKey: string,
    imageBuffer: Buffer,
    threshold: number = 0.85
  ): Promise<{
    hasChanged: boolean;
    similarity: number;
    cachedData?: CachedImageData;
    newHash: string;
  }> {
    try {
      const newHash = await generatePerceptualHash(imageBuffer);
      const cachedData = this.cache.get(cacheKey);

      if (!cachedData) {
        return {
          hasChanged: true,
          similarity: 0,
          newHash,
        };
      }

      const similarity = compareHashes(cachedData.hash, newHash);
      const hasChanged = similarity < threshold;

      return {
        hasChanged,
        similarity,
        cachedData,
        newHash,
      };
    } catch (error) {
      console.error('Error checking image change in fallback cache:', error);
      return {
        hasChanged: true,
        similarity: 0,
        newHash: '',
      };
    }
  }

  async findSimilarImages(
    imageBuffer: Buffer,
    threshold: number = 0.8,
    limit: number = 10
  ): Promise<SimilarityResult[]> {
    try {
      const newHash = await generatePerceptualHash(imageBuffer);
      const results: SimilarityResult[] = [];

      for (const [cacheKey, cachedData] of this.cache.entries()) {
        const similarity = compareHashes(newHash, cachedData.hash);

        if (similarity >= threshold) {
          results.push({
            hash: cachedData.hash,
            similarity,
            cacheKey,
            metadata: cachedData,
          });
        }
      }

      return results
        .sort((a, b) => b.similarity - a.similarity)
        .slice(0, limit);
    } catch (error) {
      console.error('Error finding similar images in fallback cache:', error);
      return [];
    }
  }

  async getCachedImageData(cacheKey: string): Promise<CachedImageData | null> {
    return this.cache.get(cacheKey) || null;
  }

  async storeCanvasHash(
    userId: string,
    problemId: string,
    sessionId: string,
    imageBuffer: Buffer,
    metadata: CachedImageData
  ): Promise<boolean> {
    const cacheKey = `canvas_${userId}_${problemId}_${sessionId}`;
    return this.storeImageHash(cacheKey, imageBuffer, metadata, CACHE_SETTINGS.CANVAS_TTL);
  }

  async checkCanvasChange(
    userId: string,
    problemId: string,
    sessionId: string,
    imageBuffer: Buffer,
    threshold: number = 0.85
  ): Promise<{
    hasChanged: boolean;
    similarity: number;
    cachedData?: CachedImageData;
    newHash: string;
  }> {
    const cacheKey = `canvas_${userId}_${problemId}_${sessionId}`;
    return this.checkImageChange(cacheKey, imageBuffer, threshold);
  }

  async getUserSessionStats(userId: string): Promise<{
    totalSessions: number;
    totalCanvasChanges: number;
    averageSimilarity: number;
    tokensSaved: number;
  }> {
    let totalSessions = 0;
    let totalCanvasChanges = 0;
    let totalSimilarity = 0;
    let tokensSaved = 0;

    for (const [key, data] of this.cache.entries()) {
      if (key.includes(userId)) {
        totalSessions++;
        if (data.userId === userId) {
          totalCanvasChanges++;
          totalSimilarity += 1; // Assume similarity of 1 for cached items
          tokensSaved += data.tokensEstimate || 0;
        }
      }
    }

    return {
      totalSessions,
      totalCanvasChanges,
      averageSimilarity: totalCanvasChanges > 0 ? totalSimilarity / totalCanvasChanges : 0,
      tokensSaved,
    };
  }

  async clearExpiredEntries(): Promise<number> {
    const now = Date.now();
    let deletedCount = 0;

    for (const [key, data] of this.cache.entries()) {
      if (now - data.timestamp > CACHE_SETTINGS.DEFAULT_TTL * 1000) {
        this.cache.delete(key);
        deletedCount++;
      }
    }

    return deletedCount;
  }

  async getCacheStats(): Promise<{
    totalKeys: number;
    imageHashes: number;
    canvasHashes: number;
    activeSessions: number;
    memoryUsage: string;
  }> {
    const totalKeys = this.cache.size;
    let imageHashes = 0;
    let canvasHashes = 0;
    let activeSessions = 0;

    for (const key of this.cache.keys()) {
      if (key.startsWith(CACHE_SETTINGS.IMAGE_HASH_PREFIX)) {
        imageHashes++;
      } else if (key.startsWith('canvas_')) {
        canvasHashes++;
      } else if (key.startsWith(CACHE_SETTINGS.USER_SESSION_PREFIX)) {
        activeSessions++;
      }
    }

    // Rough memory estimation
    const memoryUsage = Math.round(totalKeys * 1024 / 1024 * 100) / 100; // Rough estimate

    return {
      totalKeys,
      imageHashes,
      canvasHashes,
      activeSessions,
      memoryUsage: `${memoryUsage}MB`,
    };
  }

  async close(): Promise<void> {
    this.cache.clear();
    this.isConnected = false;
  }
}

// Export singleton instance
export const fallbackImageCache = new FallbackImageCache();

// Utility functions that match the Redis interface
export async function storeCanvasHash(
  userId: string,
  problemId: string,
  sessionId: string,
  imageBuffer: Buffer,
  metadata: CachedImageData
): Promise<boolean> {
  return fallbackImageCache.storeCanvasHash(userId, problemId, sessionId, imageBuffer, metadata);
}

export async function checkCanvasChange(
  userId: string,
  problemId: string,
  sessionId: string,
  imageBuffer: Buffer,
  threshold: number = 0.85
): Promise<{
  hasChanged: boolean;
  similarity: number;
  cachedData?: CachedImageData;
  newHash: string;
}> {
  return fallbackImageCache.checkCanvasChange(userId, problemId, sessionId, imageBuffer, threshold);
}

export async function findSimilarImages(
  imageBuffer: Buffer,
  threshold: number = 0.8,
  limit: number = 10
): Promise<SimilarityResult[]> {
  return fallbackImageCache.findSimilarImages(imageBuffer, threshold, limit);
}

export async function getCacheStats() {
  return fallbackImageCache.getCacheStats();
}

// Create alias for the cache instance
export const redisImageCache = fallbackImageCache;

// Initialize cleanup interval
setInterval(async () => {
  try {
    await fallbackImageCache.clearExpiredEntries();
  } catch (error) {
    console.error('Error in cache cleanup interval:', error);
  }
}, 60 * 60 * 1000); // Clean every hour