---
applyTo: '**'
---
# MongoDB Structure Instructions for BIS System

## Collections Overview

### 1. Users Collection
```javascript
{
  _id: ObjectId,
  username: String,         // unique
  password: String,         // hashed
  name: String,
  contactNumber: String,
  role: String,            // enum: ['admin']
  createdAt: Date,
  updatedAt: Date
}

// Indexes
{ username: 1 }           // unique index
```

### 2. Requests Collection
```javascript
{
  _id: ObjectId,
  ref: String,            // format: REQ-YYYY-MM-#####
  fullName: String,
  contactNumber: String,
  address: String,
  purpose: String,
  eduAttainment: String,  // optional
  eduCourse: String,      // optional
  age: Number,
  maritalStatus: String,
  docTypeId: ObjectId,    // reference to DocumentTypes
  idImageUrl: String,     // URL to uploaded ID
  status: String,         // enum: ['pending', 'approved', 'rejected']
  createdAt: Date,
  updatedAt: Date,
  releasedAt: Date       // optional, when status changes to 'approved'
}

// Indexes
{ ref: 1 }              // unique index
{ status: 1 }          // for filtering
{ createdAt: -1 }      // for sorting by date
{ docTypeId: 1 }       // for document type lookups
```

### 3. Complaints Collection
```javascript
{
  _id: ObjectId,
  ref: String,          // format: CMPL-YYYY-MM-#####
  reporterName: String,
  contactNumber: String,
  address: String,
  complaintType: String,
  description: String,
  status: String,       // enum: ['pending', 'in_progress', 'resolved']
  createdAt: Date,
  updatedAt: Date,
  resolvedAt: Date      // optional, when status changes to 'resolved'
}

// Indexes
{ ref: 1 }            // unique index
{ status: 1 }        // for filtering
{ createdAt: -1 }    // for sorting by date
```

### 4. DocumentTypes Collection
```javascript
{
  _id: ObjectId,
  name: String,        // e.g., "Barangay Clearance"
  description: String,
  requirements: [String],
  fee: Number,         // optional
  createdAt: Date,
  updatedAt: Date
}

// Indexes
{ name: 1 }          // unique index
```

## Default Document Types
```javascript
[
  {
    name: "Barangay Clearance",
    description: "General purpose clearance for employment, scholarship, etc.",
    requirements: ["Valid ID", "Proof of Residence"]
  },
  {
    name: "Business Permit",
    description: "Required for operating businesses within the barangay",
    requirements: ["DTI/SEC Registration", "Valid ID", "Proof of Residence"]
  },
  {
    name: "Certificate of Indigency",
    description: "Certifies that the resident belongs to low-income category",
    requirements: ["Valid ID", "Proof of Residence", "Income Declaration"]
  },
  {
    name: "First-time Job Seeker",
    description: "Certification for first-time job seekers (RA 11261)",
    requirements: ["Valid ID", "Proof of Residence", "Affidavit of First-time Job Seeker"]
  }
]
```

## Reference Number Format

1. Requests:
   - Format: REQ-YYYY-MM-#####
   - Example: REQ-2025-10-00001

2. Complaints:
   - Format: CMPL-YYYY-MM-#####
   - Example: CMPL-2025-10-00001

## Validation Rules

### Users
- Username: Required, unique, minimum 4 characters
- Password: Required, minimum 8 characters, hashed before storage
- Name: Required
- Contact Number: Required, valid phone format
- Role: Required, must be 'admin'

### Requests
- Reference: Auto-generated, unique
- Full Name: Required
- Contact Number: Required, valid phone format
- Address: Required
- Purpose: Required
- Age: Required, numeric, > 0
- Document Type: Required, valid ObjectId reference
- Status: Required, valid enum value

### Complaints
- Reference: Auto-generated, unique
- Reporter Name: Required
- Contact Number: Required, valid phone format
- Address: Required
- Complaint Type: Required
- Description: Required
- Status: Required, valid enum value

### Document Types
- Name: Required, unique
- Description: Required
- Requirements: Array of strings, at least one item

## Data Relationships

1. Requests → Document Types (One-to-One)
   - Requests.docTypeId references DocumentTypes._id

## Analytics Considerations

1. Request Statistics:
   - Index on createdAt for date-based queries
   - Index on docTypeId for document type aggregation
   - Compound index {docTypeId: 1, createdAt: 1} for type-based timeline

2. Complaint Resolution:
   - Index on status for quick filtering
   - Index on resolvedAt for resolution time analysis

## Backup Strategy

1. Daily Backups:
   - All collections
   - Store for 30 days

2. Weekly Backups:
   - Store for 3 months

3. Monthly Backups:
   - Store for 1 year

## Data Retention Policy

1. Requests:
   - Keep all approved/rejected requests for 5 years
   - Archive after 5 years

2. Complaints:
   - Keep resolved complaints for 3 years
   - Archive after 3 years

3. Users:
   - Keep indefinitely
   - Maintain audit log of role changes

4. Document Types:
   - Keep indefinitely
   - Maintain version history of requirement changes

## Security Considerations

1. Data Encryption:
   - Passwords must be hashed (bcrypt)
   - Sensitive fields should use encryption at rest

2. Access Control:
   - Only admin users can access all collections
   - Public endpoints limited to request creation and status checking

3. Rate Limiting:
   - Implement rate limiting on public endpoints
   - Track requests by IP and token

## Implementation Notes

1. Use Mongoose schemas with:
   - Timestamps plugin
   - Validation middleware
   - Pre-save hooks for reference generation

2. Implement soft deletion where appropriate:
   - Add isDeleted flag
   - Add deletedAt timestamp
   - Filter deleted items in queries

3. Use transactions for operations affecting multiple collections

4. Implement proper error handling and validation at the database level

---

This document serves as a reference for implementing and maintaining the MongoDB database structure for the BIS System. Follow these guidelines when making changes to ensure data consistency and proper functionality.