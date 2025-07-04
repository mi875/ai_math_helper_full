import type { Config } from 'drizzle-kit';

export default {
    schema: './src/db/schema.ts',
    out: './drizzle',

    dbCredentials: {
        url: 'postgresql://postgres:mathpassword@localhost:5431/ai_math_helper',
    },
    dialect: 'postgresql'
} satisfies Config;
