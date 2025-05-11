# API Documentation

This directory contains the OpenAPI/Swagger specification for the Home Cleaning App API. This documentation serves as a contract between the iOS frontend and backend services.

## Files

- `swagger.yaml` - OpenAPI 3.0 specification detailing all API endpoints, request/response models, and authentication requirements

## How to Use

### For iOS Developers

1. Reference this documentation when implementing new API calls or updating existing ones
2. Ensure DTOs match the schemas defined in the specification
3. Follow the authentication patterns described in the specification

### For Backend Developers

1. Implement API endpoints according to the specification
2. Validate request and response formats against the schemas
3. Ensure authentication middleware validates tokens as specified

## Viewing the Documentation

You can use various tools to view this documentation in a more user-friendly format:

- [Swagger UI](https://swagger.io/tools/swagger-ui/) - Web-based viewer
- [Redoc](https://github.com/Redocly/redoc) - Alternative web-based viewer
- [Stoplight Studio](https://stoplight.io/studio) - Desktop application for viewing and editing
- [Swagger Editor](https://editor.swagger.io/) - Web-based editor with live preview

Example of importing into Swagger UI:

```
docker run -p 80:8080 -e SWAGGER_JSON=/foo/swagger.yaml -v $(pwd):/foo swaggerapi/swagger-ui
```

## Keeping in Sync

Both iOS and backend teams should:

1. Propose changes to this specification before implementing them
2. Update the specification when API changes are made
3. Use this as the single source of truth for API contracts
4. Tag versions of the API spec to match release versions

## Schema Information

The specification includes models for:

- Authentication (login, token refresh)
- Services (cleaning service types)
- Reservations and jobs
- Users (consumers, technicians, admins)
- Payments and reviews
- Error responses
- Pagination

## Authentication

The API uses JWT token authentication:

- Obtain tokens via `/auth/login`
- Refresh expired tokens via `/auth/refresh`
- Include token in Authorization header for protected endpoints

## Error Handling

All errors follow a standard format with code and message fields. Common HTTP status codes:

- 200/201: Success
- 400: Bad request or validation error
- 401: Authentication error
- 403: Permission error
- 404: Resource not found
- 500: Server error
