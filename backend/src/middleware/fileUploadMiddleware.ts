import sharp from 'sharp';
import path from 'path';
import fs from 'fs/promises';
import type { Context, Next } from 'hono';
import { HTTPException } from 'hono/http-exception';
import crypto from 'crypto';
import heicConvert from 'heic-convert';

// File upload configuration
const UPLOAD_DIR = './uploads/profile-images';
const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB (increased for HEIC files which can be larger)
const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/heic', 'image/heif'];
const MAX_DIMENSIONS = { width: 1024, height: 1024 };
const THUMBNAIL_SIZE = { width: 200, height: 200 };

// Ensure upload directory exists
async function ensureUploadDir() {
  try {
    await fs.access(UPLOAD_DIR);
  } catch {
    await fs.mkdir(UPLOAD_DIR, { recursive: true });
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
  await ensureUploadDir();

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
  const processedPath = path.join(UPLOAD_DIR, `processed_${baseFilename}`);
  const thumbnailPath = path.join(UPLOAD_DIR, `thumb_${baseFilename}`);

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

      const filePath = path.join(UPLOAD_DIR, filename);
      
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
