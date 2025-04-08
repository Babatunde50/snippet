# Snippet

Snippet is a secure and robust web application for creating, storing, and sharing text snippets. Built with Go, it features user authentication, database persistence, and HTTPS support.

## Overview

Snippet allows users to create and manage short snippets of text with customizable expiration times. This application demonstrates best practices for building web applications in Go, including:

- Clean architecture with separation of concerns
- User authentication and session management
- Secure form handling and validation
- Database integration with MySQL
- HTTPS support with TLS
- Unit and integration testing

## Features

- Create, view, and manage text snippets
- User registration and authentication
- Secure sessions with cookie management
- Customizable expiration times for snippets
- HTTPS support for secure connections
- Responsive web interface

## Requirements

- Go 1.19 or later
- MySQL 5.7 or later
- Make (for using the Makefile)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Babatunde50/snippet.git
   cd snippet
   ```

2. Set up the database:
   ```bash
   # Log into MySQL and create a database
   mysql -u root -p
   ```

   ```sql
   CREATE DATABASE snippetbox CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   CREATE USER 'web'@'localhost' IDENTIFIED BY 'pass';
   GRANT ALL PRIVILEGES ON snippetbox.* TO 'web'@'localhost';
   ```

3. Create the necessary tables (schema provided in `database.sql`).

4. Generate TLS certificates for HTTPS:
   ```bash
   mkdir -p tls
   cd tls
   
   # For development only - generate self-signed certificates
   go run /usr/local/go/src/crypto/tls/generate_cert.go --rsa-bits=2048 --host=localhost
   
   # Alternatively, for production, use proper certificates
   ```

5. Install dependencies:
   ```bash
   make deps
   ```

## Configuration

The application can be configured using command-line flags:

- `-addr`: HTTP network address (default: `:4000`)
- `-static-dir`: Path to static assets (default: `./ui/static`)
- `-dsn`: MySQL data source name (default: `web:pass@/snippetbox?parseTime=true`)

## Usage

### Building and Running

Build the application:
```bash
make build
```

Run the application:
```bash
make run
```

For development:
```bash
make run-dev
```

### Testing

Run all tests:
```bash
make test
```

Run tests with coverage:
```bash
make test-cover
```