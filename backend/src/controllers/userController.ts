import { db } from '../db/client.js';
import { users, gradeEnum } from '../db/schema.js';
import { eq } from 'drizzle-orm';
import type { Context } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { 
  processProfileImage, 
  deleteProfileImage as deleteImageFile, 
  generateImageUrl 
} from '../middleware/fileUploadMiddleware.js';

// Grade display names for Japanese education system
const gradeDisplayNames = {
  'junior_high_1': '中学1年生',
  'junior_high_2': '中学2年生', 
  'junior_high_3': '中学3年生',
  'senior_high_1': '高校1年生',
  'senior_high_2': '高校2年生',
  'senior_high_3': '高校3年生',
  'kosen_1': '高専1年生',
  'kosen_2': '高専2年生',
  'kosen_3': '高専3年生',
  'kosen_4': '高専4年生',
  'kosen_5': '高専5年生',
} as const;

// Get user profile
export const getUserProfile = async (c: Context) => {
  try {
    const user = c.get('user');
    
    const userProfile = await db.select()
      .from(users)
      .where(eq(users.uid, user.uid));
    
    if (!userProfile.length) {
      return c.json({ success: false, error: 'User profile not found' }, 404);
    }
    
    const profile = userProfile[0];
    const gradeDisplayName = profile.grade ? gradeDisplayNames[profile.grade as keyof typeof gradeDisplayNames] : null;
    
    // Generate image URLs if profile image exists
    const baseUrl = `${c.req.url.split('/api')[0]}`;
    const profileImageUrl = profile.profileImageUrl ? generateImageUrl(profile.profileImageUrl, baseUrl) : null;
    const thumbnailUrl = profile.profileImageUrl ? generateImageUrl(profile.profileImageUrl.replace('processed_', 'thumb_'), baseUrl) : null;
    
    return c.json({ 
      success: true, 
      profile: {
        ...profile,
        gradeDisplayName,
        profileImageUrl,
        thumbnailUrl
      }
    });
  } catch (error) {
    console.error('Error fetching user profile:', error);
    return c.json({ success: false, error: 'Failed to fetch user profile' }, 500);
  }
};

// Update user profile (display name and grade)
export const updateUserProfile = async (c: Context) => {
  try {
    const user = c.get('user');
    const { displayName, grade } = await c.req.json();
    
    // Validate grade if provided
    if (grade && !gradeEnum.includes(grade)) {
      return c.json({ 
        success: false, 
        error: 'Invalid grade. Must be one of: ' + gradeEnum.join(', ') 
      }, 400);
    }
    
    // Validate display name length
    if (displayName && displayName.length > 100) {
      return c.json({ 
        success: false, 
        error: 'Display name must be 100 characters or less' 
      }, 400);
    }
    
    // Check if user exists
    const existingUser = await db.select()
      .from(users)
      .where(eq(users.uid, user.uid));
    
    let updatedUser;
    
    if (existingUser.length === 0) {
      // Create new user profile
      updatedUser = await db.insert(users).values({
        uid: user.uid,
        email: user.email || '',
        displayName: displayName || null,
        grade: grade || null,
      }).returning();
    } else {
      // Update existing user profile
      const updateData: any = { updatedAt: new Date() };
      if (displayName !== undefined) updateData.displayName = displayName;
      if (grade !== undefined) updateData.grade = grade;
      
      updatedUser = await db.update(users)
        .set(updateData)
        .where(eq(users.uid, user.uid))
        .returning();
    }
    
    const profile = updatedUser[0];
    const gradeDisplayName = profile.grade ? gradeDisplayNames[profile.grade as keyof typeof gradeDisplayNames] : null;
    
    return c.json({ 
      success: true, 
      profile: {
        ...profile,
        gradeDisplayName
      }
    });
  } catch (error) {
    console.error('Error updating user profile:', error);
    return c.json({ success: false, error: 'Failed to update user profile' }, 500);
  }
};

// Complete first-time user registration
export const completeUserRegistration = async (c: Context) => {
  try {
    const user = c.get('user');
    const { displayName, grade } = await c.req.json();
    
    // Validate required fields for registration
    if (!displayName || !grade) {
      return c.json({ 
        success: false, 
        error: 'Display name and grade are required for registration' 
      }, 400);
    }
    
    // Validate grade
    if (!gradeEnum.includes(grade)) {
      return c.json({ 
        success: false, 
        error: 'Invalid grade. Must be one of: ' + gradeEnum.join(', ') 
      }, 400);
    }
    
    // Validate display name length
    if (displayName.length > 100) {
      return c.json({ 
        success: false, 
        error: 'Display name must be 100 characters or less' 
      }, 400);
    }
    
    // Check if user already exists
    const existingUser = await db.select()
      .from(users)
      .where(eq(users.uid, user.uid));
    
    let updatedUser;
    
    if (existingUser.length === 0) {
      // Create new user profile with complete registration
      updatedUser = await db.insert(users).values({
        uid: user.uid,
        email: user.email || '',
        displayName,
        grade,
        isProfileComplete: true,
      }).returning();
    } else {
      // Update existing user profile and mark as complete
      updatedUser = await db.update(users)
        .set({
          displayName,
          grade,
          isProfileComplete: true,
          updatedAt: new Date(),
        })
        .where(eq(users.uid, user.uid))
        .returning();
    }
    
    const profile = updatedUser[0];
    const gradeDisplayName = profile.grade ? gradeDisplayNames[profile.grade as keyof typeof gradeDisplayNames] : null;
    
    return c.json({ 
      success: true, 
      message: 'User registration completed successfully',
      profile: {
        ...profile,
        gradeDisplayName
      }
    });
  } catch (error) {
    console.error('Error completing user registration:', error);
    return c.json({ success: false, error: 'Failed to complete user registration' }, 500);
  }
};

