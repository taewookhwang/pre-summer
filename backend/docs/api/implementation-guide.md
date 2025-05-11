# API Implementation Guide

This document provides implementation details for both iOS and backend developers to ensure the API contract is properly maintained.

## General API Conventions

1. All response bodies include a `success` boolean field indicating the status of the operation
2. All property names follow snake_case naming convention
3. All date/time fields use ISO 8601 format (YYYY-MM-DDThh:mm:ssZ)
4. Paginated responses include pagination metadata
5. Error responses include code and message fields

## iOS Implementation

### Response and Request Structure Handling

The iOS app needs to properly handle the snake_case to camelCase conversion:

```swift
// Configure JSONDecoder for snake_case to camelCase conversion
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase

// Example model
struct AuthResponse: Decodable {
    let success: Bool
    let accessToken: String
    let refreshToken: String
    let user: User
}

// For requests, convert camelCase to snake_case
let encoder = JSONEncoder()
encoder.keyEncodingStrategy = .convertToSnakeCase
```

### Authentication

The iOS app should implement the auth flow as follows:

```swift
// Login and store tokens
func login(email: String, password: String) -> AnyPublisher<User, Error> {
    return authAPI.login(email: email, password: password)
        .map { authResponse in
            // Verify success flag
            guard authResponse.success else {
                throw APIError.serverError("Login failed")
            }

            // Store tokens securely
            KeychainManager.shared.saveToken(token: authResponse.accessToken, type: .access)
            KeychainManager.shared.saveToken(token: authResponse.refreshToken, type: .refresh)
            return authResponse.user
        }
        .eraseToAnyPublisher()
}

// Add auth header to requests
func addAuthHeader(request: inout URLRequest) {
    if let token = KeychainManager.shared.getToken(type: .access) {
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

// Handle token refresh
func refreshTokenIfNeeded() -> AnyPublisher<Void, Error> {
    guard let refreshToken = KeychainManager.shared.getToken(type: .refresh) else {
        return Fail(error: AuthError.missingRefreshToken).eraseToAnyPublisher()
    }

    return authAPI.refreshToken(refreshToken: refreshToken)
        .map { response in
            // Verify success flag
            guard response.success else {
                throw APIError.unauthorized
            }

            KeychainManager.shared.saveToken(token: response.accessToken, type: .access)
            return
        }
        .eraseToAnyPublisher()
}
```

### Error Handling

Implement a consistent error handling approach:

```swift
enum APIError: Error {
    case networkError(Error)
    case httpError(Int)
    case decodingError(Error)
    case invalidResponse
    case unauthorized
    case serverError(String)
    case validationError(String)
    case unknown

    var userMessage: String {
        switch self {
        case .unauthorized:
            return "Session expired. Please log in again."
        case .networkError:
            return "Network connection problem. Please check your internet connection."
        case .validationError(let message):
            return message
        // Additional cases...
        default:
            return "Something went wrong. Please try again later."
        }
    }
}

// Check success flag in responses
func validateResponse<T: Decodable>(data: Data) throws -> T {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    let response = try decoder.decode(T.self, from: data)

    // For responses that have a success field, check it
    if let successCheck = response as? { success: Bool } {
        guard successCheck.success else {
            throw APIError.serverError("Operation failed")
        }
    }

    return response
}
```

### Making API Requests

Structure API requests consistently:

```swift
func getJobs(page: Int, limit: Int, status: String? = nil) -> AnyPublisher<PaginatedResponse<Job>, APIError> {
    var queryItems = [
        URLQueryItem(name: "page", value: "\(page)"),
        URLQueryItem(name: "limit", value: "\(limit)")
    ]

    if let status = status {
        queryItems.append(URLQueryItem(name: "status", value: status))
    }

    return makeRequest(
        endpoint: "technicians/jobs",
        method: .get,
        queryItems: queryItems
    )
    .map { (response: PaginatedResponse<Job>) in
        // Always check success flag in responses
        guard response.success else {
            throw APIError.serverError("Failed to get jobs")
        }
        return response
    }
    .eraseToAnyPublisher()
}
```

## Backend Implementation

### Response Format

All responses should follow consistent formats with success field and snake_case naming:

```javascript
// Success response
res.status(200).json({
  success: true,
  data: result,
  pagination: {
    page: parseInt(page),
    limit: parseInt(limit),
    total_items: count,
    total_pages: Math.ceil(count / parseInt(limit)),
  },
});

// Error response
res.status(400).json({
  success: false,
  code: 'validation/invalid_input',
  message: 'The provided email is not valid',
});
```

### Authentication Middleware

```javascript
// Example Express middleware (Node.js)
const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        code: 'auth/missing_token',
        message: 'Authentication token is missing',
      });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        code: 'auth/token_expired',
        message: 'Authentication token has expired',
      });
    }

    return res.status(401).json({
      success: false,
      code: 'auth/invalid_token',
      message: 'Invalid authentication token',
    });
  }
};
```

### Request Validation

Implement validation for each endpoint:

```javascript
// Example using Express validator
const { body, validationResult } = require('express-validator');

app.post(
  '/auth/login',
  [
    body('email').isEmail().withMessage('Valid email is required'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  ],
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        code: 'validation/invalid_input',
        message: errors.array()[0].msg,
      });
    }

    // Process login...
    // On success:
    res.status(200).json({
      success: true,
      access_token: '...',
      refresh_token: '...',
      user: {
        id: '...',
        email: 'user@example.com',
        name: 'User Name',
        role: 'consumer',
      },
    });
  },
);
```

## Testing the Integration

Both teams should create integration tests to verify:

1. Request formats match the specification
2. Response formats match the specification (including success field and snake_case)
3. Authentication works as expected
4. Error responses are consistent
5. Edge cases are handled correctly

## Example Responses

### Successful Login Response

```json
{
  "success": true,
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "123",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "consumer",
    "profile_image": "https://example.com/images/profile.jpg"
  }
}
```

### Error Response

```json
{
  "success": false,
  "code": "auth/invalid_credentials",
  "message": "The email or password you entered is incorrect"
}
```

### Paginated Response

```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "name": "Regular Cleaning",
      "description": "Standard cleaning service",
      "price": 120.0,
      "duration": 120,
      "image_url": "https://example.com/images/regular-cleaning.jpg"
    },
    {
      "id": "2",
      "name": "Deep Cleaning",
      "description": "Thorough cleaning service",
      "price": 200.0,
      "duration": 240,
      "image_url": "https://example.com/images/deep-cleaning.jpg"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total_items": 8,
    "total_pages": 1
  }
}
```

## Versioning Strategy

API versioning is implemented in the URL path (/v1/resource). When making non-backward compatible changes:

1. Increment the version number
2. Support previous versions for a deprecation period
3. Document changes clearly
4. Provide migration guides

## Synchronization Process

To stay in sync:

1. Both teams should review this documentation regularly
2. Use pull requests to propose API changes
3. Tag API changes with version numbers
4. Maintain a changelog of API changes
5. Implement automated testing of API contracts
