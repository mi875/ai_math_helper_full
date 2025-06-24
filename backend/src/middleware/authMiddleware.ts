import { type Next,  } from 'hono';
import { auth } from '../config/firebase.js';
import type { Context } from 'node:vm';

// Middleware to verify Firebase authentication token
export async function authMiddleware(c: Context, next: Next) {
  try {
    const authHeader = c.req.header('Authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return c.json({ error: 'Unauthorized: No token provided' }, 401);
    }
    
    const token = authHeader.split('Bearer ')[1];
    
    try {
      const decodedToken = await auth.verifyIdToken(token);
      
      // Add the user information to the context for use in route handlers
      c.set('user', {
        uid: decodedToken.uid,
        email: decodedToken.email,
        // Add other user properties as needed
      });
      
      await next();
    } catch (error) {
        console.log(error)
      return c.json({ error: 'Unauthorized: Invalid token' }, 401);
    }
  } catch (error) {
    console.error('Auth middleware error:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
}
