import type { Context, Next } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { db } from '../db/client.js';
import { users, apiUsage } from '../db/schema.js';
import { eq, sql } from 'drizzle-orm';

export interface TokenConfig {
  requiredTokens: number;
  endpoint: string;
}

// Default token costs for different operations
export const TOKEN_COSTS = {
  BASIC_AI_QUERY: 10,
  COMPLEX_AI_QUERY: 25,
  IMAGE_GENERATION: 50,
  PROBLEM_SOLVING: 15,
  EXPLANATION: 20,
} as const;

// Middleware to check and consume tokens
export const tokenMiddleware = (config: TokenConfig) => {
  return async (c: Context, next: Next) => {
    try {
      const user = c.get('user');
      if (!user) {
        throw new HTTPException(401, { message: 'Authentication required' });
      }

      const userId = user.uid;
      const { requiredTokens, endpoint } = config;

      // Get current user token status
      const [currentUser] = await db
        .select({
          id: users.id,
          totalTokens: users.totalTokens,
          usedTokens: users.usedTokens,
          remainingTokens: users.remainingTokens,
          tokenResetDate: users.tokenResetDate,
          isActive: users.isActive,
        })
        .from(users)
        .where(eq(users.uid, userId))
        .limit(1);

      if (!currentUser) {
        throw new HTTPException(404, { message: 'User not found' });
      }

      if (!currentUser.isActive) {
        throw new HTTPException(403, { message: 'Account is deactivated' });
      }

      // Check if tokens need to be reset (monthly reset)
      const now = new Date();
      const resetDate = currentUser.tokenResetDate;
      
      if (!resetDate || now > resetDate) {
        // Reset tokens (monthly)
        const nextResetDate = new Date(now);
        nextResetDate.setMonth(nextResetDate.getMonth() + 1);
        
        await db
          .update(users)
          .set({
            usedTokens: 0,
            remainingTokens: currentUser.totalTokens || 1000,
            tokenResetDate: nextResetDate,
            updatedAt: now,
          })
          .where(eq(users.uid, userId));

        // Update current user data for this request
        currentUser.usedTokens = 0;
        currentUser.remainingTokens = currentUser.totalTokens || 1000;
      }

      // Check if user has enough tokens
      if ((currentUser.remainingTokens || 0) < requiredTokens) {
        // Log the rate limit event
        await db.insert(apiUsage).values({
          userId,
          endpoint,
          tokensConsumed: 0,
          status: 'rate_limited',
          requestData: JSON.stringify({ requiredTokens, available: currentUser.remainingTokens }),
          createdAt: now,
        });

        throw new HTTPException(429, { 
          message: `Insufficient tokens. Required: ${requiredTokens}, Available: ${currentUser.remainingTokens || 0}` 
        });
      }

      // Reserve tokens (pre-deduct them)
      const newUsedTokens = (currentUser.usedTokens || 0) + requiredTokens;
      const newRemainingTokens = (currentUser.remainingTokens || 0) - requiredTokens;

      await db
        .update(users)
        .set({
          usedTokens: newUsedTokens,
          remainingTokens: newRemainingTokens,
          updatedAt: now,
        })
        .where(eq(users.uid, userId));

      // Store token info in context for use in the handler
      c.set('tokenInfo', {
        consumed: requiredTokens,
        remaining: newRemainingTokens,
        endpoint,
      });

      // Proceed with the request
      await next();

      // Log successful API usage
      await db.insert(apiUsage).values({
        userId,
        endpoint,
        tokensConsumed: requiredTokens,
        status: 'success',
        requestData: JSON.stringify(c.req.query()),
        createdAt: now,
      });

    } catch (error) {
      // If it's already an HTTPException, re-throw it
      if (error instanceof HTTPException) {
        throw error;
      }

      // Log the error
      console.error('Token middleware error:', error);
      
      // Try to log the error in database
      try {
        const user = c.get('user');
        if (user) {
          await db.insert(apiUsage).values({
            userId: user.uid,
            endpoint: config.endpoint,
            tokensConsumed: 0,
            status: 'error',
            requestData: JSON.stringify({ error: error instanceof Error ? error.message : 'Unknown error' }),
            createdAt: new Date(),
          });
        }
      } catch (logError) {
        console.error('Failed to log error:', logError);
      }

      throw new HTTPException(500, { message: 'Internal server error' });
    }
  };
};

// Helper function to refund tokens if an operation fails
export const refundTokens = async (userId: string, tokens: number) => {
  try {
    await db
      .update(users)
      .set({
        usedTokens: sql`${users.usedTokens} - ${tokens}`,
        remainingTokens: sql`${users.remainingTokens} + ${tokens}`,
        updatedAt: new Date(),
      })
      .where(eq(users.uid, userId));
  } catch (error) {
    console.error('Failed to refund tokens:', error);
  }
};
