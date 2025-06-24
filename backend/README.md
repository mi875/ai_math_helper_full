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
  - `GET /api/user/profile` - Get user profile
  - `PUT /api/user/profile` - Update user profile
  - `GET /api/user/grades` - Get available grades
  - `POST /api/user/profile/image` - Upload profile image
  - `DELETE /api/user/profile/image` - Delete profile image
  - `GET /api/files/profile-images/:filename` - Serve profile image
  - `GET /api/tokens/status` - Get token status
  - `GET /api/tokens/usage` - Get usage history
  - `GET /api/tokens/plans` - Get token plans
  - `POST /api/tokens/add` - Add tokens (Admin only)
