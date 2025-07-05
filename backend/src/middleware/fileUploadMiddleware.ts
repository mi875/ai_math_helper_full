import sharp from 'sharp';
import path from 'path';
import fs from 'fs/promises';
import type { Context, Next } from 'hono';
import { HTTPException } from 'hono/http-exception';
import crypto from 'crypto';
import heicConvert from 'heic-convert';
import { processAndCacheImage, hasImageChanged } from '../utils/imageOptimizer.js';
import { checkCanvasChange, storeCanvasHash } from '../utils/fallbackRedisCache.js';

// File upload configuration
const PROFILE_UPLOAD_DIR = './uploads/profile-images';
const PROBLEM_UPLOAD_DIR = './uploads/problem-images';
const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB (increased for HEIC files which can be larger)
const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/heic', 'image/heif'];
const MAX_DIMENSIONS = { width: 1024, height: 1024 };
const THUMBNAIL_SIZE = { width: 200, height: 200 };

// Ensure upload directory exists
async function ensureUploadDir(uploadDir: string) {
  try {
    await fs.access(uploadDir);
  } catch {
    await fs.mkdir(uploadDir, { recursive: true });
  }
}

// File validation function
export function validateImageFile(file: { originalname: string; mimetype: string; size: number }): { isValid: boolean; error?: string } {
  // Check file size
  if (file.size > MAX_FILE_SIZE) {
    const errorMsg = `File size too large. Maximum size is ${MAX_FILE_SIZE / (1024 * 1024)}MB, received ${(file.size / (1024 * 1024)).toFixed(2)}MB`;
    return { isValid: false, error: errorMsg };
  }

  // Get file extension
  const extension = path.extname(file.originalname).toLowerCase();

  // Check if it's a HEIC file
  const isHeicFile = ['.heic', '.heif'].includes(extension);

  // Check MIME type (allow generic types for HEIC files)
  const isMimeTypeAllowed = ALLOWED_MIME_TYPES.includes(file.mimetype);
  const isGenericHeic = isHeicFile && (file.mimetype === 'application/octet-stream' || file.mimetype === '');
  
  if (!isMimeTypeAllowed && !isGenericHeic) {
    const errorMsg = `Invalid file type. Received MIME type: "${file.mimetype}". Allowed types: JPEG, PNG, WebP, GIF, HEIC`;
    return { isValid: false, error: errorMsg };
  }

  // Check file extension matches MIME type (for non-HEIC files)
  if (!isHeicFile) {
    const mimeToExt: Record<string, string[]> = {
      'image/jpeg': ['.jpg', '.jpeg'],
      'image/png': ['.png'],
      'image/webp': ['.webp'],
      'image/gif': ['.gif'],
    };

    const allowedExtensions = mimeToExt[file.mimetype] || [];
    
    if (allowedExtensions.length > 0 && !allowedExtensions.includes(extension)) {
      const errorMsg = `File extension "${extension}" does not match MIME type "${file.mimetype}"`;
      return { isValid: false, error: errorMsg };
    }
  }

  return { isValid: true };
}

// HEIC conversion function
async function convertHeicToJpeg(inputBuffer: Buffer): Promise<Buffer> {
  try {
    const convertedBuffer = await heicConvert({
      buffer: inputBuffer.buffer.slice(inputBuffer.byteOffset, inputBuffer.byteOffset + inputBuffer.byteLength),
      format: 'JPEG',
      quality: 0.85,
    });
    return Buffer.from(convertedBuffer);
  } catch (error) {
    console.error('HEIC conversion error:', error);
    throw new Error('Failed to convert HEIC image');
  }
}

