# Docker Setup for AI Math Helper Backend

This document explains how to run the AI Math Helper backend using Docker and Docker Compose.

## Prerequisites

- Docker and Docker Compose installed
- Environment variables configured (see below)

## Quick Start

### Production

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down
```

### Development

```bash
# Start with development configuration (hot reload)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Start with database studio
docker-compose -f docker-compose.yml -f docker-compose.dev.yml --profile tools up
```

## Services

### 1. PostgreSQL Database (`postgres`)
- **Image**: `postgres:15-alpine`
- **Port**: `5431:5432`
- **Database**: `ai_math_helper`
- **Credentials**: `postgres/mathpassword`
- **Volume**: `postgres_data` for data persistence

### 2. Backend API (`backend`)
- **Port**: `3000:3000`
- **Health Check**: `/health` endpoint
- **Volume**: `uploads_data` for file storage

### 3. Database Migration (`migrate`)
- Runs database migrations on startup
- Executes once and exits

### 4. Database Studio (`db-studio`) - Development Only
- **Port**: `4983:4983`
- **Usage**: Access Drizzle Studio at `http://localhost:4983`
- **Start**: Use `--profile tools` flag

## Environment Variables

### Required Variables

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

Key variables to set:
- `GOOGLE_AI_API_KEY`: Your Google AI API key
- `FIREBASE_PROJECT_ID`: Your Firebase project ID
- Place `credential.json` in the backend directory

### Docker Environment

The Docker Compose file sets these automatically:
- `DATABASE_URL`: PostgreSQL connection string
- `PORT`: Server port (3000)
- `NODE_ENV`: Environment mode

## Volumes

### Persistent Data
- `postgres_data`: Database data
- `uploads_data`: User uploaded files (profile images, problem images)

### Development Mounts
- `.:/app`: Source code (hot reload)
- `/app/node_modules`: Preserve installed dependencies

## Commands

### Database Operations

```bash
# Run migrations
docker-compose exec backend pnpm run db:migrate

# Generate new migration
docker-compose exec backend pnpm run db:generate

# Open database studio
docker-compose -f docker-compose.yml -f docker-compose.dev.yml --profile tools up db-studio
```

### Application Commands

```bash
# View backend logs
docker-compose logs -f backend

# Access backend container
docker-compose exec backend sh

# Restart backend service
docker-compose restart backend

# Rebuild backend
docker-compose up --build backend
```

## Development Workflow

1. **Initial Setup**:
   ```bash
   # Copy environment file
   cp .env.example .env
   
   # Edit .env with your configuration
   nano .env
   
   # Place Firebase credentials
   cp /path/to/your/credential.json ./credential.json
   ```

2. **Start Development Environment**:
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
   ```

3. **Access Services**:
   - Backend API: `http://localhost:3000`
   - Database Studio: `http://localhost:4983` (with `--profile tools`)
   - PostgreSQL: `localhost:5431`

## Production Deployment

1. **Environment Setup**:
   - Set production environment variables
   - Ensure `NODE_ENV=production`
   - Configure proper secrets management

2. **Deploy**:
   ```bash
   docker-compose up -d
   ```

3. **Health Checks**:
   - Backend: `http://localhost:3000/health`
   - Database: Automatic health check configured

## Troubleshooting

### Common Issues

1. **Port Already in Use**:
   ```bash
   # Change ports in docker-compose.yml
   ports:
     - "3001:3000"  # Use different host port
   ```

2. **Permission Issues**:
   ```bash
   # Fix upload directory permissions
   docker-compose exec backend chown -R nodejs:nodejs uploads
   ```

3. **Database Connection Issues**:
   ```bash
   # Check database is running
   docker-compose ps postgres
   
   # Check database logs
   docker-compose logs postgres
   ```

4. **Build Issues**:
   ```bash
   # Clean rebuild
   docker-compose down
   docker-compose build --no-cache
   docker-compose up
   ```

### Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs backend
docker-compose logs postgres

# Follow logs
docker-compose logs -f backend
```

## File Structure

```
backend/
├── Dockerfile              # Multi-stage build configuration
├── docker-compose.yml      # Production configuration
├── docker-compose.dev.yml  # Development overrides
├── .dockerignore           # Build context exclusions
├── .env.example           # Environment template
└── DOCKER.md              # This documentation
```

## Network

All services communicate through the `ai_math_helper` bridge network:
- `postgres`: Database service
- `backend`: API service
- `migrate`: Migration service
- `db-studio`: Development tool (optional)

## Security Considerations

- Non-root user in containers
- Minimal attack surface with Alpine images
- Health checks for service monitoring
- Proper secret management (avoid committing `.env`)
- Firebase credentials mounted as read-only