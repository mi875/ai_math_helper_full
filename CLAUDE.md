# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AI Math Helper is a full-stack application consisting of a Flutter mobile frontend and a Node.js backend API. The app provides user profile management, image upload functionality, and token-based API access control.

## Development Commands

### Frontend (Flutter)
- `cd frontend && flutter run` - Run the Flutter app in debug mode
- `cd frontend && flutter build apk` - Build Android APK
- `cd frontend && flutter build ios` - Build iOS app
- `cd frontend && dart run build_runner build` - Generate code for Riverpod, Freezed, and JSON serialization
- `cd frontend && flutter test` - Run widget tests
- `cd frontend && flutter analyze` - Run static analysis
- `cd frontend && dart run custom_lint` - Run custom lints including Riverpod lints

### Backend (Node.js/Hono)
- `cd backend && pnpm run dev` - Start development server with hot reload
- `cd backend && pnpm run build` - Build TypeScript to JavaScript
- `cd backend && pnpm start` - Start production server
- `cd backend && pnpm run db:generate` - Generate database migrations
- `cd backend && pnpm run db:migrate` - Run database migrations
- `cd backend && pnpm run db:studio` - Open Drizzle Studio for database management

### Database Setup
The backend uses PostgreSQL with Drizzle ORM. Database runs on localhost:5431 with compose.yaml in backend/db/

### Docker Setup
Full Docker Compose setup available for backend:
- `cd backend && ./setup.sh` - Interactive setup script
- `make help` - Show all Docker commands
- `docker-compose up -d` - Start production environment
- `docker-compose -f docker-compose.yml -f docker-compose.dev.yml up` - Development with hot reload
- See `backend/DOCKER.md` for complete documentation

## Architecture

### Full-Stack Structure
```
ai_math_helper_full/
├── frontend/           # Flutter mobile app
├── backend/           # Node.js API server
└── README.md
```

### Backend Architecture (Node.js + Hono)
- **Framework**: Hono.js with TypeScript
- **Database**: PostgreSQL with Drizzle ORM
- **AI Integration**: Mastra framework with Google Generative AI
- **Authentication**: Firebase Admin SDK for token validation
- **File Uploads**: Multer with Sharp for image processing
- **Image Optimization**: Perceptual hashing with intelligent change detection
- **Caching**: Multi-tier in-memory cache with optional Redis support
- **Cost Optimization**: Smart cropping, adaptive compression, and token reduction

Key backend components:
- `src/index.ts` - Main server entry point
- `src/routers.ts` - API route definitions
- `src/db/schema.ts` - Database schema with users and apiUsage tables
- `src/controllers/` - Request handlers for user and token management
- `src/middleware/` - Auth, token management, and file upload middleware
- `src/utils/imageOptimizer.ts` - Intelligent image processing and optimization
- `src/utils/fallbackRedisCache.ts` - Multi-tier caching system
- `src/mastra/agents/mathHelper.ts` - AI agent with enhanced memory and image tracking

### Backend API Routes
- `/api/user/profile` - User profile management with image upload
- `/api/tokens/status` - Token usage tracking
- `/api/problems/:problemUid/feedback/stream` - AI feedback with intelligent image processing
- `/api/cache/stats` - Cache performance monitoring
- `/api/cache/performance` - User-specific optimization metrics  
- `/health` - Public health check endpoint

### Frontend Architecture (Flutter)
- **State Management**: Riverpod with code generation
- **Data Classes**: Freezed for immutable models
- **Authentication**: Firebase Auth with Google Sign-In

Frontend structure follows the existing CLAUDE.md in frontend/ directory.

### Database Schema
- **users**: Firebase UID, profile data, token allocation and usage tracking
- **apiUsage**: Detailed API usage tracking for billing/analytics

### Token System
- Users have monthly token allocations (default: 1000)
- Different operations consume different token amounts
- Token middleware enforces usage limits
- Usage tracked in database for analytics

## Key Dependencies

### Backend
- **@hono/node-server** + **hono** - Web framework
- **drizzle-orm** + **drizzle-kit** - Database ORM and migrations
- **@mastra/core** + **@ai-sdk/google** - AI framework and Google AI integration
- **firebase-admin** - Authentication validation
- **multer** + **sharp** - File upload and image processing
- **heic-convert** - HEIC image format conversion

### Frontend
- **firebase_core** + **firebase_auth** - Authentication
- **flutter_riverpod** + **riverpod_annotation** - State management
- **freezed** + **json_annotation** - Data classes and serialization
- **flutter_doc_scanner** - Document scanning
- **scribble** (custom fork) - Handwriting input
- **material3_layout** - Material 3 components

## Environment Setup

### Backend Environment Variables
Required in backend/.env:
- Database connection details for PostgreSQL
- Firebase service account credentials
- Google AI API keys

### Firebase Configuration
- Frontend: Uses firebase_options.dart for initialization
- Backend: Uses credential.json for admin SDK
- Authentication handled via Firebase Auth tokens

## Image Optimization Features

### Cost Reduction System
The AI Math Helper now includes intelligent image optimization to reduce AI processing costs:

- **Perceptual Hash Change Detection**: Only processes images when meaningful changes occur (>15% difference)
- **Smart Cropping**: Automatically removes empty space and focuses on content
- **Adaptive Compression**: Analyzes content to determine optimal quality (text-heavy = higher quality)
- **Multi-tier Caching**: In-memory cache with optional Redis support for persistence
- **Token Reduction**: Achieves 60-80% reduction in AI token consumption

### Performance Monitoring
- **GET** `/api/cache/stats` - Overall cache performance
- **GET** `/api/cache/performance` - User-specific metrics  
- **POST** `/api/cache/clear` - Clear cache entries

### Benefits
- 60-80% fewer AI tokens consumed for unchanged images
- 90% faster response times for cached content
- 40-60% bandwidth savings through compression
- Seamless fallback mechanisms for reliability

### Documentation
See `backend/docs/IMAGE_OPTIMIZATION.md` for detailed technical documentation.

### Don't run these commands
- pnpm run dev
- flutter run