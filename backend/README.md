# AI Math Helper API

Backend API for the AI Math Helper application built with Hono, PostgreSQL, and Firebase Authentication.

## Prerequisites

- Node.js 18+ and pnpm
- PostgreSQL (via Docker or local installation)
- Firebase project with Authentication enabled

## Setup

1. Install dependencies:

```bash
pnpm install
```

2. Set up your environment variables:

Copy the `.env.example` file to `.env` and update the variables:

```bash
cp .env.example .env
# Edit .env with your configuration
```

3. Start PostgreSQL using Docker:

```bash
cd ../db
docker-compose up -d
```

4. Generate and run database migrations:

```bash
pnpm db:generate
pnpm db:migrate
```

## Development

Start the development server:

```bash
pnpm dev
```

The API will be available at http://localhost:3000

## API Routes

- Public: `GET /health` - Health check endpoint
- Authentication required:
  - `GET /api/math/problems` - Get all math problems
  - `GET /api/math/problems/:id` - Get a specific math problem
  - `POST /api/math/problems` - Create a new math problem
  - `PUT /api/math/problems/:id` - Update a math problem
  - `DELETE /api/math/problems/:id` - Delete a math problem
  - `GET /api/user/profile` - Get user profile
