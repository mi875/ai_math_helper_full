import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import { logger } from 'hono/logger';
import { cors } from 'hono/cors';
import { apiRouter, publicRouter } from './routers.js';
import './db/client.js'; // Import to initialize database connection

export const app = new Hono();

// Add middleware
app.use('*', logger());
app.use('*', cors());

// Add routes
app.get('/', (c) => {
  return c.text('AI Math Helper API');
});

// Mount routers
app.route('/api', apiRouter);
app.route('/', publicRouter);

// Start the server
const PORT = process.env.PORT || 3000;
serve({
  fetch: app.fetch,
  port: Number(PORT),
}, (info) => {
  console.log(`Server is running on http://localhost:${info.port}`);
});
