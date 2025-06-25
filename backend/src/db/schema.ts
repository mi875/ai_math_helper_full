import { pgTable, serial, text, timestamp, varchar, integer, boolean } from 'drizzle-orm/pg-core';

// Define your database schema here

// Japanese education system grades enum
export const gradeEnum = [
  // Junior High School (Chugakko) - 中学校
  'junior_high_1', // 中学1年生
  'junior_high_2', // 中学2年生
  'junior_high_3', // 中学3年生
  // Senior High School (Kotogakko) - 高等学校
  'senior_high_1', // 高校1年生
  'senior_high_2', // 高校2年生
  'senior_high_3', // 高校3年生
  // Kosen (Koto Senmon Gakko) - 高等専門学校
  'kosen_1', // 高専1年生
  'kosen_2', // 高専2年生
  'kosen_3', // 高専3年生
  'kosen_4', // 高専4年生
  'kosen_5', // 高専5年生
] as const;

// Example: Users table
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  uid: varchar('uid', { length: 128 }).notNull().unique(), // Firebase Auth UID
  email: varchar('email', { length: 255 }).notNull(),
  displayName: varchar('display_name', { length: 100 }),
  grade: varchar('grade', { length: 20 }), // Japanese education system grade
  // Profile image
  profileImageUrl: varchar('profile_image_url', { length: 500 }), // URL to uploaded image
  profileImageOriginalName: varchar('profile_image_original_name', { length: 255 }), // Original file name
  profileImageSize: integer('profile_image_size'), // File size in bytes
  profileImageMimeType: varchar('profile_image_mime_type', { length: 50 }), // MIME type
  // Token management
  totalTokens: integer('total_tokens').default(1000), // Total tokens allocated
  usedTokens: integer('used_tokens').default(0), // Tokens consumed
  remainingTokens: integer('remaining_tokens').default(1000), // Tokens left
  tokenResetDate: timestamp('token_reset_date'), // When tokens reset (monthly)
  isActive: boolean('is_active').default(true), // Account status
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

// API usage tracking table
export const apiUsage = pgTable('api_usage', {
  id: serial('id').primaryKey(),
  userId: varchar('user_id', { length: 128 }).notNull(),
  endpoint: varchar('endpoint', { length: 255 }).notNull(),
  tokensConsumed: integer('tokens_consumed').notNull(),
  requestData: text('request_data'), // JSON string of request data
  responseData: text('response_data'), // JSON string of response data
  status: varchar('status', { length: 20 }).notNull(), // 'success', 'error', 'rate_limited'
  createdAt: timestamp('created_at').defaultNow(),
});

// Notebooks table
export const notebooks = pgTable('notebooks', {
  id: serial('id').primaryKey(),
  uid: varchar('uid', { length: 128 }).notNull(), // UUID for frontend
  userId: varchar('user_id', { length: 128 }).notNull(), // Firebase UID reference
  title: varchar('title', { length: 255 }).notNull(),
  description: text('description'),
  coverColor: varchar('cover_color', { length: 50 }).default('default'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

// Math problems table
export const mathProblems = pgTable('math_problems', {
  id: serial('id').primaryKey(),
  uid: varchar('uid', { length: 128 }).notNull(), // UUID for frontend
  notebookId: integer('notebook_id').notNull(),
  userId: varchar('user_id', { length: 128 }).notNull(), // Firebase UID reference
  title: varchar('title', { length: 255 }),
  description: text('description'),
  scribbleData: text('scribble_data'), // Scribble drawing data
  status: varchar('status', { length: 20 }).default('unsolved'), // 'unsolved', 'in_progress', 'solved', 'needs_help'
  tags: text('tags'), // JSON array of tags
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

// Problem images table
export const problemImages = pgTable('problem_images', {
  id: serial('id').primaryKey(),
  uid: varchar('uid', { length: 128 }).notNull(), // UUID for frontend
  problemId: integer('problem_id').notNull(),
  userId: varchar('user_id', { length: 128 }).notNull(), // Firebase UID reference
  originalFilename: varchar('original_filename', { length: 255 }).notNull(),
  filename: varchar('filename', { length: 255 }).notNull(), // Processed filename
  filePath: varchar('file_path', { length: 500 }).notNull(), // Server file path
  fileUrl: varchar('file_url', { length: 500 }).notNull(), // Public URL
  mimeType: varchar('mime_type', { length: 50 }).notNull(),
  fileSize: integer('file_size').notNull(), // Size in bytes
  width: integer('width'), // Image width in pixels
  height: integer('height'), // Image height in pixels
  displayOrder: integer('display_order').default(0), // Order for display
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

