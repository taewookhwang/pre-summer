# Backend Standardization Project

This repository contains the standardized backend architecture for the home cleaning services platform. The project implements a microservices architecture with standardized patterns for logging, configuration, error handling, and code style.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Installation Guide](#installation-guide)
- [Contribution Guide](#contribution-guide)
- [Folder Structure](#folder-structure)
- [Coding Standards](#coding-standards)
- [Documentation](#documentation)

## Architecture Overview

The backend follows a microservices architecture with the following key components:

- **API Gateway**: Entry point for all client requests
- **Microservices**: Independent services for specific business domains
- **Shared Components**: Standardized modules used across all services

For a detailed architecture overview, see [Architecture Overview](./docs/architecture/architecture-overview.md).

## Installation Guide

For detailed setup instructions, see [Installation Guide](./docs/installation-guide.md).

Quick start:

```bash
# Clone the repository
git clone <repository-url>
cd backend

# Install dependencies
npm install

# Set up environment variables
cp Infrastructure/.env.example Infrastructure/.env.development

# Start development server
npm run dev
```

## Services

The backend consists of the following microservices:

- **AuthService**: User authentication and authorization
- **ConsumerService**: Service browsing and booking for consumers
- **TechnicianService**: Job management for service providers
- **PaymentService**: Payment processing
- **MatchingService**: Matching consumers with technicians
- **AdminService**: Administrative dashboard and user management
- **ChatService**: Real-time messaging
- **RealtimeService**: Real-time notifications and updates
- **FileService**: File storage and management
- **ReviewService**: Service reviews
- **CancelService**: Cancellation management

## Shared Components

Standardized modules used across all services:

- **Logger**: Centralized logging system
- **Config**: Environment configuration management
- **Database**: Database connection and models
- **Cache**: Redis-based caching
- **Middleware**: Common middleware (auth, error handling, request logging)
- **Validation**: Input validation utilities
- **Errors**: Standardized error handling
- **Utils**: Common utility functions

## Standardization Features

This project implements the following standardization features:

1. **Logging System**:
   - Consistent log levels and formats
   - Context preservation for request tracking
   - Error tracking with stack traces
   - Daily log rotation

2. **Environment Configuration**:
   - Environment-specific .env files
   - Standardized variable naming
   - Type conversion and validation
   - Service-specific configuration

3. **Code Style**:
   - ESLint and Prettier configuration
   - Consistent JSDoc comments
   - Standardized folder structure
   - Code duplication prevention

4. **Error Handling**:
   - Standardized error classes
   - Centralized error middleware
   - Consistent error responses

5. **API Responses**:
   - Consistent response format
   - Standardized status codes
   - Pagination support

## Documentation

Comprehensive documentation is available in the `docs/` directory:

- [Architecture Overview](./docs/architecture/architecture-overview.md)
- [Installation Guide](./docs/installation-guide.md)
- [Contribution Guide](./docs/contribution-guide.md)
- [Folder Structure Guide](./docs/folder-structure.md)
- [Environment Configuration Guide](./docs/env-config-guide.md)
- [JSDoc Style Guide](./docs/jsdoc-guide.md)
- [Logging Guide](./docs/logging-guide.md)
- [API Documentation](./docs/api/README.md)

## Scripts

```bash
# Start the API Gateway
npm start

# Development mode
npm run dev

# Start individual services
npm run auth
npm run consumer
npm run technician
# ... and others

# Linting and formatting
npm run lint
npm run lint:fix
npm run format

# Generate documentation
npm run docs

# Run tests
npm test
```

## License

This project is licensed under the ISC License.