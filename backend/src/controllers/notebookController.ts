import type { Context } from 'hono';
import { db } from '../db/client.js';
import { notebooks, mathProblems, users, problemImages, aiFeedbacks } from '../db/schema.js';
import { eq, and, desc, sql } from 'drizzle-orm';
import { randomUUID } from 'crypto';
import { processProblemImage, deleteProblemImages } from '../middleware/fileUploadMiddleware.js';
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

      // Get canvas image buffer from uploaded file
      const canvasImageBuffer = canvasImageFile.buffer;

      // Read original problem image from disk

      console.log('Reading original problem image from:', problemImage[0].filePath);
      const originalImageBuffer = fs.readFileSync(problemImage[0].filePath);

      // Call mathHelper agent with both images
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
              image: new URL(`data:image/png;base64,${canvasImageBuffer.toString('base64')}`)
            }
          ]
        },
     
      ]);

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

      // Save feedback to database
      const feedbackRecord = await db
        .insert(aiFeedbacks)
        .values({
          uid: randomUUID(),
          problemId: problem[0].id,
          userId,
          feedbackText,
          feedbackType,
          tokensConsumed: 75, // Default token cost
        })
        .returning();

      // Update user token usage
      await db
        .update(users)
        .set({
          usedTokens: sql`${users.usedTokens} + 75`,
          remainingTokens: sql`${users.remainingTokens} - 75`,
        })
        .where(eq(users.uid, userId));

      return c.json({
        success: true,
        data: {
          id: feedbackRecord[0].uid,
          message: feedbackRecord[0].feedbackText,
          type: feedbackRecord[0].feedbackType,
          timestamp: feedbackRecord[0].createdAt,
          tokensConsumed: feedbackRecord[0].tokensConsumed
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
      console.log('Custom message received:', customMessage);
      
      if (!files || files.length === 0) {
        const errorData = JSON.stringify({
          success: false,
          error: 'Canvas image is required'
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

      const canvasImageFile = files[0]; // Get the first (and only) uploaded file

      // Get canvas and original image buffers
      const canvasImageBuffer = canvasImageFile.buffer;
      const originalImageBuffer = fs.readFileSync(problemImage[0].filePath);

      // Create a readable stream for SSE
      const encoder = new TextEncoder();
      let feedbackId: string;
      let fullFeedbackText = '';
      let tokenCount = 0;

      const stream = new ReadableStream({
        async start(controller) {
          try {
            // Send initial status
            const startData = JSON.stringify({
              type: 'start',
              message: 'AI分析を開始しています...'
            });
            controller.enqueue(encoder.encode(`data: ${startData}\n\n`));

            // Call mathHelper agent with streaming
            const mathHelperAgent = mastra.getAgent('mathHelperAgent');
            
            // Generate unique feedback ID
            feedbackId = randomUUID();
            
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
                    image: new URL(`data:${problemImage[0].mimeType};base64,${originalImageBuffer.toString('base64')}`)
                  },
                  {
                    type: 'image',
                    mimeType: 'image/png',
                    image: new URL(`data:image/png;base64,${canvasImageBuffer.toString('base64')}`)
                  }
                ]
              }
            ]);

            // Get the full response and simulate streaming by chunking
            fullFeedbackText = result.text;
            tokenCount = Math.ceil(fullFeedbackText.length / 4); // Rough token estimation
            
            // Simulate streaming by breaking response into chunks
            const words = fullFeedbackText.split(' ');
            let currentText = '';
            
            for (let i = 0; i < words.length; i++) {
              currentText += (i > 0 ? ' ' : '') + words[i];
              
              // Send chunk every few words to simulate streaming
              if (i % 3 === 0 || i === words.length - 1) {
                const chunkData = JSON.stringify({
                  type: 'chunk',
                  chunk: words[i],
                  fullText: currentText,
                  id: feedbackId
                });
                controller.enqueue(encoder.encode(`data: ${chunkData}\n\n`));
                
                // Small delay to simulate real streaming
                await new Promise(resolve => setTimeout(resolve, 100));
              }
            }

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
            const feedbackRecord = await db
              .insert(aiFeedbacks)
              .values({
                uid: feedbackId,
                problemId: problem[0].id,
                userId,
                feedbackText: fullFeedbackText,
                feedbackType,
                tokensConsumed: Math.max(tokenCount, 25), // Ensure minimum token count
              })
              .returning();

            // Update user token usage
            const tokensUsed = feedbackRecord[0].tokensConsumed;
            await db
              .update(users)
              .set({
                usedTokens: sql`${users.usedTokens} + ${tokensUsed}`,
                remainingTokens: sql`${users.remainingTokens} - ${tokensUsed}`,
              })
              .where(eq(users.uid, userId));

            // Send completion message
            const completeData = JSON.stringify({
              type: 'complete',
              id: feedbackRecord[0].uid,
              message: feedbackRecord[0].feedbackText,
              feedbackType: feedbackRecord[0].feedbackType,
              timestamp: feedbackRecord[0].createdAt,
              tokensConsumed: feedbackRecord[0].tokensConsumed
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
};