# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AI Math Helper is a full-stack application consisting of a Flutter mobile frontend and a Node.js backend API. The app helps students solve math problems using AI, with features for uploading problem images, managing notebooks, and tracking token usage.

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
- `cd backend && npm run dev` - Start development server with hot reload
- `cd backend && npm run build` - Build TypeScript to JavaScript
- `cd backend && npm start` - Start production server
- `cd backend && npm run db:generate` - Generate database migrations
- `cd backend && npm run db:migrate` - Run database migrations
- `cd backend && npm run db:studio` - Open Drizzle Studio for database management

### Database Setup
The backend uses PostgreSQL with Drizzle ORM. Database runs on localhost:5431 with compose.yaml in backend/db/

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

Key backend components:
- `src/index.ts` - Main server entry point
- `src/routers.ts` - API route definitions
- `src/db/schema.ts` - Database schema with users, mathProblems, apiUsage tables
- `src/mastra/` - AI agents for math solving, explanation, and practice generation
- `src/controllers/` - Request handlers for math, user, and token management
- `src/middleware/` - Auth, token management, and file upload middleware

### Backend API Routes
- `/api/math/problems` - CRUD operations for math problems
- `/api/math/ai/solve` - AI-powered problem solving (requires tokens)
- `/api/math/ai/explain` - AI concept explanations (requires tokens)  
- `/api/math/ai/generate` - Generate practice problems (requires tokens)
- `/api/user/profile` - User profile management with image upload
- `/api/tokens/status` - Token usage tracking
- `/health` - Public health check endpoint

### Frontend Architecture (Flutter)
- **State Management**: Riverpod with code generation
- **Data Classes**: Freezed for immutable models
- **Authentication**: Firebase Auth with Google Sign-In
- **Document Scanning**: flutter_doc_scanner for math problem capture
- **Handwriting Input**: Custom scribble library fork

Frontend structure follows the existing CLAUDE.md in frontend/ directory.

### Database Schema
- **users**: Firebase UID, profile data, token allocation and usage tracking
- **mathProblems**: User problems with solutions and token costs
- **apiUsage**: Detailed API usage tracking for billing/analytics

### AI Integration
Uses Mastra framework with three specialized agents:
- **mathSolver**: Solves mathematical problems
- **mathExplainer**: Explains mathematical concepts
- **practiceGenerator**: Creates practice problems

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