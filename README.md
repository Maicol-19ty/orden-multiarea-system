# Order Router - Multi-Area System with Timer

MVP "Enrutador de Órdenes Multiárea con Temporizador" - A professional Spring Boot application for routing orders across multiple areas with built-in timer functionality.

## Tech Stack

- **Backend**: Java 17 + Spring Boot 3.2.0
- **Build Tool**: Gradle (Kotlin DSL)
- **Database**: PostgreSQL
- **Database Migrations**: Flyway
- **Testing**: JUnit 5

## Prerequisites

Before running this application, ensure you have the following installed:

- Java 17 or higher ([Download](https://adoptium.net/))
- PostgreSQL 14 or higher ([Download](https://www.postgresql.org/download/))
- Git ([Download](https://git-scm.com/downloads))

## Quick Start (5 Steps)

### 1. Clone the repository
```bash
git clone https://github.com/Maicol-19ty/orden-multiarea-system.git
cd orden-multiarea-system
```

### 2. Create PostgreSQL database
```bash
# Login to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE orderrouter;

# Exit psql
\q
```

### 3. Configure environment variables
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your database credentials (use your preferred editor)
nano .env  # or use vim, vi, gedit, etc.
```

### 4. Build the application
```bash
# On Linux/Mac
./gradlew build

# On Windows
gradlew.bat build
```

### 5. Run the application
```bash
# On Linux/Mac
./gradlew bootRun

# On Windows
gradlew.bat bootRun
```

The application will start on `http://localhost:8080`

## Environment Variables

All required environment variables are listed in `.env.example`. Copy this file to `.env` and configure according to your setup:

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `SERVER_PORT` | Application server port | `8080` |
| `DB_HOST` | PostgreSQL host | `localhost` |
| `DB_PORT` | PostgreSQL port | `5432` |
| `DB_NAME` | Database name | `orderrouter` |
| `DB_USERNAME` | Database username | `postgres` |
| `DB_PASSWORD` | Database password | `postgres` |
| `JPA_SHOW_SQL` | Show SQL queries in logs | `false` |
| `LOG_LEVEL` | Root logging level | `INFO` |
| `APP_LOG_LEVEL` | Application logging level | `DEBUG` |
| `SPRING_PROFILES_ACTIVE` | Active Spring profile | `dev` |

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
│   │       └── templates/      # Templates
│   └── test/                   # Test classes
├── docs/                       # Documentation
│   ├── architecture.md         # Architecture details
│   └── api.md                  # API documentation
├── gradle/                     # Gradle wrapper
├── .env.example               # Environment variables template
├── .gitignore                 # Git ignore rules
├── LICENSE                    # MIT License
└── README.md                  # This file
```

## Database Migrations

Database migrations are managed automatically by Flyway. Migration files are located in `src/main/resources/db/migration/`.

The initial schema (`V1__initial_schema.sql`) creates:
- **areas**: Different processing areas
- **orders**: Order information and routing
- **order_timers**: Timer management for orders

Migrations run automatically on application startup.

## Development

### Run tests
```bash
./gradlew test
```

### Build without tests
```bash
./gradlew build -x test
```

### Clean build
```bash
./gradlew clean build
```

### Check for dependency updates
```bash
./gradlew dependencyUpdates
```

## Documentation

- [Architecture Overview](docs/architecture.md)
- [API Documentation](docs/api.md)

## Troubleshooting

### Database connection issues
- Verify PostgreSQL is running: `pg_isready`
- Check database credentials in `.env`
- Ensure database `orderrouter` exists

### Port already in use
- Change `SERVER_PORT` in `.env` to a different port
- Or stop the process using port 8080

### Build issues
- Ensure Java 17 is installed: `java -version`
- Clear Gradle cache: `./gradlew clean`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

For issues and questions, please open an issue in the GitHub repository.