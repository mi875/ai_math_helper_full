import { Hono } from 'hono';
import { authMiddleware } from './middleware/authMiddleware.js';
import {
  getUserProfile,
  updateUserProfile,
  getAvailableGrades,
  uploadProfileImage,
  deleteProfileImage
} from './controllers/userController.js';
import { tokenController } from './controllers/tokenController.js';
import { notebookController } from './controllers/notebookController.js';
import { 
  profileImageUploadMiddleware, 
  serveProfileImage,
  problemImageUploadMiddleware,
  serveProblemImage
} from './middleware/fileUploadMiddleware.js';

// Create an api router with auth middleware
const apiRouter = new Hono()
  .use('*', authMiddleware) // Apply auth middleware to all routes under /api
  .get('/', (c) => c.json({ message: 'Protected API endpoint' }));

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
apiRouter.get('/files/problem-images/:filename', serveProblemImage());

// Token management endpoints
apiRouter.get('/tokens/status', tokenController.getTokenStatus);
apiRouter.get('/tokens/usage', tokenController.getUsageHistory);
apiRouter.get('/tokens/plans', tokenController.getTokenPlans);
apiRouter.post('/tokens/add', tokenController.addTokens); // Admin only

// Notebook endpoints
apiRouter.get('/notebooks', notebookController.getNotebooks);
apiRouter.get('/notebooks/:uid', notebookController.getNotebook);
apiRouter.post('/notebooks', notebookController.createNotebook);
apiRouter.put('/notebooks/:uid', notebookController.updateNotebook);
apiRouter.delete('/notebooks/:uid', notebookController.deleteNotebook);

// Math problem endpoints
apiRouter.post('/notebooks/:uid/problems', notebookController.createProblem);
apiRouter.put('/problems/:problemUid', notebookController.updateProblem);
apiRouter.delete('/problems/:problemUid', notebookController.deleteProblem);
apiRouter.get('/problems/:problemUid/feedbacks', notebookController.getProblemFeedbacks);
apiRouter.post('/problems/:problemUid/feedback/generate', 
  problemImageUploadMiddleware(), 
  notebookController.generateAiFeedback
);

// Problem image upload endpoint
apiRouter.post('/problems/images/upload', 
  problemImageUploadMiddleware(), 
  notebookController.uploadProblemImages
);

// Health check endpoint - public, no auth needed
// and hello world
export const publicRouter = new Hono()
  .get('/health', (c) => c.json({ status: 'ok', time: new Date().toISOString() }));

export { apiRouter };