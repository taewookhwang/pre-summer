# Migration Guide: Backend Standardization

This guide provides instructions for migrating existing code to the new standardized patterns introduced in the backend standardization project.

## Table of Contents

- [Overview](#overview)
- [Logger Migration](#logger-migration)
- [Configuration Migration](#configuration-migration)
- [Error Handling Migration](#error-handling-migration)
- [Middleware Migration](#middleware-migration)
- [Response Formatting Migration](#response-formatting-migration)
- [Testing Migration](#testing-migration)
- [Documentation Migration](#documentation-migration)

## Overview

The standardization project introduces several changes that existing code needs to adapt to:

1. New shared modules for common functionality
2. Standardized patterns for logging, configuration, and error handling
3. Consistent API response formatting
4. Updated ESLint and Prettier configurations
5. Standardized folder structure

This guide provides step-by-step instructions for migrating each aspect of your code.

## Logger Migration

### Before
```javascript
console.log('User logged in:', userId);
console.error('Error processing payment:', error);
```

### After
```javascript
const logger = require('../../../Shared/logger');

// Informational logs
logger.info('User logged in', { userId, service: 'AuthService' });

// Error logs
logger.error('Error processing payment', { 
  error: error.message,
  stack: error.stack,
  userId,
  service: 'PaymentService'
});

// Request logs
logger.http('Incoming request', {
  method: req.method,
  path: req.path,
  ip: req.ip,
  service: 'Gateway'
});
```

### Migration Steps

1. Import the shared logger module at the top of your file
2. Replace all `console.log` calls with appropriate log level methods
3. Add context objects with relevant information
4. Add service name to all log entries
5. Use proper log levels according to the [Logging Guide](./docs/logging-guide.md)

## Configuration Migration

### Before
```javascript
require('dotenv').config();

const PORT = process.env.PORT || 3000;
const DB_HOST = process.env.DB_HOST || 'localhost';
```

### After
```javascript
const config = require('../../../Shared/config');

const PORT = config.get('PORT', 3000);
const DB_HOST = config.get('DB_HOST', 'localhost');
const DB_CONFIG = config.getByPrefix('DB_');
```

### Migration Steps

1. Remove direct `dotenv` configuration in service files
2. Import the shared config module
3. Replace `process.env` access with `config.get()` methods
4. Use `getByPrefix()` for grouped configuration
5. Update environment variables according to the new naming conventions

## Error Handling Migration

### Before
```javascript
try {
  // Code that might throw
} catch (error) {
  console.error('Error:', error);
  res.status(500).json({ success: false, message: 'Internal server error' });
}
```

### After
```javascript
const { AppError, NotFoundError } = require('../../../Shared/errors');
const errorMiddleware = require('../../../Shared/middleware/errorMiddleware');

// In routes setup
app.use(errorMiddleware);

// In controller
try {
  const user = await userService.findById(id);
  if (!user) {
    throw new NotFoundError('User not found');
  }
  // Rest of the code
} catch (error) {
  // Just throw the error, middleware will handle it
  throw error;
}
```

### Migration Steps

1. Import the shared error classes
2. Add the error middleware to your Express app
3. Replace manual error handling with appropriate error classes
4. Remove try/catch blocks that only log and return generic errors

## Middleware Migration

### Before
```javascript
// auth.js
const jwt = require('jsonwebtoken');

const auth = (req, res, next) => {
  try {
    const token = req.header('Authorization').replace('Bearer ', '');
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ success: false, message: 'Authentication failed' });
  }
};
```

### After
```javascript
// Use the shared middleware
const { authMiddleware } = require('../../../Shared/middleware');

// In routes setup
router.get('/protected', authMiddleware, controllerFunction);
```

### Migration Steps

1. Import shared middleware modules
2. Replace service-specific middlewares with shared ones
3. Update route configurations to use the shared middleware
4. Remove duplicate middleware files

## Response Formatting Migration

### Before
```javascript
res.status(200).json({
  success: true,
  data: users
});

res.status(400).json({
  success: false,
  message: 'Invalid input'
});
```

### After
```javascript
const { response } = require('../../../Shared/utils');

// Success response
res.status(200).json(response.success(users));

// Error response
res.status(400).json(response.error('Invalid input', 400));

// Paginated response
res.status(200).json(response.paginated(
  users,
  page,
  limit,
  total,
  'Users retrieved successfully'
));
```

### Migration Steps

1. Import the shared response utilities
2. Replace direct response objects with utility functions
3. Ensure consistent response structure across all endpoints

## Testing Migration

### Before (inconsistent testing patterns)

### After
```javascript
const request = require('supertest');
const app = require('../app');
const { setupTestDb, teardownTestDb } = require('../../tests/helpers/db');
const { mockUser } = require('../../tests/fixtures/users');

describe('User API', () => {
  beforeAll(async () => {
    await setupTestDb();
  });

  afterAll(async () => {
    await teardownTestDb();
  });

  it('should create a new user', async () => {
    const response = await request(app)
      .post('/api/users')
      .send(mockUser)
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.data).toHaveProperty('id');
  });
});
```

### Migration Steps

1. Create proper test directories (`unit`, `integration`, `fixtures`, `helpers`)
2. Use standard test helpers for database setup and teardown
3. Create fixtures for test data
4. Follow consistent testing patterns

## Documentation Migration

### Before (inconsistent or missing documentation)

### After
```javascript
/**
 * Creates a new user in the system
 * 
 * @param {Object} req - Express request object
 * @param {Object} req.body - Request body
 * @param {string} req.body.email - User email
 * @param {string} req.body.password - User password
 * @param {string} req.body.name - User's full name
 * @param {Object} res - Express response object
 * @returns {Promise<void>} - Nothing
 * @throws {ValidationError} If the input is invalid
 * @throws {ConflictError} If the email is already in use
 */
const createUser = async (req, res) => {
  // Implementation
};
```

### Migration Steps

1. Add JSDoc comments to all functions, classes, and modules
2. Follow the JSDoc style guide for consistent documentation
3. Update API documentation in Swagger files
4. Create or update README files for all services

## Final Steps

After migrating all aspects of your code:

1. Run linting to ensure compliance with the new standards:
   ```bash
   npm run lint
   ```

2. Fix any linting issues:
   ```bash
   npm run lint:fix
   ```

3. Run tests to ensure everything works:
   ```bash
   npm test
   ```

4. Document any specific migration steps for your service in a service-level README

## Need Help?

If you encounter issues during migration:

1. Check the comprehensive documentation in the `docs/` directory
2. Look at the example implementations in the updated services
3. Contact the standardization team for assistance