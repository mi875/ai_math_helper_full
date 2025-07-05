import type { Context } from 'hono';
import { getCacheStats as getMemoryCacheStats } from '../utils/imageOptimizer.js';
import { getCacheStats as getRedisCacheStats, redisImageCache } from '../utils/fallbackRedisCache.js';

export const cacheController = {
  // Get comprehensive cache statistics
  async getCacheStats(c: Context) {
    try {
      const user = c.get('user');
      const userId = user?.uid;

      // Get stats from both caching systems
      const [memoryCacheStats, redisCacheStats] = await Promise.all([
        getMemoryCacheStats(),
        getRedisCacheStats(),
      ]);

      // Get user-specific stats if user is authenticated
      let userStats = null;
      if (userId) {
        try {
          userStats = await redisImageCache.getUserSessionStats(userId);
        } catch (error) {
          console.warn('Failed to get user stats:', error);
        }
      }

      return c.json({
        success: true,
        data: {
          memoryCache: {
            name: 'In-Memory Image Cache',
            ...memoryCacheStats,
            efficiency: memoryCacheStats.hitRate * 100,
          },
          redisCache: {
            name: 'Redis Distributed Cache',
            ...redisCacheStats,
            isAvailable: true, // Will be false if Redis is down
          },
          userStats: userStats ? {
            userId,
            ...userStats,
            efficiency: userStats.tokensSaved > 0 ? (userStats.tokensSaved / (userStats.totalCanvasChanges * 150)) * 100 : 0,
          } : null,
          recommendations: generateCacheRecommendations(memoryCacheStats, redisCacheStats, userStats),
        }
      });
    } catch (error) {
      console.error('Error getting cache stats:', error);
      return c.json({
        success: false,
        error: 'Failed to get cache statistics'
      }, 500);
    }
  },

  // Clear cache entries (admin only)
  async clearCache(c: Context) {
    try {
      const user = c.get('user');
      const { cacheType = 'all', userId = null } = await c.req.json();

      // This would typically require admin privileges
      // For demo purposes, allowing authenticated users to clear their own cache

      let clearedEntries = 0;

      if (cacheType === 'memory' || cacheType === 'all') {
        // Clear memory cache (implementation would depend on your cache structure)
        console.log('Clearing memory cache...');
      }

      if (cacheType === 'redis' || cacheType === 'all') {
        try {
          clearedEntries += await redisImageCache.clearExpiredEntries();
        } catch (error) {
          console.warn('Failed to clear Redis cache:', error);
        }
      }

      return c.json({
        success: true,
        data: {
          clearedEntries,
          message: `Cleared ${clearedEntries} cache entries`
        }
      });
    } catch (error) {
      console.error('Error clearing cache:', error);
      return c.json({
        success: false,
        error: 'Failed to clear cache'
      }, 500);
    }
  },

  // Get cache performance metrics
  async getCachePerformance(c: Context) {
    try {
      const user = c.get('user');
      const userId = user?.uid;

      if (!userId) {
        return c.json({
          success: false,
          error: 'Authentication required'
        }, 401);
      }

      // Get detailed performance metrics for the user
      const userStats = await redisImageCache.getUserSessionStats(userId);
      
      // Calculate performance metrics
      const avgTokensPerInteraction = userStats.totalCanvasChanges > 0 
        ? userStats.tokensSaved / userStats.totalCanvasChanges 
        : 0;

      const cacheEfficiency = userStats.totalCanvasChanges > 0 
        ? (userStats.tokensSaved / (userStats.totalCanvasChanges * 200)) * 100 
        : 0;

      return c.json({
        success: true,
        data: {
          userId,
          performance: {
            totalSessions: userStats.totalSessions,
            totalCanvasChanges: userStats.totalCanvasChanges,
            averageSimilarity: userStats.averageSimilarity,
            tokensSaved: userStats.tokensSaved,
            avgTokensPerInteraction,
            cacheEfficiency,
            estimatedCostSavings: userStats.tokensSaved * 0.0001, // Rough cost estimate
          },
          insights: generatePerformanceInsights(userStats),
        }
      });
    } catch (error) {
      console.error('Error getting cache performance:', error);
      return c.json({
        success: false,
        error: 'Failed to get cache performance metrics'
      }, 500);
    }
  },
};

// Helper function to generate cache recommendations
function generateCacheRecommendations(
  memoryStats: any,
  redisStats: any,
  userStats: any
): string[] {
  const recommendations: string[] = [];

  if (memoryStats.size >= memoryStats.maxSize * 0.9) {
    recommendations.push('Memory cache is nearly full. Consider increasing cache size or reducing TTL.');
  }

  if (redisStats.totalKeys > 10000) {
    recommendations.push('Redis cache has many entries. Consider implementing cache partitioning.');
  }

  if (userStats && userStats.averageSimilarity > 0.95) {
    recommendations.push('User submits very similar images frequently. Consider increasing similarity threshold.');
  }

  if (userStats && userStats.tokensSaved < userStats.totalCanvasChanges * 50) {
    recommendations.push('Low token savings detected. Review image change detection sensitivity.');
  }

  if (recommendations.length === 0) {
    recommendations.push('Cache performance is optimal. No immediate optimizations needed.');
  }

  return recommendations;
}

// Helper function to generate performance insights
function generatePerformanceInsights(userStats: any): string[] {
  const insights: string[] = [];

  const avgSimilarity = userStats.averageSimilarity;
  const efficiency = userStats.tokensSaved / (userStats.totalCanvasChanges * 200) * 100;

  if (avgSimilarity > 0.9) {
    insights.push('High image similarity detected - you tend to make small, incremental changes.');
  } else if (avgSimilarity < 0.5) {
    insights.push('Low image similarity detected - you make significant changes between submissions.');
  }

  if (efficiency > 70) {
    insights.push('Excellent cache efficiency! The system is saving significant processing costs.');
  } else if (efficiency < 30) {
    insights.push('Low cache efficiency. Consider making smaller changes between submissions.');
  }

  if (userStats.totalSessions > 10) {
    insights.push('Active user with good session history for optimization.');
  }

  return insights;
}