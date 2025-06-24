import type { Context } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { db } from '../db/client.js';
import { users, apiUsage } from '../db/schema.js';
import { eq, desc, and, gte, sql } from 'drizzle-orm';

export const tokenController = {
  // Get user's token status
  getTokenStatus: async (c: Context) => {
    try {
      const user = c.get('user');
      if (!user) {
        throw new HTTPException(401, { message: 'Authentication required' });
      }

      const [userTokens] = await db
        .select({
          totalTokens: users.totalTokens,
          usedTokens: users.usedTokens,
          remainingTokens: users.remainingTokens,
          tokenResetDate: users.tokenResetDate,
          isActive: users.isActive,
        })
        .from(users)
        .where(eq(users.uid, user.uid))
        .limit(1);

      if (!userTokens) {
        throw new HTTPException(404, { message: 'User not found' });
      }

      return c.json({
        success: true,
        data: {
          totalTokens: userTokens.totalTokens || 0,
          usedTokens: userTokens.usedTokens || 0,
          remainingTokens: userTokens.remainingTokens || 0,
          tokenResetDate: userTokens.tokenResetDate,
          isActive: userTokens.isActive,
          resetDaysLeft: userTokens.tokenResetDate 
            ? Math.ceil((new Date(userTokens.tokenResetDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24))
            : null,
        },
      });
    } catch (error) {
      console.error('Get token status error:', error);
      if (error instanceof HTTPException) {
        throw error;
      }
      throw new HTTPException(500, { message: 'Internal server error' });
    }
  },

  // Get user's API usage history
  getUsageHistory: async (c: Context) => {
    try {
      const user = c.get('user');
      if (!user) {
        throw new HTTPException(401, { message: 'Authentication required' });
      }

      const page = parseInt(c.req.query('page') || '1');
      const limit = parseInt(c.req.query('limit') || '20');
      const offset = (page - 1) * limit;

      // Get usage from last 30 days
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const usageHistory = await db
        .select({
          id: apiUsage.id,
          endpoint: apiUsage.endpoint,
          tokensConsumed: apiUsage.tokensConsumed,
          status: apiUsage.status,
          createdAt: apiUsage.createdAt,
        })
        .from(apiUsage)
        .where(
          and(
            eq(apiUsage.userId, user.uid),
            gte(apiUsage.createdAt, thirtyDaysAgo)
          )
        )
        .orderBy(desc(apiUsage.createdAt))
        .limit(limit)
        .offset(offset);

      // Get total count for pagination
      const [{ count }] = await db
        .select({ count: sql<number>`count(*)` })
        .from(apiUsage)
        .where(
          and(
            eq(apiUsage.userId, user.uid),
            gte(apiUsage.createdAt, thirtyDaysAgo)
          )
        );

      return c.json({
        success: true,
        data: {
          usage: usageHistory,
          pagination: {
            page,
            limit,
            total: count,
            totalPages: Math.ceil(count / limit),
          },
        },
      });
    } catch (error) {
      console.error('Get usage history error:', error);
      if (error instanceof HTTPException) {
        throw error;
      }
      throw new HTTPException(500, { message: 'Internal server error' });
    }
  },

  // Admin: Add tokens to a user (for admin use)
  addTokens: async (c: Context) => {
    try {
      const user = c.get('user');
      if (!user) {
        throw new HTTPException(401, { message: 'Authentication required' });
      }

      // Note: In a real app, you'd check if the user is an admin
      const body = await c.req.json();
      const { targetUserId, tokensToAdd } = body;

      if (!targetUserId || !tokensToAdd || tokensToAdd <= 0) {
        throw new HTTPException(400, { message: 'Invalid request data' });
      }

      const [targetUser] = await db
        .select({
          totalTokens: users.totalTokens,
          remainingTokens: users.remainingTokens,
        })
        .from(users)
        .where(eq(users.uid, targetUserId))
        .limit(1);

      if (!targetUser) {
        throw new HTTPException(404, { message: 'Target user not found' });
      }

      const newTotalTokens = (targetUser.totalTokens || 0) + tokensToAdd;
      const newRemainingTokens = (targetUser.remainingTokens || 0) + tokensToAdd;

      await db
        .update(users)
        .set({
          totalTokens: newTotalTokens,
          remainingTokens: newRemainingTokens,
          updatedAt: new Date(),
        })
        .where(eq(users.uid, targetUserId));

      return c.json({
        success: true,
        message: `Added ${tokensToAdd} tokens to user ${targetUserId}`,
        data: {
          newTotalTokens,
          newRemainingTokens,
        },
      });
    } catch (error) {
      console.error('Add tokens error:', error);
      if (error instanceof HTTPException) {
        throw error;
      }
      throw new HTTPException(500, { message: 'Internal server error' });
    }
  },

  // Get token pricing/plans info
  getTokenPlans: async (c: Context) => {
    return c.json({
      success: true,
      data: {
        plans: [
          {
            name: 'Free',
            tokensPerMonth: 1000,
            price: 0,
            features: ['Basic AI queries', 'Problem solving', 'Explanations'],
          },
          {
            name: 'Student',
            tokensPerMonth: 5000,
            price: 500, // 500 yen
            features: ['All Free features', 'Priority support', 'Advanced AI models'],
          },
          {
            name: 'Premium',
            tokensPerMonth: 15000,
            price: 1200, // 1200 yen
            features: ['All Student features', 'Unlimited explanations', 'Custom difficulty levels'],
          },
        ],
        tokenCosts: {
          basicQuery: 10,
          complexQuery: 25,
          problemSolving: 15,
          explanation: 20,
          imageGeneration: 50,
        },
      },
    });
  },
};
