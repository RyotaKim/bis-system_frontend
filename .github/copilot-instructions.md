# AI Development Instructions for BIS System Backend

## Project Overview
This is the backend component of the Business Information System (BIS). The project is structured as a Node.js application, currently in its initial setup phase.

## Architecture and Structure
- Main entry point: `index.js` in the root directory
- Package configuration: `package.json` defines project metadata and dependencies

## Development Workflows

### Setting Up the Project
```bash
npm install
```

### Development Best Practices
1. **Code Organization**
   - Place route handlers in a `routes/` directory
   - Group database models in a `models/` directory
   - Keep business logic in a `services/` directory
   - Store configuration in a `config/` directory

2. **API Design**
   - Follow RESTful conventions
   - Use consistent endpoint naming patterns
   - Group related endpoints under common prefixes

3. **Error Handling**
   - Implement centralized error handling middleware
   - Use standardized error response format

4. **Environment Configuration**
   - Use `.env` files for environment variables
   - Never commit sensitive credentials
   - Document required environment variables

## Integration Points
- Document external service integrations here as they are added
- List API endpoints and their purposes
- Specify authentication methods

## Key Files and Directories
- `index.js`: Application entry point
- `package.json`: Project configuration and dependencies

## Conventions
- Use async/await for asynchronous operations
- Follow Node.js best practices for error handling
- Implement proper logging mechanisms
- Use proper HTTP status codes

## Notes for AI Assistance
- When implementing new features, create necessary directory structure if not exists
- Follow established patterns for consistency
- Ensure proper error handling in all new endpoints
- Add appropriate logging statements
- Update documentation when adding new endpoints or features

*This is a living document - update as patterns and practices emerge during development.*