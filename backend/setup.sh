#!/bin/bash

# AI Math Helper Backend - Docker Setup Script

set -e

echo "🚀 AI Math Helper Backend Docker Setup"
echo "======================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚙️  Creating .env file from template..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ .env file created. Please edit it with your configuration."
        echo "📝 Important: Set your GOOGLE_AI_API_KEY and FIREBASE_PROJECT_ID"
    else
        echo "❌ .env.example not found. Please create .env manually."
        exit 1
    fi
else
    echo "✅ .env file already exists."
fi

# Check for Firebase credentials
if [ ! -f credential.json ]; then
    echo "⚠️  Firebase credential.json not found."
    echo "📝 Please place your Firebase service account credentials as 'credential.json'"
    echo "   You can continue without it, but Firebase authentication won't work."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✅ Firebase credentials found."
fi

# Ask for deployment type
echo ""
echo "Select deployment type:"
echo "1) Production (optimized build)"
echo "2) Development (hot reload)"
echo "3) Development with tools (includes database studio)"
echo "4) Database only"

read -p "Choose option (1-4): " -n 1 -r
echo

case $REPLY in
    1)
        echo "🏗️  Building and starting production environment..."
        docker-compose build
        docker-compose up -d
        echo "✅ Production environment started!"
        echo "🌐 Backend API: http://localhost:3000"
        echo "📊 Health check: http://localhost:3000/health"
        ;;
    2)
        echo "🏗️  Starting development environment..."
        docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
        ;;
    3)
        echo "🏗️  Starting development environment with tools..."
        docker-compose -f docker-compose.yml -f docker-compose.dev.yml --profile tools up
        ;;
    4)
        echo "🏗️  Starting database only..."
        docker-compose -f db/compose.yaml up -d
        echo "✅ Database started!"
        echo "🗄️  PostgreSQL: localhost:5431"
        ;;
    *)
        echo "❌ Invalid option selected."
        exit 1
        ;;
esac

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Useful commands:"
echo "  make help     - Show all available commands"
echo "  make logs     - View service logs"
echo "  make down     - Stop all services"
echo "  make migrate  - Run database migrations"
echo ""
echo "For more information, see DOCKER.md"