// Image processing function
export async function processProfileImage(
  inputBuffer: Buffer,
  filename: string,
  mimeType?: string
): Promise<{ processedPath: string; thumbnailPath: string; metadata: any }> {
  await ensureUploadDir(PROFILE_UPLOAD_DIR);

  const fileId = crypto.randomUUID();
  const extension = path.extname(filename).toLowerCase();
  
  // Check if we need to convert HEIC to JPEG
  let processBuffer = inputBuffer;
  let processedFilename = filename;
  
  if (extension === '.heic' || extension === '.heif' || mimeType === 'image/heic' || mimeType === 'image/heif') {
    console.log('Converting HEIC/HEIF image to JPEG...');
    processBuffer = await convertHeicToJpeg(inputBuffer);
    // Change filename extension to .jpg
    processedFilename = filename.replace(/\.(heic|heif)$/i, '.jpg');
  }
  
  const baseFilename = `${fileId}_${processedFilename}`;
  const processedPath = path.join(PROFILE_UPLOAD_DIR, `processed_${baseFilename}`);
  const thumbnailPath = path.join(PROFILE_UPLOAD_DIR, `thumb_${baseFilename}`);

  try {
    // Get image metadata and validate dimensions
    const metadata = await sharp(processBuffer).metadata();
    
    if (!metadata.width || !metadata.height) {
      throw new Error('Invalid image: Unable to determine dimensions');
    }

    // Process main image (resize if too large, optimize)
    await sharp(processBuffer)
      .resize(MAX_DIMENSIONS.width, MAX_DIMENSIONS.height, {
        fit: 'inside',
        withoutEnlargement: true,
      })
      .jpeg({ quality: 85, progressive: true })
      .toFile(processedPath);

    // Create thumbnail
    await sharp(processBuffer)
      .resize(THUMBNAIL_SIZE.width, THUMBNAIL_SIZE.height, {
        fit: 'cover',
        position: 'center',
      })
      .jpeg({ quality: 80 })
      .toFile(thumbnailPath);

    return { processedPath, thumbnailPath, metadata };
  } catch (error) {
    // Clean up files if processing failed
    try {
      await fs.unlink(processedPath).catch(() => {});
      await fs.unlink(thumbnailPath).catch(() => {});
    } catch {}
    throw error;
  }
}

// Problem image processing function with intelligent optimization
export async function processProblemImage(
  inputBuffer: Buffer,
  filename: string,
  mimeType?: string,
  options: {
    userId?: string;
    problemId?: string;
    forceQuality?: 'high' | 'medium' | 'low';
  } = {}
): Promise<{ 
  processedPath: string; 
  metadata: any; 
  optimizationResult: {
    hash: string;
    quality: string;
    compressionRatio: number;
    tokensEstimate: number;
    fromCache: boolean;
  };
}> {
  await ensureUploadDir(PROBLEM_UPLOAD_DIR);

  const fileId = crypto.randomUUID();
  const extension = path.extname(filename).toLowerCase();
  
  // Check if we need to convert HEIC to JPEG
  let processBuffer = inputBuffer;
  let processedFilename = filename;
  
  if (extension === '.heic' || extension === '.heif' || mimeType === 'image/heic' || mimeType === 'image/heif') {
    console.log('Converting HEIC/HEIF image to JPEG...');
    processBuffer = await convertHeicToJpeg(inputBuffer);
    // Change filename extension to .jpg
    processedFilename = filename.replace(/\.(heic|heif)$/i, '.jpg');
  }
  
  const baseFilename = `${fileId}_${processedFilename}`;
  const processedPath = path.join(PROBLEM_UPLOAD_DIR, `processed_${baseFilename}`);

  try {
    // Create cache key for intelligent optimization
    const cacheKey = options.userId && options.problemId 
      ? `${options.userId}_${options.problemId}_${filename}`
      : `${fileId}_${filename}`;
    
    // Use intelligent optimization system
    const optimizationResult = await processAndCacheImage(processBuffer, cacheKey, {
      forceQuality: options.forceQuality,
      maxDimensions: MAX_DIMENSIONS,
      targetTokens: 150, // Target token cost for problem images
    });

    // Save optimized image to disk
    await fs.writeFile(processedPath, optimizationResult.buffer);

    // Get metadata for return
    const metadata = await sharp(optimizationResult.buffer).metadata();
    
    if (!metadata.width || !metadata.height) {
      throw new Error('Invalid image: Unable to determine dimensions');
    }

    console.log(`Problem image processed - Quality: ${optimizationResult.quality}, Compression: ${optimizationResult.compressionRatio.toFixed(2)}x, Tokens: ${optimizationResult.tokensEstimate}, FromCache: ${optimizationResult.fromCache}`);

    return { 
      processedPath, 
      metadata,
      optimizationResult: {
        hash: optimizationResult.hash,
        quality: optimizationResult.quality,
        compressionRatio: optimizationResult.compressionRatio,
        tokensEstimate: optimizationResult.tokensEstimate,
        fromCache: optimizationResult.fromCache,
      }
    };
  } catch (error) {
    // Clean up files if processing failed
    try {
      await fs.unlink(processedPath).catch(() => {});
    } catch {}
    throw error;
  }
}

