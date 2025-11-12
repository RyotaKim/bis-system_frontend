# BIS System Backend API

A Node.js/Express backend for the Barangay Information System (BIS) with MongoDB integration. Supports resident request filing, complaint management, and admin dashboard features.

## Features

✅ **Resident Module**
- File requests for Barangay documents
- Check request status via reference number

✅ **Admin Module**
- User authentication with JWT
- Dashboard statistics
- Request management (view, edit status, delete)
- Complaint management (view, edit status, delete)
- Analytics and reporting

✅ **Security**
- Password hashing with bcrypt
- JWT token-based authentication
- Role-based access control (admin only)
- CORS enabled for frontend access

## Project Structure

```
backend_bis/
├── models/          # Mongoose schemas
│   ├── User.js
│   ├── Request.js
│   ├── Complaint.js
│   └── DocumentType.js
├── controllers/     # Business logic
│   ├── authController.js
│   ├── residentController.js
│   ├── adminController.js
│   └── analyticsController.js
├── routes/          # API routes
│   ├── auth.js
│   ├── resident.js
│   ├── admin.js
│   ├── analytics.js
│   └── documentTypes.js
├── services/        # Utilities and helpers
│   ├── authService.js
│   ├── referenceService.js
│   └── seedService.js
├── middleware/      # Express middleware
│   └── auth.js
├── config/          # Configuration files
│   └── database.js
├── index.js         # Application entry point
├── package.json     # Dependencies
└── .env             # Environment variables
```

## Setup Instructions

### Prerequisites
- Node.js v14+
- MongoDB Atlas account (or local MongoDB)
- npm or yarn

### Installation

1. Clone the repository:
```bash
git clone https://github.com/RyotaKim/BIS-SYSTEM---BACKEND.git
cd backend_bis
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file with your configuration:
```bash
PORT=3000
MONGODB_URI=mongodb+srv://your-username:your-password@your-cluster.mongodb.net/BIS
JWT_SECRET=your-super-secret-key-here
NODE_ENV=development
```

4. Start the server:
```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

The server will run on `http://localhost:3000`

## API Endpoints

### Authentication

#### Admin Login
```
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "password123"
}

Response:
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "name": "Admin User",
    "role": "admin",
    "username": "admin"
  }
}
```

#### Admin Registration
```
POST /api/auth/register
Content-Type: application/json

{
  "username": "admin",
  "password": "password123",
  "name": "Admin User",
  "contactNumber": "+1234567890"
}

Response:
{
  "message": "Admin user created",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "name": "Admin User",
    "username": "admin"
  }
}
```

### Resident Routes (No Authentication)

#### File a Request
```
POST /api/resident/request
Content-Type: application/json

{
  "fullName": "John Doe",
  "contactNumber": "09123456789",
  "address": "123 Main St",
  "purpose": "Employment",
  "eduAttainment": "Bachelor's Degree",
  "eduCourse": "Computer Science",
  "age": 25,
  "maritalStatus": "Single",
  "docTypeId": "507f1f77bcf86cd799439011"
}

Response:
{
  "message": "Request filed successfully",
  "ref": "REQ-2025-10-00001",
  "request": { ... }
}
```

#### Check Request Status
```
GET /api/resident/request/status?ref=REQ-2025-10-00001

Response:
{
  "request": {
    "_id": "507f1f77bcf86cd799439011",
    "ref": "REQ-2025-10-00001",
    "fullName": "John Doe",
    "status": "pending",
    "createdAt": "2025-10-21T10:00:00Z",
    ...
  }
}
```

### Document Types (Public)

#### Get All Document Types
```
GET /api/document-types

Response:
{
  "docTypes": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Barangay Clearance",
      "description": "Document certifying residency and good moral character"
    },
    ...
  ]
}
```

### Admin Routes (Requires JWT Token)

**Authentication Header:**
```
Authorization: Bearer <your-jwt-token>
```

#### Dashboard Statistics
```
GET /api/admin/dashboard

Response:
{
  "totalRequests": 150,
  "totalComplaints": 45,
  "pendingRequests": 30,
  "resolvedComplaints": 40,
  "approvedRequests": 100,
  "rejectedRequests": 20
}
```

#### Get All Requests
```
GET /api/admin/requests

Response:
{
  "requests": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "ref": "REQ-2025-10-00001",
      "fullName": "John Doe",
      "contactNumber": "09123456789",
      "docTypeId": { "name": "Barangay Clearance", ... },
      "status": "pending",
      "createdAt": "2025-10-21T10:00:00Z",
      ...
    },
    ...
  ]
}
```

#### Get Request by ID
```
GET /api/admin/requests/:id

Response:
{
  "request": { ... }
}
```

#### Update Request Status
```
PUT /api/admin/requests/:id/status
Content-Type: application/json

{
  "status": "approved"
}

Response:
{
  "message": "Request status updated",
  "request": { ... }
}
```