// Check if user needs to complete registration
export const checkRegistrationStatus = async (c: Context) => {
  try {
    const user = c.get('user');
    
    const userProfile = await db.select()
      .from(users)
      .where(eq(users.uid, user.uid));
    
    if (!userProfile.length) {
      return c.json({ 
        success: true, 
        needsRegistration: true,
        message: 'User profile not found' 
      });
    }
    
    const profile = userProfile[0];
    const needsRegistration = !profile.isProfileComplete || !profile.displayName || !profile.grade;
    
    return c.json({ 
      success: true, 
      needsRegistration,
      profile: needsRegistration ? null : profile
    });
  } catch (error) {
    console.error('Error checking registration status:', error);
    return c.json({ success: false, error: 'Failed to check registration status' }, 500);
  }
};

// Get available grades
export const getAvailableGrades = async (c: Context) => {
  try {
    const grades = gradeEnum.map(grade => ({
      key: grade,
      displayName: gradeDisplayNames[grade as keyof typeof gradeDisplayNames],
      category: grade.startsWith('junior_high') ? 'junior_high' :
                grade.startsWith('senior_high') ? 'senior_high' :
                'kosen'
    }));
    
    return c.json({ success: true, grades });
  } catch (error) {
    console.error('Error fetching available grades:', error);
    return c.json({ success: false, error: 'Failed to fetch available grades' }, 500);
  }
};

// Upload profile image
export const uploadProfileImage = async (c: Context) => {
  try {
    const user = c.get('user');
    const uploadedFile = c.get('uploadedFile') as {
      originalname: string;
      mimetype: string;
      size: number;
      buffer: Buffer;
    };
    
    if (!uploadedFile) {
      throw new HTTPException(400, { message: 'No image file provided' });
    }

    // Get current user profile to check for existing image
    const [currentUser] = await db.select()
      .from(users)
      .where(eq(users.uid, user.uid))
      .limit(1);

    if (!currentUser) {
      throw new HTTPException(404, { message: 'User not found' });
    }

    // Process the uploaded image
    const { processedPath, thumbnailPath, metadata } = await processProfileImage(
      uploadedFile.buffer,
      uploadedFile.originalname,
      uploadedFile.mimetype
    );

    // Delete old profile image if exists
    if (currentUser.profileImageUrl) {
      await deleteImageFile(currentUser.profileImageUrl);
    }

    // Update user profile with new image information
    const updatedUser = await db.update(users)
      .set({
        profileImageUrl: processedPath,
        profileImageOriginalName: uploadedFile.originalname,
        profileImageSize: uploadedFile.size,
        profileImageMimeType: uploadedFile.mimetype,
        updatedAt: new Date(),
      })
      .where(eq(users.uid, user.uid))
      .returning();

    if (!updatedUser.length) {
      // Clean up uploaded files if database update failed
      await deleteImageFile(processedPath);
      throw new HTTPException(500, { message: 'Failed to update user profile' });
    }

    // Generate URLs for response
    const baseUrl = `${c.req.url.split('/api')[0]}`;
    const profileImageUrl = generateImageUrl(processedPath, baseUrl);
    const thumbnailUrl = generateImageUrl(thumbnailPath, baseUrl);

    return c.json({
      success: true,
      message: 'Profile image uploaded successfully',
      data: {
        profileImageUrl,
        thumbnailUrl,
        originalName: uploadedFile.originalname,
        size: uploadedFile.size,
        dimensions: {
          width: metadata.width,
          height: metadata.height,
        },
      },
    });

  } catch (error) {
    console.error('Profile image upload error:', error);
    if (error instanceof HTTPException) {
      throw error;
    }
    throw new HTTPException(500, { message: 'Failed to upload profile image' });
  }
};

// Delete profile image
export const deleteProfileImage = async (c: Context) => {
  try {
    const user = c.get('user');

    // Get current user profile
    const [currentUser] = await db.select()
      .from(users)
      .where(eq(users.uid, user.uid))
      .limit(1);

    if (!currentUser) {
      throw new HTTPException(404, { message: 'User not found' });
    }

    if (!currentUser.profileImageUrl) {
      return c.json({
        success: true,
        message: 'No profile image to delete',
      });
    }

    // Delete image files
    await deleteImageFile(currentUser.profileImageUrl);

    // Update user profile to remove image information
    await db.update(users)
      .set({
        profileImageUrl: null,
        profileImageOriginalName: null,
        profileImageSize: null,
        profileImageMimeType: null,
        updatedAt: new Date(),
      })
      .where(eq(users.uid, user.uid));

    return c.json({
      success: true,
      message: 'Profile image deleted successfully',
    });

  } catch (error) {
    console.error('Profile image deletion error:', error);
    if (error instanceof HTTPException) {
      throw error;
    }
    throw new HTTPException(500, { message: 'Failed to delete profile image' });
  }
};
