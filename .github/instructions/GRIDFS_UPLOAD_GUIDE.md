# GridFS File Upload Documentation

## Overview
The BIS System now uses MongoDB GridFS to store uploaded ID images directly in the database. This eliminates the need for separate file storage services.

## Features
- ✅ Store images in MongoDB using GridFS
- ✅ Maximum file size: 5MB
- ✅ Accepts image files only (jpg, png, gif, etc.)
- ✅ Automatic file cleanup when request is deleted
- ✅ File streaming for efficient downloads

## API Endpoints

### 1. File a Request with Image Upload
**Endpoint:** `POST /api/resident/request`

**Content-Type:** `multipart/form-data`

**Form Fields:**
- `fullName` (string, required)
- `contactNumber` (string, required)
- `address` (string, required)
- `purpose` (string, required)
- `age` (number, required)
- `docTypeId` (ObjectId, required)
- `eduAttainment` (string, optional)
- `eduCourse` (string, optional)
- `maritalStatus` (string, optional)
- `idImage` (file, required) - The uploaded image file

**Example using JavaScript Fetch:**
```javascript
const formData = new FormData();
formData.append('fullName', 'Juan Dela Cruz');
formData.append('contactNumber', '09171234567');
formData.append('address', '123 Main St, Barangay Sample');
formData.append('purpose', 'Employment');
formData.append('age', '25');
formData.append('docTypeId', '507f1f77bcf86cd799439011');
formData.append('idImage', fileInput.files[0]); // File from input element

const response = await fetch('http://localhost:3000/api/resident/request', {
  method: 'POST',
  body: formData
});

const result = await response.json();
console.log(result);
```

**Example Response:**
```json
{
  "message": "Request filed successfully",
  "request": {
    "_id": "507f1f77bcf86cd799439011",
    "ref": "REQ-2025-11-00001",
    "fullName": "Juan Dela Cruz",
    "contactNumber": "09171234567",
    "address": "123 Main St, Barangay Sample",
    "purpose": "Employment",
    "age": 25,
    "docTypeId": "507f1f77bcf86cd799439011",
    "uploadedFileId": "507f191e810c19729de860ea",
    "idImageUrl": "/api/files/507f191e810c19729de860ea",
    "status": "pending",
    "createdAt": "2025-11-13T10:30:00.000Z",
    "updatedAt": "2025-11-13T10:30:00.000Z"
  },
  "ref": "REQ-2025-11-00001"
}
```

### 2. Download/View Uploaded Image
**Endpoint:** `GET /api/files/:id`

**Parameters:**
- `id` - The GridFS file ID (from `uploadedFileId` or extracted from `idImageUrl`)

**Example:**
```html
<!-- Direct image display -->
<img src="http://localhost:3000/api/files/507f191e810c19729de860ea" alt="ID Image">
```

```javascript
// Download file
const fileId = '507f191e810c19729de860ea';
window.open(`http://localhost:3000/api/files/${fileId}`, '_blank');
```

### 3. Get Request with Image URL (Admin)
**Endpoint:** `GET /api/admin/requests/:id`

**Headers:**
```
Authorization: Bearer <admin_jwt_token>
```

**Response includes `idImageUrl`:**
```json
{
  "request": {
    "_id": "507f1f77bcf86cd799439011",
    "ref": "REQ-2025-11-00001",
    "fullName": "Juan Dela Cruz",
    "uploadedFileId": "507f191e810c19729de860ea",
    "idImageUrl": "/api/files/507f191e810c19729de860ea",
    ...
  }
}
```

### 4. Get All Requests with Image URLs (Admin)
**Endpoint:** `GET /api/admin/requests`

**Headers:**
```
Authorization: Bearer <admin_jwt_token>
```

All requests in the array will include `idImageUrl` if they have an uploaded file.

## Frontend Integration

### React Example
```jsx
import React, { useState } from 'react';

function FileRequestForm() {
  const [formData, setFormData] = useState({
    fullName: '',
    contactNumber: '',
    address: '',
    purpose: '',
    age: '',
    docTypeId: ''
  });
  const [file, setFile] = useState(null);

  const handleFileChange = (e) => {
    setFile(e.target.files[0]);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    const data = new FormData();
    Object.keys(formData).forEach(key => {
      data.append(key, formData[key]);
    });
    data.append('idImage', file);

    try {
      const response = await fetch('http://localhost:3000/api/resident/request', {
        method: 'POST',
        body: data
      });
      
      const result = await response.json();
      console.log('Request submitted:', result);
      alert(`Request submitted! Reference: ${result.ref}`);
    } catch (error) {
      console.error('Error:', error);
      alert('Error submitting request');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Form inputs... */}
      <input 
        type="file" 
        accept="image/*" 
        onChange={handleFileChange} 
        required 
      />
      <button type="submit">Submit Request</button>
    </form>
  );
}
```

### Flutter Example
```dart
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';

Future<void> submitRequest(File imageFile) async {
  var uri = Uri.parse('http://localhost:3000/api/resident/request');
  var request = http.MultipartRequest('POST', uri);
  
  // Add text fields
  request.fields['fullName'] = 'Juan Dela Cruz';
  request.fields['contactNumber'] = '09171234567';
  request.fields['address'] = '123 Main St';
  request.fields['purpose'] = 'Employment';
  request.fields['age'] = '25';
  request.fields['docTypeId'] = '507f1f77bcf86cd799439011';
  
  // Add image file
  request.files.add(await http.MultipartFile.fromPath(
    'idImage',
    imageFile.path,
    contentType: MediaType('image', 'jpeg'),
  ));
  
  var response = await request.send();
  var responseData = await response.stream.bytesToString();
  print(responseData);
}
```

## File Validation
- **Accepted formats:** image/jpeg, image/png, image/gif, image/webp, etc.
- **Maximum size:** 5MB
- **Required:** Yes, idImage field is mandatory

## Error Handling

### Common Errors

**400 - Missing ID Image:**
```json
{
  "message": "ID image is required"
}
```

**400 - Invalid File Type:**
```json
{
  "message": "Only image files are allowed!"
}
```

**413 - File Too Large:**
```json
{
  "message": "File too large"
}
```

**404 - File Not Found:**
```json
{
  "message": "File not found"
}
```

## MongoDB GridFS Collections

GridFS creates two collections:
- `uploads.files` - File metadata
- `uploads.chunks` - File data chunks (256KB each)

## Testing with Postman

1. Create a new POST request to `http://localhost:3000/api/resident/request`
2. Set body type to `form-data`
3. Add text fields (fullName, contactNumber, etc.)
4. Add a file field named `idImage` and select an image
5. Send the request
6. Copy the `idImageUrl` from response
7. Open it in browser or create a GET request to view the image

## Notes
- Files are automatically deleted from GridFS when a request is deleted
- Images are served with appropriate content-type headers
- GridFS efficiently handles large files by chunking them
- All timestamps use Philippine Time (UTC+8)

## Security Considerations
- File type validation prevents non-image uploads
- File size limits prevent abuse
- Consider adding virus scanning for production
- Add rate limiting on upload endpoints for production
