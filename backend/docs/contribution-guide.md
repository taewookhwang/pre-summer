# Contribution Guide

This guide outlines the process for contributing to the backend codebase, ensuring consistency and quality across all submissions.

## Getting Started

1. Make sure you have read the following documents:
   - [Installation Guide](./installation-guide.md)
   - [Coding Standards](../CODING_STANDARDS.md)
   - [Architecture Overview](./architecture/architecture-overview.md)
   - [Folder Structure Guide](./folder-structure.md)

2. Set up your development environment as described in the Installation Guide.

## Development Workflow

### 1. Branching Strategy

We follow a feature branch workflow:

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/feature-name` - Feature branches
- `bugfix/bug-name` - Bug fix branches
- `hotfix/fix-name` - Urgent production fixes

Always create your branch from the most recent `develop` branch:

```bash
git checkout develop
git pull
git checkout -b feature/your-feature-name
```

### 2. Coding Standards

All code must adhere to our [Coding Standards](../CODING_STANDARDS.md). Key points:

- Follow ESLint and Prettier configurations
- Write comprehensive JSDoc comments
- Maintain the established folder structure
- Use the standardized logging patterns
- Follow the error handling guidelines

Run the linting tools before submitting your code:

```bash
npm run lint
npm run format
```

### 3. Creating a New Service

When creating a new microservice:

1. Follow the established folder structure:
   ```
   ServiceName/
   ├── src/
   │   ├── controllers/
   │   ├── middleware/
   │   ├── models/
   │   ├── routes/
   │   ├── services/
   │   └── index.js
   ```

2. Use the shared modules for common functionality:
   - Logging: `Shared/logger`
   - Configuration: `Shared/config`
   - Database access: `Shared/database`
   - Authentication: `Shared/middleware/authMiddleware`
   - Error handling: `Shared/middleware/errorMiddleware`
   - Request logging: `Shared/middleware/requestLoggerMiddleware`

3. Ensure your service is included in the Docker Compose configuration.

### 4. Testing

All code should be tested thoroughly:

- Write unit tests for business logic
- Write integration tests for API endpoints
- Ensure tests run in isolation

Run tests before submitting your changes:

```bash
npm test
```

For coverage reports:

```bash
npm run test:coverage
```

### 5. Pull Request Process

1. Ensure your code passes all tests and linting checks
2. Update relevant documentation
3. Create a pull request against the `develop` branch
4. Fill out the PR template with:
   - Description of changes
   - Issue reference
   - Testing steps
   - Screenshots (if applicable)

### 6. Code Review

All PRs require at least one review before merging. During code review:

- Explain your approach and design decisions
- Address feedback promptly
- Be open to suggestions and improvements

## Documentation

Update documentation when:

- Adding new features or endpoints
- Changing existing functionality
- Fixing bugs that affect behavior
- Adding or changing configuration options

Documentation should be updated in:

- JSDoc comments for API reference
- API documentation in Swagger
- Relevant markdown files in the `docs/` directory

## Shared Modules

When working with shared modules:

1. Consider backward compatibility
2. Test changes across all services
3. Document any breaking changes clearly

## Logging Guidelines

Follow these logging guidelines:

- Use appropriate log levels (`error`, `warn`, `info`, `http`, `debug`)
- Include context information with every log
- Don't log sensitive information
- Use structured logging format

Example:

```javascript
logger.info('User login successful', { 
  userId: user.id,
  service: 'AuthService'
});
```

## Environment Variables

When adding new environment variables:

1. Follow the naming conventions
2. Add the variable to the relevant `.env.example` files
3. Document the variable in the environment configuration guide
4. Provide sensible defaults when possible

## Committing Changes

Write clear, concise commit messages that explain what and why:

```
feat(auth): Add rate limiting to login endpoints

Adds rate limiting to prevent brute force attacks.
Includes configuration options and documentation.

Resolves: #123
```

Follow the conventional commit format:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting changes
- `refactor`: Code refactoring
- `test`: Adding or fixing tests
- `chore`: Maintenance tasks

## Versioning

We follow semantic versioning (MAJOR.MINOR.PATCH):

- MAJOR: Breaking changes
- MINOR: New features (backwards compatible)
- PATCH: Bug fixes (backwards compatible)

## Need Help?

If you need assistance:

- Check the documentation in the `docs/` directory
- Look for similar code in the existing codebase
- Ask for help from other contributors

## Security Issues

For security vulnerabilities, do not open a public issue. Instead, contact the team directly.