// Hono middleware for file upload (native implementation)
export const profileImageUploadMiddleware = () => {
  return async (c: Context, next: Next) => {
    try {
      const body = await c.req.parseBody();
      const file = body['profileImage'] as File;
      
      if (!file) {
        throw new HTTPException(400, { message: 'No profileImage field found in form data' });
      }

      if (!(file instanceof File)) {
        throw new HTTPException(400, { message: 'profileImage must be a file' });
      }

      // Special handling for HEIC files - browsers often don't set correct MIME type
      let mimeType = file.type;
      const extension = path.extname(file.name).toLowerCase();
      if (['.heic', '.heif'].includes(extension) && (!mimeType || mimeType === 'application/octet-stream')) {
        mimeType = 'image/heic';
      }

      // Validate file
      const validation = validateImageFile({
        originalname: file.name,
        mimetype: mimeType,
        size: file.size,
      });

      if (!validation.isValid) {
        throw new HTTPException(400, { message: validation.error });
      }

      // Convert File to Buffer
      const buffer = await file.arrayBuffer();
      const fileBuffer = Buffer.from(buffer);

      // Store file data in context for the handler
      c.set('uploadedFile', {
        originalname: file.name,
        mimetype: mimeType,
        size: file.size,
        buffer: fileBuffer,
      });

      await next();
    } catch (error) {
      console.error('File upload error:', error);
      if (error instanceof HTTPException) {
        throw error;
      }
      throw new HTTPException(500, { message: 'File upload failed' });
    }
  };
};

// Problem image upload middleware
export const problemImageUploadMiddleware = () => {
  return async (c: Context, next: Next) => {
    try {
      const body = await c.req.parseBody();
      const files = body['images'] as File | File[];
      
      if (!files) {
        throw new HTTPException(400, { message: 'No images field found in form data' });
      }

      // Convert single file to array for consistent processing
      const fileArray = Array.isArray(files) ? files : [files];
      
      if (fileArray.length === 0) {
        throw new HTTPException(400, { message: 'At least one image must be provided' });
      }

      if (fileArray.length > 10) {
        throw new HTTPException(400, { message: 'Maximum 10 images allowed per problem' });
      }

      // Validate and process each file
      const processedFiles = [];
      
      for (const file of fileArray) {
        if (!(file instanceof File)) {
          throw new HTTPException(400, { message: 'All images must be valid files' });
        }

        // Special handling for HEIC files - browsers often don't set correct MIME type
        let mimeType = file.type;
        const extension = path.extname(file.name).toLowerCase();
        if (['.heic', '.heif'].includes(extension) && (!mimeType || mimeType === 'application/octet-stream')) {
          mimeType = 'image/heic';
        }

        // Validate file
        const validation = validateImageFile({
          originalname: file.name,
          mimetype: mimeType,
          size: file.size,
        });

        if (!validation.isValid) {
          throw new HTTPException(400, { message: `Invalid file ${file.name}: ${validation.error}` });
        }

        // Convert File to Buffer
        const buffer = await file.arrayBuffer();
        const fileBuffer = Buffer.from(buffer);

        processedFiles.push({
          originalname: file.name,
          mimetype: mimeType,
          size: file.size,
          buffer: fileBuffer,
        });
      }

      // Store file data in context for the handler
      c.set('uploadedFiles', processedFiles);

      await next();
    } catch (error) {
      console.error('File upload error:', error);
      if (error instanceof HTTPException) {
        throw error;
      }
      throw new HTTPException(500, { message: 'File upload failed' });
    }
  };
};

