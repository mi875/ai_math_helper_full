import { migrate } from 'drizzle-orm/node-postgres/migrator';
import { db } from './client.js';

// This function will apply all pending migrations
async function runMigrations() {
  console.log('Running migrations...');
  try {
    await migrate(db, { migrationsFolder: './drizzle' });
    console.log('Migrations completed successfully');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

// Run migrations if this file is executed directly
if (true) {
  runMigrations()
    .then(() => process.exit(0))
    .catch(err => {
      console.error('Unhandled error during migration:', err);
      process.exit(1);
    });
}

export default runMigrations;
