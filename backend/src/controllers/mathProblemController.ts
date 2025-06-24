import { db } from '../db/client.js';
import { mathProblems } from '../db/schema.js';
import { eq, and } from 'drizzle-orm';
import type { Context } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { refundTokens } from '../middleware/tokenMiddleware.js';
import { mastraAIService } from '../services/mastraAIService.js';

// Get all math problems for a user
export const getUserMathProblems = async (c: Context) => {
  try {
    const user = c.get('user');
    const problems = await db.select().from(mathProblems).where(eq(mathProblems.userId, user.uid));
    return c.json({ success: true, problems });
  } catch (error) {
    console.error('Error fetching user math problems:', error);
    return c.json({ success: false, error: 'Failed to fetch math problems' }, 500);
  }
};

// Get a specific math problem
export const getMathProblem = async (c: Context) => {
  try {
    const id = parseInt(c.req.param('id'));
    const user = c.get('user');
    
    const problem = await db.select()
      .from(mathProblems)
      .where(
        and(
          eq(mathProblems.id, id),
          eq(mathProblems.userId, user.uid)
        )
      );
    
    if (!problem.length) {
      return c.json({ success: false, error: 'Problem not found' }, 404);
    }
    
    return c.json({ success: true, problem: problem[0] });
  } catch (error) {
    console.error('Error fetching math problem:', error);
    return c.json({ success: false, error: 'Failed to fetch math problem' }, 500);
  }
};

// Create a new math problem
export const createMathProblem = async (c: Context) => {
  try {
    const user = c.get('user');
    const { problem, solution } = await c.req.json();
    
    if (!problem) {
      return c.json({ success: false, error: 'Problem content is required' }, 400);
    }
    
    const result = await db.insert(mathProblems).values({
      userId: user.uid,
      problem,
      solution: solution || null,
    }).returning();
    
    return c.json({ success: true, problem: result[0] }, 201);
  } catch (error) {
    console.error('Error creating math problem:', error);
    return c.json({ success: false, error: 'Failed to create math problem' }, 500);
  }
};

// Update a math problem
export const updateMathProblem = async (c: Context) => {
  try {
    const id = parseInt(c.req.param('id'));
    const user = c.get('user');
    const { problem, solution } = await c.req.json();
    
    const existingProblem = await db.select()
      .from(mathProblems)
      .where(eq(mathProblems.id, id));
    
    if (!existingProblem.length) {
      return c.json({ success: false, error: 'Problem not found' }, 404);
    }
    
    const updatedProblem = await db.update(mathProblems)
      .set({
        problem: problem || existingProblem[0].problem,
        solution: solution || existingProblem[0].solution,
        updatedAt: new Date(),
      })
      .where(eq(mathProblems.id, id))
      .returning();
    
    return c.json({ success: true, problem: updatedProblem[0] });
  } catch (error) {
    console.error('Error updating math problem:', error);
    return c.json({ success: false, error: 'Failed to update math problem' }, 500);
  }
};

// Delete a math problem
export const deleteMathProblem = async (c: Context) => {
  try {
    const id = parseInt(c.req.param('id'));
    const user = c.get('user');
    
    const existingProblem = await db.select()
      .from(mathProblems)
      .where(
        and(
          eq(mathProblems.id, id),
          eq(mathProblems.userId, user.uid)
        )
      );
    
    if (!existingProblem.length) {
      return c.json({ success: false, error: 'Problem not found' }, 404);
    }
    
    await db.delete(mathProblems)
      .where(eq(mathProblems.id, id));
    
    return c.json({ success: true, message: 'Problem deleted successfully' });
  } catch (error) {
    console.error('Error deleting math problem:', error);
    return c.json({ success: false, error: 'Failed to delete math problem' }, 500);
  }
};

// AI-powered problem solving using Mastra
export const solveMathProblemAI = async (c: Context) => {
  try {
    const user = c.get('user');
    const tokenInfo = c.get('tokenInfo');
    const { problem, difficulty = 'medium', showSteps = true } = await c.req.json();
    
    if (!problem) {
      throw new HTTPException(400, { message: 'Problem content is required' });
    }

    let solution = '';
    let tokensUsed = tokenInfo?.consumed || 15; // Default if not set by middleware

    try {
      // Use Mastra AI service to solve the problem
      solution = await mastraAIService.solveMathProblem({
        problem,
        difficulty,
        showSteps,
      });

    } catch (aiError) {
      console.error('AI solving error:', aiError);
      // Refund tokens if AI request failed
      await refundTokens(user.uid, tokensUsed);
      throw new HTTPException(500, { message: 'AI service temporarily unavailable' });
    }

    // Save the problem and solution to database
    const result = await db.insert(mathProblems).values({
      userId: user.uid,
      problem,
      solution,
      tokensUsed,
    }).returning();

    return c.json({
      success: true,
      data: {
        problem: result[0],
        tokensUsed,
        remainingTokens: tokenInfo?.remaining || 0,
      },
    });

  } catch (error) {
    console.error('Solve math problem error:', error);
    if (error instanceof HTTPException) {
      throw error;
    }
    throw new HTTPException(500, { message: 'Failed to solve math problem' });
  }
};

// AI-powered problem explanation
export const explainMathConcept = async (c: Context) => {
  try {
    const user = c.get('user');
    const tokenInfo = c.get('tokenInfo');
    const { concept, gradeLevel, examples = true } = await c.req.json();
    
    if (!concept) {
      throw new HTTPException(400, { message: 'Math concept is required' });
    }

    let explanation = '';
    let tokensUsed = tokenInfo?.consumed || 20;

    try {
      // Use Mastra AI service to explain the concept
      explanation = await mastraAIService.explainConcept({
        concept,
        gradeLevel,
        includeExamples: examples,
      });

    } catch (aiError) {
      console.error('AI explanation error:', aiError);
      await refundTokens(user.uid, tokensUsed);
      throw new HTTPException(500, { message: 'AI service temporarily unavailable' });
    }

    return c.json({
      success: true,
      data: {
        concept,
        explanation,
        tokensUsed,
        remainingTokens: tokenInfo?.remaining || 0,
      },
    });

  } catch (error) {
    console.error('Explain math concept error:', error);
    if (error instanceof HTTPException) {
      throw error;
    }
    throw new HTTPException(500, { message: 'Failed to explain math concept' });
  }
};

// AI-powered practice problem generation
export const generatePracticeProblems = async (c: Context) => {
  try {
    const user = c.get('user');
    const tokenInfo = c.get('tokenInfo');
    const { topic, difficulty = 'medium', count = 5, gradeLevel } = await c.req.json();
    
    if (!topic) {
      throw new HTTPException(400, { message: 'Topic is required' });
    }

    let problems = [];
    let tokensUsed = tokenInfo?.consumed || 25;

    try {
      // Use Mastra AI service to generate practice problems
      problems = await mastraAIService.generatePracticeProblems({
        topic,
        difficulty,
        count,
        gradeLevel,
      });

    } catch (aiError) {
      console.error('AI generation error:', aiError);
      await refundTokens(user.uid, tokensUsed);
      throw new HTTPException(500, { message: 'AI service temporarily unavailable' });
    }

    return c.json({
      success: true,
      data: {
        topic,
        difficulty,
        problems,
        tokensUsed,
        remainingTokens: tokenInfo?.remaining || 0,
      },
    });

  } catch (error) {
    console.error('Generate practice problems error:', error);
    if (error instanceof HTTPException) {
      throw error;
    }
    throw new HTTPException(500, { message: 'Failed to generate practice problems' });
  }
};
