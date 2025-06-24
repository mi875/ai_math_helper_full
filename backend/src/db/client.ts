import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as schema from './schema.js';

// Create a PostgreSQL connection pool
const pool = new Pool({
  connectionString: 'postgresql://postgres:mathpassword@localhost:5431/ai_math_helper',
});

// Create a Drizzle ORM client
export const db = drizzle(pool, { schema });

// Test the database connection
pool.query('SELECT NOW()')
  .then(res => console.log('Database connected at:', res.rows[0].now))
  .catch(err => console.error('Database connection error:', err));

export default pool;
