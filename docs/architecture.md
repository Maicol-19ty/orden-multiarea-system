# Architecture Overview

## System Description
MVP "Enrutador de Órdenes Multiárea con Temporizador" (Multi-Area Order Router with Timer)

## Technology Stack
- **Backend Framework**: Spring Boot 3.2.0
- **Language**: Java 17
- **Build Tool**: Gradle (Kotlin DSL)
- **Database**: PostgreSQL
- **Database Migrations**: Flyway
- **Testing**: JUnit 5

## Project Structure
```
.
├── src/
│   ├── main/
│   │   ├── java/com/multiarea/orderrouter/
│   │   │   ├── config/         # Configuration classes
│   │   │   ├── controller/     # REST controllers
│   │   │   ├── dto/            # Data Transfer Objects
│   │   │   ├── exception/      # Custom exceptions
│   │   │   ├── model/          # JPA entities
│   │   │   ├── repository/     # Data repositories
│   │   │   └── service/        # Business logic
│   │   └── resources/
│   │       ├── db/migration/   # Flyway SQL migrations
│   │       ├── static/         # Static resources
│   │       └── templates/      # Templates (if needed)
│   └── test/                   # Test classes
├── docs/                       # Documentation
├── gradle/                     # Gradle wrapper
├── .env.example               # Environment variables template
└── README.md                  # Project documentation
```

## Key Components

### Order Router
Routes orders to different areas based on business rules and priorities.

### Timer System
Manages order expiration times and automated transitions based on time constraints.

### Areas
Different zones or departments where orders can be routed.

## Database Schema
See `src/main/resources/db/migration/` for the complete database schema.

Key tables:
- **areas**: Different processing areas
- **orders**: Order information and routing
- **order_timers**: Timer management for orders
