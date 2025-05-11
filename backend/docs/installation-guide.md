# Backend Installation and Setup Guide

This guide provides comprehensive instructions for setting up the backend services for development, testing, and production environments.

## Prerequisites

Before starting, ensure you have the following installed:

- Node.js (v18 or later)
- npm (v9 or later)
- Docker and Docker Compose
- Git

## Clone the Repository

```bash
git clone <repository-url>
cd backend
```

## Environment Configuration

1. Create appropriate environment files based on your target environment:

```bash
cp Infrastructure/.env.example Infrastructure/.env.development
# Edit the .env.development file with your local settings
```

2. For each environment, set up the specific configuration files:
   - `.env.development` - For local development
   - `.env.test` - For running tests
   - `.env.production` - For production deployment

Refer to the [Environment Configuration Guide](./env-config-guide.md) for detailed information about environment variables.

## Install Dependencies

Install all required dependencies:

```bash
npm install
```

## Database Setup

1. Create the necessary databases:

```bash
# Start the database container
docker-compose -f Infrastructure/docker-compose.yml up -d db

# Initialize the database schema
npm run db:init
```

2. Seed the database with initial data:

```bash
npm run db:seed
```

## Starting Services

### Development Mode

To start all services in development mode:

```bash
npm run dev
```

This will start all services with hot reloading enabled.

To start a specific service:

```bash
npm run dev -- --service=AuthService
```

### Production Mode

For production deployment:

```bash
npm run build
npm start
```

## Docker Deployment

To deploy the entire stack using Docker:

```bash
docker-compose -f Infrastructure/docker-compose.yml up -d
```

This will build and start all services defined in the Docker Compose file.

## Accessing the API

Once the services are running:

- API Gateway: http://localhost:3000
- Swagger Documentation: http://localhost:3000/api-docs

## Running Tests

```bash
# Run all tests
npm test

# Run tests for a specific service
npm test -- --service=AuthService

# Run tests with coverage
npm run test:coverage
```

## Linting and Code Formatting

```bash
# Run ESLint
npm run lint

# Fix ESLint issues
npm run lint:fix

# Run Prettier
npm run format
```

## Logging

Logs are stored in the `logs/` directory and are rotated daily. You can configure log levels in the environment files:

```
LOG_LEVEL=info
```

Available log levels: `error`, `warn`, `info`, `http`, `debug`

## Troubleshooting

### Common Issues

1. **Port conflicts**: If a port is already in use, you can modify the port in the corresponding environment file.

2. **Database connection errors**: Verify your database credentials in the environment files and ensure the database server is running.

3. **Missing dependencies**: Run `npm install` to ensure all dependencies are installed.

### Logs

Check the logs for detailed error information:

```bash
# View the most recent logs
cat logs/app.log

# View logs in real-time
tail -f logs/app.log
```

## Additional Resources

- [Folder Structure Guide](./folder-structure.md)
- [API Documentation](./api/README.md)
- [Architecture Overview](./architecture/architecture-overview.md)
- [Coding Standards](../CODING_STANDARDS.md)
- [JSDoc Guide](./jsdoc-guide.md)
- [Logging Guide](./logging-guide.md)