#### Delete Request
```
DELETE /api/admin/requests/:id

Response:
{
  "message": "Request deleted successfully",
  "request": { ... }
}
```

#### Get All Complaints
```
GET /api/admin/complaints

Response:
{
  "complaints": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "ref": "CMPL-2025-10-00001",
      "reporterName": "Jane Doe",
      "complaintType": "Noise",
      "status": "pending",
      "createdAt": "2025-10-21T10:00:00Z",
      ...
    },
    ...
  ]
}
```

#### Get Complaint by ID
```
GET /api/admin/complaints/:id

Response:
{
  "complaint": { ... }
}
```

#### Update Complaint Status
```
PUT /api/admin/complaints/:id/status
Content-Type: application/json

{
  "status": "resolved"
}

Response:
{
  "message": "Complaint status updated",
  "complaint": { ... }
}
```

#### Delete Complaint
```
DELETE /api/admin/complaints/:id

Response:
{
  "message": "Complaint deleted successfully",
  "complaint": { ... }
}
```

#### Encode a Complaint (Admin Only)
```
POST /api/admin/complaints
Content-Type: application/json
Authorization: Bearer <your-jwt-token>

{
  "reporterName": "Maria Santos",
  "contactNumber": "09198765432",
  "address": "456 Oak Avenue",
  "complaintType": "Noise Disturbance",
  "description": "Loud music and parties until late night from the neighboring house"
}

Response:
{
  "message": "Complaint encoded successfully",
  "ref": "CMPL-2025-10-00001",
  "complaint": { ... }
}
```

### Analytics Routes (Requires JWT Token)

#### Weekly Request Statistics
```
GET /api/analytics/weekly-requests

Response:
{
  "requestStats": [
    {
      "_id": {
        "date": "2025-10-21",
        "docType": "Barangay Clearance"
      },
      "count": 5
    },
    ...
  ]
}
```

#### Complaint Resolution Rate
```
GET /api/analytics/complaint-resolution

Response:
{
  "complaintStats": [
    {
      "_id": {
        "date": "2025-10-21",
        "status": "resolved"
      },
      "count": 3
    },
    ...
  ]
}
```

#### All Analytics
```
GET /api/analytics/all

Response:
{
  "requestStats": [ ... ],
  "complaintStats": [ ... ],
  "summary": {
    "totalRequests": 150,
    "totalComplaints": 45,
    "pendingRequests": 30,
    "resolvedComplaints": 40
  }
}
```

## Database Models

### User
```javascript
{
  _id: ObjectId,
  username: String (unique),
  passwordHash: String,
  role: String (enum: ['admin', 'resident']),
  name: String,
  contactNumber: String,
  createdAt: Date,
  updatedAt: Date
}
```

### DocumentType
```javascript
{
  _id: ObjectId,
  name: String (unique),
  description: String,
  createdAt: Date,
  updatedAt: Date
}
```

### Request
```javascript
{
  _id: ObjectId,
  ref: String (unique),
  userId: ObjectId (FK -> User),
  fullName: String,
  contactNumber: String,
  address: String,
  purpose: String,
  eduAttainment: String,
  eduCourse: String,
  age: Number,
  maritalStatus: String,
  docTypeId: ObjectId (FK -> DocumentType),
  uploadedFileId: ObjectId,
  status: String (enum: ['pending', 'approved', 'rejected']),
  createdAt: Date,
  updatedAt: Date
}
```

### Complaint
```javascript
{
  _id: ObjectId,
  ref: String (unique),
  reporterName: String,
  contactNumber: String,
  address: String,
  complaintType: String,
  description: String,
  status: String (enum: ['pending', 'in_progress', 'resolved']),
  createdAt: Date,
  updatedAt: Date
}
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | Server port | 3000 |
| MONGODB_URI | MongoDB connection string | - |
| MONGODB_TEST_URI | MongoDB test connection string | - |
| NODE_ENV | Environment (development/production) | development |
| JWT_SECRET | Secret key for JWT signing | your-secret-key |

## Error Handling

All errors return a JSON response with a message:
```json
{
  "message": "Error description"
}
```

Common HTTP status codes:
- 200: Success
- 201: Created
- 400: Bad request
- 401: Unauthorized
- 403: Forbidden
- 404: Not found
- 500: Server error

## Future Enhancements

- [ ] File upload handling with GridFS
- [ ] Email notifications
- [ ] SMS alerts
- [ ] Advanced analytics dashboard
- [ ] Audit logging
- [ ] Rate limiting
- [ ] Advanced search and filtering
- [ ] Batch operations
- [ ] Export functionality (PDF, CSV)
- [ ] Mobile app API

## License

ISC

## Support

For issues and questions, please refer to the GitHub repository:
https://github.com/RyotaKim/BIS-SYSTEM---BACKEND