// Helper function to delete old profile images
export async function deleteProfileImage(imagePath: string): Promise<void> {
  try {
    if (imagePath && imagePath.startsWith('./uploads/')) {
      await fs.unlink(imagePath);
      
      // Also try to delete thumbnail
      const thumbnailPath = imagePath.replace('processed_', 'thumb_');
      await fs.unlink(thumbnailPath).catch(() => {}); // Ignore errors for thumbnail
    }
  } catch (error) {
    console.error('Error deleting profile image:', error);
    // Don't throw error - image deletion failure shouldn't break the flow
  }
}

// Helper function to delete problem images
export async function deleteProblemImages(imagePaths: string[]): Promise<void> {
  for (const imagePath of imagePaths) {
    try {
      if (imagePath && imagePath.startsWith('./uploads/')) {
        await fs.unlink(imagePath);
      }
    } catch (error) {
      console.error('Error deleting problem image:', error);
      // Don't throw error - image deletion failure shouldn't break the flow
    }
  }
}

// Canvas image processing function with intelligent change detection
export async function processCanvasImage(
  inputBuffer: Buffer,
  filename: string,
  options: {
    userId: string;
    problemId: string;
    sessionId?: string;
    previousHash?: string;
  }
): Promise<{ 
  processedPath: string | null;
  metadata: any;
  optimizationResult: {
    hash: string;
    quality: string;
    compressionRatio: number;
    tokensEstimate: number;
    fromCache: boolean;
    hasChanged: boolean;
    similarity: number;
  };
}> {
  await ensureUploadDir(PROBLEM_UPLOAD_DIR);

  try {
    // Try Redis first, fall back to in-memory cache
    let changeResult;
    try {
      // Use Redis for enhanced caching if available
      changeResult = await checkCanvasChange(
        options.userId,
        options.problemId,
        options.sessionId || 'default',
        inputBuffer,
        0.85
      );
    } catch (redisError) {
      console.warn('Redis unavailable, falling back to in-memory cache:', redisError);
      // Fallback to in-memory cache
      const cacheKey = `canvas_${options.userId}_${options.problemId}_${options.sessionId || 'default'}`;
      changeResult = await hasImageChanged(inputBuffer, cacheKey, 0.85);
    }
    
    let processedPath: string | null = null;
    let optimizationResult: any;
    
    if (changeResult.hasChanged) {
      console.log(`Canvas image changed - Similarity: ${(changeResult.similarity * 100).toFixed(1)}%`);
      
      // Process the changed image with high quality for math content
      const cacheKey = `canvas_${options.userId}_${options.problemId}_${options.sessionId || 'default'}`;
      optimizationResult = await processAndCacheImage(inputBuffer, cacheKey, {
        forceQuality: 'high', // Canvas images typically contain handwritten math
        maxDimensions: { width: 1024, height: 1024 },
        targetTokens: 200, // Higher token allowance for canvas images
      });
      
      // Save to disk if needed
      const fileId = crypto.randomUUID();
      const baseFilename = `canvas_${fileId}_${filename}`;
      processedPath = path.join(PROBLEM_UPLOAD_DIR, `processed_${baseFilename}`);
      
      await fs.writeFile(processedPath, optimizationResult.buffer);
      
      // Store in Redis cache for future reference
      try {
        await storeCanvasHash(
          options.userId,
          options.problemId,
          options.sessionId || 'default',
          optimizationResult.buffer,
          {
            hash: optimizationResult.hash,
            timestamp: Date.now(),
            metadata: {
              width: optimizationResult.metadata.width,
              height: optimizationResult.metadata.height,
              size: optimizationResult.buffer.length,
              quality: optimizationResult.quality,
              compressionRatio: optimizationResult.compressionRatio,
            },
            userId: options.userId,
            problemId: options.problemId,
            sessionId: options.sessionId,
            tokensEstimate: optimizationResult.tokensEstimate,
          }
        );
      } catch (redisError) {
        console.warn('Failed to store in Redis cache:', redisError);
      }
      
      console.log(`Canvas image processed - Quality: ${optimizationResult.quality}, Compression: ${optimizationResult.compressionRatio.toFixed(2)}x, Tokens: ${optimizationResult.tokensEstimate}`);
    } else {
      console.log(`Canvas image unchanged - Similarity: ${(changeResult.similarity * 100).toFixed(1)}%, skipping AI processing`);
      
      // Return cached optimization data
      optimizationResult = {
        hash: changeResult.newHash,
        quality: 'high',
        compressionRatio: 1.0,
        tokensEstimate: 0, // No tokens consumed for unchanged images
        fromCache: true,
        buffer: inputBuffer,
      };
    }
    
    // Get metadata
    const metadata = await sharp(inputBuffer).metadata();
    
    return { 
      processedPath,
      metadata,
      optimizationResult: {
        hash: optimizationResult.hash,
        quality: optimizationResult.quality,
        compressionRatio: optimizationResult.compressionRatio,
        tokensEstimate: optimizationResult.tokensEstimate,
        fromCache: optimizationResult.fromCache,
        hasChanged: changeResult.hasChanged,
        similarity: changeResult.similarity,
      }
    };
  } catch (error) {
    console.error('Error processing canvas image:', error);
    throw error;
  }
}

