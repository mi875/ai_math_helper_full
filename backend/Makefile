# AI Math Helper Backend - Docker Management

.PHONY: help build up down logs restart migrate dev dev-tools clean

# Default target
help:
	@echo "AI Math Helper Backend - Docker Commands"
	@echo ""
	@echo "Production:"
	@echo "  make build     - Build all services"
	@echo "  make up        - Start all services"
	@echo "  make down      - Stop all services"
	@echo "  make restart   - Restart all services"
	@echo "  make logs      - View logs"
	@echo ""
	@echo "Development:"
	@echo "  make dev       - Start development environment"
	@echo "  make dev-tools - Start dev environment with database studio"
	@echo ""
	@echo "Database:"
	@echo "  make migrate   - Run database migrations"
	@echo "  make db-only   - Start only database"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean     - Clean up containers and volumes"
	@echo "  make rebuild   - Clean rebuild all services"

# Production commands
build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f

# Development commands
dev:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

dev-tools:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml --profile tools up

# Database commands
migrate:
	docker-compose exec backend pnpm run db:migrate

db-only:
	docker-compose -f db/compose.yaml up -d

# Maintenance commands
clean:
	docker-compose down -v
	docker system prune -f

rebuild: clean build up

# Status
status:
	docker-compose ps

# Backend shell access
shell:
	docker-compose exec backend sh

# View specific service logs
logs-backend:
	docker-compose logs -f backend

logs-db:
	docker-compose logs -f postgres

# Health check
health:
	@echo "Checking backend health..."
	@curl -f http://localhost:3000/health && echo "✅ Backend is healthy" || echo "❌ Backend is not responding"