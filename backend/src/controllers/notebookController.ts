import type { Context } from 'hono';
import { db } from '../db/client.js';
import { notebooks, mathProblems, aiFeedbacks, users } from '../db/schema.js';
import { eq, and, desc } from 'drizzle-orm';
import { randomUUID } from 'crypto';

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
  // Get all notebooks for a user
  async getNotebooks(c: Context) {
    try {
      const user = c.get('user');
      const userId = user.uid;
      
      const userNotebooks = await db
        .select()
        .from(notebooks)
        .where(eq(notebooks.userId, userId))
        .orderBy(desc(notebooks.updatedAt));

      return c.json({
        success: true,
        data: userNotebooks
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

      return c.json({
        success: true,
        data: {
          ...notebook[0],
          problems: problems.map(problem => ({
            ...problem,
            imagePaths: problem.imagePaths ? JSON.parse(problem.imagePaths) : [],
            tags: problem.tags ? JSON.parse(problem.tags) : [],
          }))
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

      // Delete associated AI feedbacks for all problems in this notebook
      const problemIds = await db
        .select({ id: mathProblems.id })
        .from(mathProblems)
        .where(eq(mathProblems.notebookId, notebook[0].id));

      if (problemIds.length > 0) {
        await db
          .delete(aiFeedbacks)
          .where(eq(aiFeedbacks.problemId, problemIds[0].id));
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
      const { title, description, imagePaths, scribbleData, tags } = await c.req.json();

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
          imagePaths: imagePaths ? JSON.stringify(imagePaths) : null,
          scribbleData,
          tags: tags ? JSON.stringify(tags) : null,
        })
        .returning();

      return c.json({
        success: true,
        data: {
          ...newProblem[0],
          imagePaths: newProblem[0].imagePaths ? JSON.parse(newProblem[0].imagePaths) : [],
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
      const { title, description, imagePaths, scribbleData, status, tags } = await c.req.json();

      const updatedProblem = await db
        .update(mathProblems)
        .set({
          title,
          description,
          imagePaths: imagePaths ? JSON.stringify(imagePaths) : null,
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

      return c.json({
        success: true,
        data: {
          ...updatedProblem[0],
          imagePaths: updatedProblem[0].imagePaths ? JSON.parse(updatedProblem[0].imagePaths) : [],
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

      // Delete associated AI feedbacks
      await db
        .delete(aiFeedbacks)
        .where(eq(aiFeedbacks.problemId, problem[0].id));

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

      const feedbacks = await db
        .select()
        .from(aiFeedbacks)
        .where(eq(aiFeedbacks.problemId, problem[0].id))
        .orderBy(desc(aiFeedbacks.createdAt));

      return c.json({
        success: true,
        data: feedbacks
      });
    } catch (error) {
      console.error('Error fetching problem feedbacks:', error);
      return c.json({
        success: false,
        error: 'Failed to fetch problem feedbacks'
      }, 500);
    }
  },
};