// Generate file URL for serving
export function generateImageUrl(filePath: string, baseUrl: string): string {
  if (!filePath) return '';
  
  const fileName = path.basename(filePath);
  return `${baseUrl}/api/files/profile-images/${fileName}`;
}

// File serving middleware
export const serveProfileImage = () => {
  return async (c: Context) => {
    try {
      const filename = c.req.param('filename');
      if (!filename) {
        throw new HTTPException(400, { message: 'Filename is required' });
      }

      // Validate filename to prevent directory traversal
      if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
        throw new HTTPException(400, { message: 'Invalid filename' });
      }

      const filePath = path.join(PROFILE_UPLOAD_DIR, filename);
      
      try {
        await fs.access(filePath);
        const fileBuffer = await fs.readFile(filePath);
        
        // Set appropriate headers
        c.header('Content-Type', 'image/jpeg');
        c.header('Cache-Control', 'public, max-age=86400'); // 24 hours cache
        c.header('Content-Length', fileBuffer.length.toString());
        
        return c.body(fileBuffer);
      } catch (error) {
        throw new HTTPException(404, { message: 'Image not found' });
      }
    } catch (error) {
      console.error('Error serving image:', error);
      if (error instanceof HTTPException) {
        throw error;
      }
      throw new HTTPException(500, { message: 'Error serving image' });
    }
  };
};

// Problem image serving middleware
export const serveProblemImage = () => {
  return async (c: Context) => {
    try {
      const filename = c.req.param('filename');
      if (!filename) {
        throw new HTTPException(400, { message: 'Filename is required' });
      }

      // Validate filename to prevent directory traversal
      if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
        throw new HTTPException(400, { message: 'Invalid filename' });
      }

      const filePath = path.join(PROBLEM_UPLOAD_DIR, filename);
      
      try {
        await fs.access(filePath);
        const fileBuffer = await fs.readFile(filePath);
        
        // Set appropriate headers
        c.header('Content-Type', 'image/jpeg');
        c.header('Cache-Control', 'public, max-age=86400'); // 24 hours cache
        c.header('Content-Length', fileBuffer.length.toString());
        
        return c.body(fileBuffer);
      } catch (error) {
        throw new HTTPException(404, { message: 'Image not found' });
      }
    } catch (error) {
      console.error('Error serving image:', error);
      if (error instanceof HTTPException) {
        throw error;
      }
      throw new HTTPException(500, { message: 'Error serving image' });
    }
  };
};
