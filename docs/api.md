# API Documentation

## Base URL
```
http://localhost:8080/api
```

## Health Check
```
GET /actuator/health
```

## Endpoints

### Areas

#### Get All Areas
```http
GET /api/areas
```

#### Create Area
```http
POST /api/areas
Content-Type: application/json

{
  "name": "Kitchen",
  "description": "Main kitchen area",
  "active": true
}
```

### Orders

#### Get All Orders
```http
GET /api/orders
```

#### Create Order
```http
POST /api/orders
Content-Type: application/json

{
  "orderNumber": "ORD-001",
  "areaId": 1,
  "status": "PENDING",
  "priority": 1
}
```

#### Get Order by ID
```http
GET /api/orders/{id}
```

### Order Timers

#### Start Timer
```http
POST /api/orders/{orderId}/timer
Content-Type: application/json

{
  "duration": 1800
}
```

#### Get Timer Status
```http
GET /api/orders/{orderId}/timer
```

## Response Formats

### Success Response
```json
{
  "status": "success",
  "data": { ... }
}
```

### Error Response
```json
{
  "status": "error",
  "message": "Error description",
  "timestamp": "2025-10-31T12:00:00Z"
}
```

## Status Codes
- `200 OK` - Successful request
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error
