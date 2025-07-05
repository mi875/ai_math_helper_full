import type { Context } from 'hono';
import { db } from '../db/client.js';
import { notebooks, mathProblems, users, problemImages, aiFeedbacks, chatThreads } from '../db/schema.js';
import { eq, and, desc, sql } from 'drizzle-orm';
import { randomUUID } from 'crypto';
import { processProblemImage, deleteProblemImages, processCanvasImage } from '../middleware/fileUploadMiddleware.js';
import path from 'path';
import { mastra } from '../mastra/index.js';
import fs from "fs";

// Helper function to ensure user exists in database
async function ensureUserExists(user: { uid: string; email?: string }) {
  const existingUser = await db
    .select()
    .from(users)
    .where(eq(users.uid, user.uid))
    .limit(1);

  if (existingUser.length === 0) {
    await db
      .insert(users)
      .values({
        uid: user.uid,
        email: user.email || '',
        displayName: null,
        grade: null,
      });
  }
}

// Helper function to get or create a chat thread for a problem
async function getOrCreateChatThread(problemId: number, userId: string): Promise<{ threadId: string; resourceId: string }> {
  // Check if a thread already exists for this problem
  const existingThread = await db
    .select()
    .from(chatThreads)
    .where(and(
      eq(chatThreads.problemId, problemId),
      eq(chatThreads.userId, userId)
    ))
    .limit(1);

  if (existingThread.length > 0) {
    return {
      threadId: existingThread[0].threadId,
      resourceId: existingThread[0].resourceId,
    };
  }

  // Create a new thread
  const threadId = randomUUID();
  const resourceId = `${userId}_problem_${problemId}`; // Unique resource ID per user-problem combination

  await db
    .insert(chatThreads)
    .values({
      uid: randomUUID(),
      problemId,
      userId,
      threadId,
      resourceId,
      title: `Math Problem Chat Session`,
    });

  return { threadId, resourceId };
}

