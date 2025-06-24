import { Hono } from 'hono';
import { authMiddleware } from './middleware/authMiddleware.js';
import { tokenMiddleware, TOKEN_COSTS } from './middleware/tokenMiddleware.js';
import { 
  getUserMathProblems, 
  getMathProblem, 
  createMathProblem, 
  updateMathProblem, 
  deleteMathProblem,
  solveMathProblemAI,
  explainMathConcept,
  generatePracticeProblems
} from './controllers/mathProblemController.js';
import {
  getUserProfile,
  updateUserProfile,
  getAvailableGrades,
  uploadProfileImage,
  deleteProfileImage
} from './controllers/userController.js';
import { tokenController } from './controllers/tokenController.js';
import { 
  profileImageUploadMiddleware, 
  serveProfileImage 
} from './middleware/fileUploadMiddleware.js';

// Create an api router with auth middleware
const apiRouter = new Hono()
  .use('*', authMiddleware) // Apply auth middleware to all routes under /api
  .get('/', (c) => c.json({ message: 'Protected API endpoint' }));

// Math problems endpoints
apiRouter.get('/math/problems', getUserMathProblems);
apiRouter.get('/math/problems/:id', getMathProblem);
apiRouter.post('/math/problems', createMathProblem);
apiRouter.put('/math/problems/:id', updateMathProblem);
apiRouter.delete('/math/problems/:id', deleteMathProblem);

// AI-powered math endpoints (with token middleware)
apiRouter.post('/math/ai/solve', 
  tokenMiddleware({ requiredTokens: TOKEN_COSTS.PROBLEM_SOLVING, endpoint: '/math/ai/solve' }),
  solveMathProblemAI
);
apiRouter.post('/math/ai/explain', 
  tokenMiddleware({ requiredTokens: TOKEN_COSTS.EXPLANATION, endpoint: '/math/ai/explain' }),
  explainMathConcept
);
apiRouter.post('/math/ai/generate', 
  tokenMiddleware({ requiredTokens: TOKEN_COSTS.COMPLEX_AI_QUERY, endpoint: '/math/ai/generate' }),
  generatePracticeProblems
);

// User data endpoints
apiRouter.get('/user/profile', getUserProfile);
apiRouter.put('/user/profile', updateUserProfile);
apiRouter.get('/user/grades', getAvailableGrades);

// Profile image endpoints
apiRouter.post('/user/profile/image', 
  profileImageUploadMiddleware(), 
  uploadProfileImage
);
apiRouter.delete('/user/profile/image', deleteProfileImage);

// File serving endpoints (public)
apiRouter.get('/files/profile-images/:filename', serveProfileImage());

// Token management endpoints
apiRouter.get('/tokens/status', tokenController.getTokenStatus);
apiRouter.get('/tokens/usage', tokenController.getUsageHistory);
apiRouter.get('/tokens/plans', tokenController.getTokenPlans);
apiRouter.post('/tokens/add', tokenController.addTokens); // Admin only

// Health check endpoint - public, no auth needed
// and hello world
export const publicRouter = new Hono()
  .get('/health', (c) => c.json({ status: 'ok', time: new Date().toISOString() }));

export { apiRouter };