export const notebookController = {
  // Get all notebooks for a user with problem counts
  async getNotebooks(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      
      const userNotebooks = await db
        .select()
        .from(notebooks)
        .where(eq(notebooks.userId, userId))
        .orderBy(desc(notebooks.updatedAt));

      // Get problem counts for each notebook
      const notebooksWithCounts = await Promise.all(
        userNotebooks.map(async (notebook) => {
          const problems = await db
            .select()
            .from(mathProblems)
            .where(eq(mathProblems.notebookId, notebook.id));
          
          return {
            ...notebook,
            problems: problems // Include actual problems array for frontend compatibility
          };
        })
      );

      return c.json({
        success: true,
        data: notebooksWithCounts
      });
    } catch (error) {
      console.error('Error fetching notebooks:', error);
      return c.json({
        success: false,
        error: 'Failed to fetch notebooks'
      }, 500);
    }
  },

  // Get a specific notebook with its problems
  async getNotebook(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      const notebookUid = c.req.param('uid');

      const notebook = await db
        .select()
        .from(notebooks)
        .where(and(
          eq(notebooks.uid, notebookUid),
          eq(notebooks.userId, userId)
        ))
        .limit(1);

      if (notebook.length === 0) {
        return c.json({
          success: false,
          error: 'Notebook not found'
        }, 404);
      }

      const problems = await db
        .select()
        .from(mathProblems)
        .where(and(
          eq(mathProblems.notebookId, notebook[0].id),
          eq(mathProblems.userId, userId)
        ))
        .orderBy(desc(mathProblems.updatedAt));

      // Get images for all problems
      const problemsWithImages = await Promise.all(
        problems.map(async (problem) => {
          const images = await db
            .select()
            .from(problemImages)
            .where(eq(problemImages.problemId, problem.id))
            .orderBy(problemImages.displayOrder);

          return {
            ...problem,
            images: images.map(img => ({
              id: img.id,
              uid: img.uid,
              originalFilename: img.originalFilename,
              filename: img.filename,
              fileUrl: img.fileUrl,
              mimeType: img.mimeType,
              fileSize: img.fileSize,
              width: img.width,
              height: img.height,
              displayOrder: img.displayOrder,
              createdAt: img.createdAt,
            })),
            tags: problem.tags ? JSON.parse(problem.tags) : [],
          };
        })
      );

      return c.json({
        success: true,
        data: {
          ...notebook[0],
          problems: problemsWithImages
        }
      });
    } catch (error) {
      console.error('Error fetching notebook:', error);
      return c.json({
        success: false,
        error: 'Failed to fetch notebook'
      }, 500);
    }
  },

  // Create a new notebook
  async createNotebook(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      const { title, description, coverColor } = await c.req.json();

      // Ensure user exists in database
      await ensureUserExists(user);

      const newNotebook = await db
        .insert(notebooks)
        .values({
          uid: randomUUID(),
          userId,
          title,
          description,
          coverColor: coverColor || 'default',
        })
        .returning();

      return c.json({
        success: true,
        data: newNotebook[0]
      }, 201);
    } catch (error) {
      console.error('Error creating notebook:', error);
      return c.json({
        success: false,
        error: 'Failed to create notebook'
      }, 500);
    }
  },

  // Update a notebook
  async updateNotebook(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      const notebookUid = c.req.param('uid');
      const { title, description, coverColor } = await c.req.json();

      const updatedNotebook = await db
        .update(notebooks)
        .set({
          title,
          description,
          coverColor,
          updatedAt: new Date(),
        })
        .where(and(
          eq(notebooks.uid, notebookUid),
          eq(notebooks.userId, userId)
        ))
        .returning();

      if (updatedNotebook.length === 0) {
        return c.json({
          success: false,
          error: 'Notebook not found'
        }, 404);
      }

      return c.json({
        success: true,
        data: updatedNotebook[0]
      });
    } catch (error) {
      console.error('Error updating notebook:', error);
      return c.json({
        success: false,
        error: 'Failed to update notebook'
      }, 500);
    }
  },

  // Delete a notebook
  async deleteNotebook(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      const notebookUid = c.req.param('uid');

      // First find the notebook to get its internal ID
      const notebook = await db
        .select({ id: notebooks.id })
        .from(notebooks)
        .where(and(
          eq(notebooks.uid, notebookUid),
          eq(notebooks.userId, userId)
        ))
        .limit(1);

      if (notebook.length === 0) {
        return c.json({
          success: false,
          error: 'Notebook not found'
        }, 404);
      }

      // Get all problems in this notebook
      const problems = await db
        .select({ id: mathProblems.id })
        .from(mathProblems)
        .where(eq(mathProblems.notebookId, notebook[0].id));

      if (problems.length > 0) {
        const problemIds = problems.map(p => p.id);
        
        // Get all images for all problems in this notebook to delete files
        const allImages: string[] = [];
        for (const problemId of problemIds) {
          const images = await db
            .select()
            .from(problemImages)
            .where(eq(problemImages.problemId, problemId));
          
          allImages.push(...images.map(img => img.filePath));
        }

        // Delete image files from disk
        if (allImages.length > 0) {
          await deleteProblemImages(allImages);
        }

        // Delete all problem images for problems in this notebook
        for (const problemId of problemIds) {
          await db
            .delete(problemImages)
            .where(eq(problemImages.problemId, problemId));
        }

      }

      // Delete all problems in the notebook
      await db
        .delete(mathProblems)
        .where(eq(mathProblems.notebookId, notebook[0].id));

      // Delete the notebook
      await db
        .delete(notebooks)
        .where(and(
          eq(notebooks.uid, notebookUid),
          eq(notebooks.userId, userId)
        ));

      return c.json({
        success: true,
        message: 'Notebook deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting notebook:', error);
      return c.json({
        success: false,
        error: 'Failed to delete notebook'
      }, 500);
    }
  },

  // Create a math problem in a notebook
  async createProblem(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      const notebookUid = c.req.param('uid');
      const { title, description, scribbleData, tags } = await c.req.json();

      // First find the notebook
      const notebook = await db
        .select({ id: notebooks.id })
        .from(notebooks)
        .where(and(
          eq(notebooks.uid, notebookUid),
          eq(notebooks.userId, userId)
        ))
        .limit(1);

      if (notebook.length === 0) {
        return c.json({
          success: false,
          error: 'Notebook not found'
        }, 404);
      }

      const newProblem = await db
        .insert(mathProblems)
        .values({
          uid: randomUUID(),
          notebookId: notebook[0].id,
          userId,
          title,
          description,
          scribbleData,
          tags: tags ? JSON.stringify(tags) : null,
        })
        .returning();

      return c.json({
        success: true,
        data: {
          ...newProblem[0],
          images: [], // Empty images array for new problem
          tags: newProblem[0].tags ? JSON.parse(newProblem[0].tags) : [],
        }
      }, 201);
    } catch (error) {
      console.error('Error creating problem:', error);
      return c.json({
        success: false,
        error: 'Failed to create problem'
      }, 500);
    }
  },

  // Update a math problem
  async updateProblem(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      const problemUid = c.req.param('problemUid');
      const { title, description, scribbleData, status, tags } = await c.req.json();

      const updatedProblem = await db
        .update(mathProblems)
        .set({
          title,
          description,
          scribbleData,
          status,
          tags: tags ? JSON.stringify(tags) : null,
          updatedAt: new Date(),
        })
        .where(and(
          eq(mathProblems.uid, problemUid),
          eq(mathProblems.userId, userId)
        ))
        .returning();

      if (updatedProblem.length === 0) {
        return c.json({
          success: false,
          error: 'Problem not found'
        }, 404);
      }

      // Get updated images for the problem
      const images = await db
        .select()
        .from(problemImages)
        .where(eq(problemImages.problemId, updatedProblem[0].id))
        .orderBy(problemImages.displayOrder);

      return c.json({
        success: true,
        data: {
          ...updatedProblem[0],
          images: images.map(img => ({
            id: img.id,
            uid: img.uid,
            originalFilename: img.originalFilename,
            filename: img.filename,
            fileUrl: img.fileUrl,
            mimeType: img.mimeType,
            fileSize: img.fileSize,
            width: img.width,
            height: img.height,
            displayOrder: img.displayOrder,
            createdAt: img.createdAt,
          })),
          tags: updatedProblem[0].tags ? JSON.parse(updatedProblem[0].tags) : [],
        }
      });
    } catch (error) {
      console.error('Error updating problem:', error);
      return c.json({
        success: false,
        error: 'Failed to update problem'
      }, 500);
    }
  },

  // Delete a math problem
  async deleteProblem(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      const problemUid = c.req.param('problemUid');

      // First find the problem to get its internal ID
      const problem = await db
        .select({ id: mathProblems.id })
        .from(mathProblems)
        .where(and(
          eq(mathProblems.uid, problemUid),
          eq(mathProblems.userId, userId)
        ))
        .limit(1);

      if (problem.length === 0) {
        return c.json({
          success: false,
          error: 'Problem not found'
        }, 404);
      }

      // Get all images for the problem to delete files
      const images = await db
        .select()
        .from(problemImages)
        .where(eq(problemImages.problemId, problem[0].id));

      // Delete image files from disk
      if (images.length > 0) {
        const imagePaths = images.map(img => img.filePath);
        await deleteProblemImages(imagePaths);
      }

      // Delete associated problem images
      await db
        .delete(problemImages)
        .where(eq(problemImages.problemId, problem[0].id));


      // Delete the problem
      await db
        .delete(mathProblems)
        .where(and(
          eq(mathProblems.uid, problemUid),
          eq(mathProblems.userId, userId)
        ));

      return c.json({
        success: true,
        message: 'Problem deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting problem:', error);
      return c.json({
        success: false,
        error: 'Failed to delete problem'
      }, 500);
    }
  },

  // Get AI feedbacks for a problem
  async getProblemFeedbacks(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      const problemUid = c.req.param('problemUid');

      // First find the problem
      const problem = await db
        .select({ id: mathProblems.id })
        .from(mathProblems)
        .where(and(
          eq(mathProblems.uid, problemUid),
          eq(mathProblems.userId, userId)
        ))
        .limit(1);

      if (problem.length === 0) {
        return c.json({
          success: false,
          error: 'Problem not found'
        }, 404);
      }

      // Get AI feedbacks for this problem
      const feedbacks = await db
        .select()
        .from(aiFeedbacks)
        .where(eq(aiFeedbacks.problemId, problem[0].id))
        .orderBy(desc(aiFeedbacks.createdAt));

      return c.json({
        success: true,
        data: feedbacks.map(feedback => ({
          id: feedback.uid,
          message: feedback.feedbackText,
          type: feedback.feedbackType,
          timestamp: feedback.createdAt,
          tokensConsumed: feedback.tokensConsumed
        }))
      });
    } catch (error) {
      console.error('Error fetching problem feedbacks:', error);
      return c.json({
        success: false,
        error: 'Failed to fetch problem feedbacks'
      }, 500);
    }
  },

  // Upload images for a problem
  async uploadProblemImages(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      const uploadedFiles = c.get('uploadedFiles') as any[];
      const { problemId } = await c.req.parseBody() as { problemId?: string };
      
      if (!uploadedFiles || uploadedFiles.length === 0) {
        return c.json({
          success: false,
          error: 'No files uploaded'
        }, 400);
      }

      if (!problemId) {
        return c.json({
          success: false,
          error: 'Problem ID is required'
        }, 400);
      }

      // Verify problem exists and belongs to user
      const problem = await db
        .select({ id: mathProblems.id })
        .from(mathProblems)
        .where(and(
          eq(mathProblems.uid, problemId),
          eq(mathProblems.userId, userId)
        ))
        .limit(1);

      if (problem.length === 0) {
        return c.json({
          success: false,
          error: 'Problem not found'
        }, 404);
      }

      // Get current max display order for this problem
      const maxOrderResult = await db
        .select()
        .from(problemImages)
        .where(eq(problemImages.problemId, problem[0].id))
        .orderBy(desc(problemImages.displayOrder))
        .limit(1);

      let nextDisplayOrder = maxOrderResult.length > 0 ? (maxOrderResult[0].displayOrder || 0) + 1 : 0;

      // Process each uploaded file
      const savedImages: any[] = [];
      const processedImagePaths: string[] = [];
      
      for (const file of uploadedFiles) {
        try {
          const { processedPath, metadata } = await processProblemImage(
            file.buffer,
            file.originalname,
            file.mimetype
          );
          
          processedImagePaths.push(processedPath);
          
          // Generate URL for the processed image
          const baseUrl = new URL(c.req.url).origin;
          const fileName = path.basename(processedPath);
          const imageUrl = `${baseUrl}/api/files/problem-images/${fileName}`;
          
          // Save image record to database
          const imageRecord = await db
            .insert(problemImages)
            .values({
              uid: randomUUID(),
              problemId: problem[0].id,
              userId,
              originalFilename: file.originalname,
              filename: fileName,
              filePath: processedPath,
              fileUrl: imageUrl,
              mimeType: file.mimetype,
              fileSize: file.size,
              width: metadata.width || null,
              height: metadata.height || null,
              displayOrder: nextDisplayOrder++,
            })
            .returning();

          savedImages.push({
            id: imageRecord[0].id,
            uid: imageRecord[0].uid,
            originalFilename: imageRecord[0].originalFilename,
            filename: imageRecord[0].filename,
            fileUrl: imageRecord[0].fileUrl,
            mimeType: imageRecord[0].mimeType,
            fileSize: imageRecord[0].fileSize,
            width: imageRecord[0].width,
            height: imageRecord[0].height,
            displayOrder: imageRecord[0].displayOrder,
            createdAt: imageRecord[0].createdAt,
          });
          
        } catch (error) {
          console.error('Error processing image:', error);
          // Clean up any processed files if one fails
          await deleteProblemImages(processedImagePaths);
          // Also clean up any saved database records
          if (savedImages.length > 0) {
            await db
              .delete(problemImages)
              .where(and(
                eq(problemImages.problemId, problem[0].id),
                eq(problemImages.userId, userId)
              ));
          }
          return c.json({
            success: false,
            error: `Failed to process image: ${file.originalname}`
          }, 500);
        }
      }

      return c.json({
        success: true,
        data: {
          images: savedImages,
          count: savedImages.length
        }
      }, 201);
    } catch (error) {
      console.error('Error uploading problem images:', error);
      return c.json({
        success: false,
        error: 'Failed to upload images'
      }, 500);
    }
  },

  // Generate AI feedback for a problem using canvas image
  // DEPRECATED: Use streamAiFeedback instead for consistent streaming
  async generateAiFeedback(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      const problemUid = c.req.param('problemUid');

      // Get uploaded canvas image from middleware
      const files = c.get('uploadedFiles') as any[];
      
      if (!files || files.length === 0) {
        return c.json({
          success: false,
          error: 'Canvas image is required'
        }, 400);
      }
      
      const canvasImageFile = files[0]; // Get the first (and only) uploaded file
      
      // Extract custom message from form data if provided
      const formData = await c.req.formData();
      const customMessage = formData.get('customMessage') as string || null;
      const sessionId = formData.get('sessionId') as string || undefined;

      // Find the problem
      const problem = await db
        .select()
        .from(mathProblems)
        .where(and(
          eq(mathProblems.uid, problemUid),
          eq(mathProblems.userId, userId)
        ))
        .limit(1);

      if (problem.length === 0) {
        return c.json({
          success: false,
          error: 'Problem not found'
        }, 404);
      }

      // Get the original problem image
      const problemImage = await db
        .select()
        .from(problemImages)
        .where(eq(problemImages.problemId, problem[0].id))
        .limit(1);

      if (problemImage.length === 0) {
        return c.json({
          success: false,
          error: 'Problem image not found'
        }, 404);
      }

      // Process canvas image with intelligent change detection
      const canvasResult = await processCanvasImage(
        canvasImageFile.buffer,
        canvasImageFile.originalname || 'canvas.png',
        {
          userId,
          problemId: problem[0].id.toString(),
          sessionId,
        }
      );

      console.log(`Canvas processing - Changed: ${canvasResult.optimizationResult.hasChanged}, Similarity: ${(canvasResult.optimizationResult.similarity * 100).toFixed(1)}%, Tokens: ${canvasResult.optimizationResult.tokensEstimate}`);

      // Skip AI processing if canvas hasn't changed significantly
      if (!canvasResult.optimizationResult.hasChanged) {
        return c.json({
          success: true,
          data: {
            id: randomUUID(),
            message: '画像に大きな変更が見つかりませんでした。新しい解答を描いてから再度送信してください。',
            type: 'suggestion',
            timestamp: new Date(),
            tokensConsumed: 0,
            imageUnchanged: true,
            similarity: canvasResult.optimizationResult.similarity
          }
        }, 200);
      }

      // Read original problem image from disk
      console.log('Reading original problem image from:', problemImage[0].filePath);
      const originalImageBuffer = fs.readFileSync(problemImage[0].filePath);

      // Get or create chat thread for memory
      const { threadId, resourceId } = await getOrCreateChatThread(problem[0].id, userId);
      
      // Call mathHelper agent with both images and memory
      const mathHelperAgent = mastra.getAgent('mathHelperAgent');
      
      // Create prompt based on custom message or default
      const promptText = customMessage 
        ? `User question: ${customMessage}\n\nPlease analyze the original math problem and the user's handwritten solution, then answer the user's question. Provide educational feedback in Japanese with TeX notation for mathematical expressions.`
        : "Please analyze the original math problem and the user's handwritten solution. Provide educational feedback in Japanese with TeX notation for mathematical expressions.";
      
      const result = await mathHelperAgent.generate([
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text: promptText
            },
            {
             type: 'image',
             mimeType: problemImage[0].mimeType,
             image:new URL(`data:${problemImage[0].mimeType};base64,${originalImageBuffer.toString('base64')}`)
            },
            {
              type: 'image',
              mimeType: 'image/png',
              image: new URL(`data:image/png;base64,${canvasImageFile.buffer.toString('base64')}`)
            }
          ]
        },
     
      ], {
        threadId,
        resourceId,
      });

      // Parse feedback and determine type
      const feedbackText = result.text;
      let feedbackType = 'suggestion'; // default

      // Simple heuristic to determine feedback type
      if (feedbackText.includes('間違い') || feedbackText.includes('エラー') || feedbackText.includes('訂正')) {
        feedbackType = 'correction';
      } else if (feedbackText.includes('説明') || feedbackText.includes('なぜなら') || feedbackText.includes('理由')) {
        feedbackType = 'explanation';
      } else if (feedbackText.includes('頑張って') || feedbackText.includes('良い') || feedbackText.includes('素晴らしい')) {
        feedbackType = 'encouragement';
      }

      // Use dynamic token cost based on optimization result
      const tokensConsumed = canvasResult.optimizationResult.tokensEstimate + 50; // Base cost + image processing cost

      // Save feedback to database
      const feedbackRecord = await db
        .insert(aiFeedbacks)
        .values({
          uid: randomUUID(),
          problemId: problem[0].id,
          userId,
          feedbackText,
          feedbackType,
          tokensConsumed,
        })
        .returning();

      // Update user token usage
      await db
        .update(users)
        .set({
          usedTokens: sql`${users.usedTokens} + ${tokensConsumed}`,
          remainingTokens: sql`${users.remainingTokens} - ${tokensConsumed}`,
        })
        .where(eq(users.uid, userId));

      return c.json({
        success: true,
        data: {
          id: feedbackRecord[0].uid,
          message: feedbackRecord[0].feedbackText,
          type: feedbackRecord[0].feedbackType,
          timestamp: feedbackRecord[0].createdAt,
          tokensConsumed: feedbackRecord[0].tokensConsumed,
          imageOptimization: {
            quality: canvasResult.optimizationResult.quality,
            compressionRatio: canvasResult.optimizationResult.compressionRatio,
            fromCache: canvasResult.optimizationResult.fromCache,
          }
        }
      }, 201);

    } catch (error) {
      console.error('Error generating AI feedback:', error);
      return c.json({
        success: false,
        error: 'Failed to generate AI feedback'
      }, 500);
    }
  },

  // Stream AI feedback generation in real-time
  async streamAiFeedback(c: Context) {
    console.log('=== STREAMING ENDPOINT HIT ===');
    try {
      const user = c.get('user');
      const userId = user?.uid;
      const problemUid = c.req.param('problemUid');

      console.log('Streaming request - User:', user, 'UserId:', userId, 'ProblemUid:', problemUid);

      if (!userId) {
        console.log('Missing userId - user object:', user);
        return c.json({
          success: false,
          error: 'Authentication failed - no user ID'
        }, 400);
      }
      
      if (!problemUid) {
        console.log('Missing problemUid from params');
        return c.json({
          success: false,
          error: 'Missing problem ID parameter'
        }, 400);
      }

      // Set up Server-Sent Events headers
      c.header('Content-Type', 'text/event-stream');
      c.header('Cache-Control', 'no-cache');
      c.header('Connection', 'keep-alive');
      c.header('Access-Control-Allow-Origin', '*');
      c.header('Access-Control-Allow-Headers', 'Content-Type');

      // Get uploaded canvas image from middleware  
      const files = c.get('uploadedFiles') as any[];
      
      console.log('Files from middleware:', files?.length || 0);
      
      // Extract custom message from form data if provided
      const formData = await c.req.formData();
      const customMessage = formData.get('customMessage') as string || null;
      const sessionId = formData.get('sessionId') as string || undefined;
      console.log('Custom message received:', customMessage);
      
      // Handle text-only conversations without canvas images
      const hasCanvasImage = files && files.length > 0;
      const isTextOnlyMessage = !hasCanvasImage && customMessage;
      
      if (!hasCanvasImage && !customMessage) {
        const errorData = JSON.stringify({
          success: false,
          error: 'Either canvas image or custom message is required'
        });
        return new Response(`data: ${errorData}\n\n`, {
          headers: {
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            'Access-Control-Allow-Origin': '*',
          }
        });
      }

      // Get problem and original image
      const problem = await db
        .select()
        .from(mathProblems)
        .where(eq(mathProblems.uid, problemUid))
        .limit(1);

      if (problem.length === 0) {
        const errorData = JSON.stringify({
          success: false,
          error: 'Problem not found'
        });
        return new Response(`data: ${errorData}\n\n`, {
          headers: {
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            'Access-Control-Allow-Origin': '*',
          }
        });
      }

      const problemImage = await db
        .select()
        .from(problemImages)
        .where(eq(problemImages.problemId, problem[0].id))
        .limit(1);

      if (problemImage.length === 0) {
        const errorData = JSON.stringify({
          success: false,
          error: 'Problem image not found'
        });
        return new Response(`data: ${errorData}\n\n`, {
          headers: {
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            'Access-Control-Allow-Origin': '*',
          }
        });
      }

      // Handle canvas processing for both image and text-only messages
      let canvasImageFile = null;
      let canvasResult = null;
      let originalImageBuffer = null;

      if (hasCanvasImage) {
        canvasImageFile = files[0]; // Get the first (and only) uploaded file

        // Process canvas image with intelligent change detection
        canvasResult = await processCanvasImage(
          canvasImageFile.buffer,
          canvasImageFile.originalname || 'canvas.png',
          {
            userId,
            problemId: problem[0].id.toString(),
            sessionId,
          }
        );

        console.log(`Streaming canvas processing - Changed: ${canvasResult.optimizationResult.hasChanged}, Similarity: ${(canvasResult.optimizationResult.similarity * 100).toFixed(1)}%, Tokens: ${canvasResult.optimizationResult.tokensEstimate}`);

        // Get original image buffer
        originalImageBuffer = fs.readFileSync(problemImage[0].filePath);
      } else {
        // For text-only messages, create a minimal optimization result
        canvasResult = {
          optimizationResult: {
            hasChanged: true, // Always process text-only messages
            similarity: 0,
            tokensEstimate: 50, // Base tokens for text processing
            quality: 'text-only',
            compressionRatio: 1,
            fromCache: false,
          }
        };
        
        console.log('Text-only message - proceeding without canvas image');
        
        // Still get original problem image for context if available
        if (problemImage.length > 0) {
          originalImageBuffer = fs.readFileSync(problemImage[0].filePath);
        }
      }

      // Create a readable stream for SSE
      const encoder = new TextEncoder();
      let feedbackId: string;
      let fullFeedbackText = '';
      let tokenCount = 0;

      const stream = new ReadableStream({
        async start(controller) {
          try {
            // Check if canvas image has changed significantly
            // For text-only messages with custom prompts, proceed even if canvas hasn't changed
            if (!canvasResult.optimizationResult.hasChanged && !customMessage) {
              // Send immediate response for unchanged image (only when no custom message)
              const unchangedData = JSON.stringify({
                type: 'complete',
                id: randomUUID(),
                message: '画像に大きな変更が見つかりませんでした。新しい解答を描いてから再度送信してください。',
                feedbackType: 'suggestion',
                timestamp: new Date(),
                tokensConsumed: 0,
                imageUnchanged: true,
                similarity: canvasResult.optimizationResult.similarity
              });
              controller.enqueue(encoder.encode(`data: ${unchangedData}\n\n`));
              controller.close();
              return;
            }

            // Send initial status
            const startData = JSON.stringify({
              type: 'start',
              message: 'AI分析を開始しています...'
            });
            controller.enqueue(encoder.encode(`data: ${startData}\n\n`));

            // Get or create chat thread for memory
            const { threadId, resourceId } = await getOrCreateChatThread(problem[0].id, userId);
            
            // Call mathHelper agent with real streaming and memory
            const mathHelperAgent = mastra.getAgent('mathHelperAgent');
            
            // Generate unique feedback ID
            feedbackId = randomUUID();
            
            // Create prompt based on message type and content
            let promptText;
            let messageContent = [];
            
            if (isTextOnlyMessage) {
              // For text-only messages, adapt the prompt
              promptText = `User question: ${customMessage}\n\nPlease answer the user's question about the math problem. Use your conversation memory to reference previous discussions. Provide helpful educational guidance in Japanese with TeX notation for mathematical expressions.`;
              
              messageContent.push({
                type: 'text',
                text: promptText
              });
              
              // Include original problem image for context if available
              if (originalImageBuffer && problemImage.length > 0) {
                messageContent.push({
                  type: 'image',
                  mimeType: problemImage[0].mimeType,
                  image: new URL(`data:${problemImage[0].mimeType};base64,${originalImageBuffer.toString('base64')}`)
                });
              }
            } else {
              // For canvas-based messages
              promptText = customMessage 
                ? `User question: ${customMessage}\n\nPlease analyze the original math problem and the user's handwritten solution, then answer the user's question. Provide educational feedback in Japanese with TeX notation for mathematical expressions.`
                : "Please analyze the original math problem and the user's handwritten solution. Provide educational feedback in Japanese with TeX notation for mathematical expressions.";
              
              messageContent = [
                {
                  type: 'text',
                  text: promptText
                },
                {
                  type: 'image',
                  mimeType: problemImage[0].mimeType,
                  image: new URL(`data:${problemImage[0].mimeType};base64,${originalImageBuffer.toString('base64')}`)
                },
                {
                  type: 'image',
                  mimeType: 'image/png',
                  image: new URL(`data:image/png;base64,${canvasImageFile.buffer.toString('base64')}`)
                }
              ];
            }
            
            // Use real streaming from Mastra
            const streamResult = await mathHelperAgent.stream([
              {
                role: 'user',
                content: messageContent
              }
            ], {
              threadId,
              resourceId,
            });

            // Process real-time streaming chunks
            let streamedText = '';
            
            try {
              // Process the streaming result with better error handling
              let hasReceivedData = false;
              
              for await (const chunk of streamResult.textStream) {
                if (chunk) {
                  hasReceivedData = true;
                  streamedText += chunk;
                  
                  const chunkData = JSON.stringify({
                    type: 'chunk',
                    chunk: chunk,
                    fullText: streamedText,
                    id: feedbackId
                  });
                  controller.enqueue(encoder.encode(`data: ${chunkData}\n\n`));
                }
              }
              
              // Ensure we have some content
              if (!hasReceivedData) {
                const finalResult = await streamResult.text;
                if (finalResult) {
                  streamedText = finalResult;
                  const chunkData = JSON.stringify({
                    type: 'chunk',
                    chunk: finalResult,
                    fullText: streamedText,
                    id: feedbackId
                  });
                  controller.enqueue(encoder.encode(`data: ${chunkData}\n\n`));
                } else {
                  throw new Error('No response received from AI model');
                }
              }
            } catch (streamError) {
              console.error('Streaming error:', streamError);
              
              // Send error message to frontend
              const errorData = JSON.stringify({
                type: 'error',
                error: 'AI model streaming failed',
                details: streamError instanceof Error ? streamError.message : 'Unknown error'
              });
              controller.enqueue(encoder.encode(`data: ${errorData}\n\n`));
              
              // Don't continue processing if streaming fails
              controller.close();
              return;
            }
            
            fullFeedbackText = streamedText;
            tokenCount = Math.ceil(fullFeedbackText.length / 4); // Rough token estimation

            // Determine feedback type from full text
            let feedbackType = 'suggestion';
            if (fullFeedbackText.includes('間違い') || fullFeedbackText.includes('エラー') || fullFeedbackText.includes('訂正')) {
              feedbackType = 'correction';
            } else if (fullFeedbackText.includes('説明') || fullFeedbackText.includes('なぜなら') || fullFeedbackText.includes('理由')) {
              feedbackType = 'explanation';
            } else if (fullFeedbackText.includes('頑張って') || fullFeedbackText.includes('良い') || fullFeedbackText.includes('素晴らしい')) {
              feedbackType = 'encouragement';
            }

            // Save feedback to database
            await db
              .insert(aiFeedbacks)
              .values({
                uid: feedbackId,
                problemId: problem[0].id,
                userId,
                feedbackText: fullFeedbackText,
                feedbackType,
                tokensConsumed: Math.max(tokenCount, 25), // Ensure minimum token count
              });

            // Calculate dynamic token cost based on optimization result
            const imageTokens = canvasResult.optimizationResult.tokensEstimate;
            const totalTokensUsed = Math.max(tokenCount + imageTokens, 25); // Ensure minimum token count
            
            // Update the feedback record with actual token usage
            await db
              .update(aiFeedbacks)
              .set({
                tokensConsumed: totalTokensUsed,
              })
              .where(eq(aiFeedbacks.uid, feedbackId));

            // Update user token usage
            await db
              .update(users)
              .set({
                usedTokens: sql`${users.usedTokens} + ${totalTokensUsed}`,
                remainingTokens: sql`${users.remainingTokens} - ${totalTokensUsed}`,
              })
              .where(eq(users.uid, userId));

            // Send completion message
            const completeData = JSON.stringify({
              type: 'complete',
              id: feedbackId,
              message: fullFeedbackText,
              feedbackType: feedbackType,
              timestamp: new Date(),
              tokensConsumed: totalTokensUsed,
              imageOptimization: {
                quality: canvasResult.optimizationResult.quality,
                compressionRatio: canvasResult.optimizationResult.compressionRatio,
                fromCache: canvasResult.optimizationResult.fromCache,
              }
            });
            controller.enqueue(encoder.encode(`data: ${completeData}\n\n`));

          } catch (error) {
            console.error('Error in streaming AI feedback:', error);
            const errorData = JSON.stringify({
              type: 'error',
              error: 'Failed to generate AI feedback',
              details: error instanceof Error ? error.message : 'Unknown error'
            });
            controller.enqueue(encoder.encode(`data: ${errorData}\n\n`));
          } finally {
            controller.close();
          }
        }
      });

      return new Response(stream, {
        headers: {
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'Connection': 'keep-alive',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        }
      });

    } catch (error) {
      console.error('Error setting up streaming AI feedback:', error);
      return c.json({
        success: false,
        error: 'Failed to set up streaming'
      }, 500);
    }
  },

  // Get chat history for a problem
  async getChatHistory(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      const problemUid = c.req.param('problemUid');

      // Find the problem
      const problem = await db
        .select()
        .from(mathProblems)
        .where(and(
          eq(mathProblems.uid, problemUid),
          eq(mathProblems.userId, userId)
        ))
        .limit(1);

      if (problem.length === 0) {
        return c.json({
          success: false,
          error: 'Problem not found'
        }, 404);
      }

      // Get or create chat thread
      const { threadId, resourceId } = await getOrCreateChatThread(problem[0].id, userId);

      // Get chat history from Mastra memory
      const mathHelperAgent = mastra.getAgent('mathHelperAgent');
      const memory = mathHelperAgent.getMemory();

      if (!memory) {
        return c.json({
          success: true,
          data: {
            threadId,
            resourceId,
            messages: []
          }
        });
      }

      try {
        // Query memory for conversation history
        const { uiMessages } = await memory.query({
          threadId,
          resourceId,
          selectBy: {
            last: 50, // Get last 50 messages
          },
        });

        // Convert messages to frontend format
        const chatMessages = uiMessages.map(msg => ({
          id: msg.id || `${msg.role}-${Date.now()}`,
          message: msg.content,
          timestamp: msg.createdAt || new Date(),
          sender: msg.role === 'user' ? 'user' : 'ai',
          feedbackType: msg.role === 'assistant' ? 'suggestion' : undefined,
        }));

        return c.json({
          success: true,
          data: {
            threadId,
            resourceId,
            messages: chatMessages
          }
        });
      } catch (memoryError) {
        console.log('Memory query failed (probably no messages yet):', memoryError);
        // Return empty messages if memory query fails (e.g., no conversation history yet)
        return c.json({
          success: true,
          data: {
            threadId,
            resourceId,
            messages: []
          }
        });
      }
    } catch (error) {
      console.error('Error fetching chat history:', error);
      return c.json({
        success: false,
        error: 'Failed to fetch chat history'
      }, 500);
    }
  },

  // Send text-only chat message (without canvas)
  // DEPRECATED: All chat now uses streamAiFeedback for consistent streaming
  async sendChatMessage(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      const problemUid = c.req.param('problemUid');
      const { message, includeImages = false } = await c.req.json();

      if (!message || typeof message !== 'string' || message.trim().length === 0) {
        return c.json({
          success: false,
          error: 'Message is required'
        }, 400);
      }

      // Find the problem
      const problem = await db
        .select()
        .from(mathProblems)
        .where(and(
          eq(mathProblems.uid, problemUid),
          eq(mathProblems.userId, userId)
        ))
        .limit(1);

      if (problem.length === 0) {
        return c.json({
          success: false,
          error: 'Problem not found'
        }, 404);
      }

      // Get or create chat thread
      const { threadId, resourceId } = await getOrCreateChatThread(problem[0].id, userId);

      // Get mathHelper agent
      const mathHelperAgent = mastra.getAgent('mathHelperAgent');
      
      // Check if this is the first interaction in the thread
      const memory = mathHelperAgent.getMemory();
      let isFirstInteraction = false;
      
      if (memory) {
        try {
          const { messages } = await memory.query({
            threadId,
            resourceId,
            selectBy: { last: 1 }
          });
          isFirstInteraction = messages.length === 0;
        } catch (error) {
          // If memory query fails, assume first interaction
          isFirstInteraction = true;
        }
      }

      let messageContent: any[] = [
        {
          type: 'text',
          text: message
        }
      ];

      // Include problem image only on first interaction or when explicitly requested
      if (isFirstInteraction || includeImages) {
        try {
          // Get the original problem image
          const problemImage = await db
            .select()
            .from(problemImages)
            .where(eq(problemImages.problemId, problem[0].id))
            .limit(1);

          if (problemImage.length > 0) {
            const originalImageBuffer = fs.readFileSync(problemImage[0].filePath);
            
            messageContent.push({
              type: 'image',
              mimeType: problemImage[0].mimeType,
              image: new URL(`data:${problemImage[0].mimeType};base64,${originalImageBuffer.toString('base64')}`)
            });

            // Add context to the message for first interaction
            if (isFirstInteraction) {
              messageContent[0].text = `This is the math problem I'm working on. ${message}`;
            }
          }
        } catch (imageError) {
          console.error('Error loading problem image:', imageError);
          // Continue without image if there's an error
        }
      }

      const result = await mathHelperAgent.generate([
        {
          role: 'user',
          content: messageContent
        }
      ], {
        threadId,
        resourceId,
      });

      // Parse response and determine type
      const responseText = result.text;
      let feedbackType = 'suggestion';

      if (responseText.includes('間違い') || responseText.includes('エラー') || responseText.includes('訂正')) {
        feedbackType = 'correction';
      } else if (responseText.includes('説明') || responseText.includes('なぜなら') || responseText.includes('理由')) {
        feedbackType = 'explanation';
      } else if (responseText.includes('頑張って') || responseText.includes('良い') || responseText.includes('素晴らしい')) {
        feedbackType = 'encouragement';
      }

      // Calculate tokens consumed based on whether images were included
      const baseTokens = Math.ceil(responseText.length / 4);
      const imageTokens = (isFirstInteraction || includeImages) ? 200 : 0; // Rough estimate for image tokens
      const tokensConsumed = Math.max(baseTokens + imageTokens, 10);

      // Update user token usage
      await db
        .update(users)
        .set({
          usedTokens: sql`${users.usedTokens} + ${tokensConsumed}`,
          remainingTokens: sql`${users.remainingTokens} - ${tokensConsumed}`,
        })
        .where(eq(users.uid, userId));

      return c.json({
        success: true,
        data: {
          id: randomUUID(),
          message: responseText,
          type: feedbackType,
          timestamp: new Date(),
          tokensConsumed,
          includedImages: isFirstInteraction || includeImages
        }
      }, 201);

    } catch (error) {
      console.error('Error sending chat message:', error);
      return c.json({
        success: false,
        error: 'Failed to send message'
      }, 500);
    }
  },
};