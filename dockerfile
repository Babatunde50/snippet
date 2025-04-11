# Stage 1: Build the application
FROM golang:1.23-alpine AS builder

# Set working directory
WORKDIR /app

# Install necessary build tools
RUN apk add --no-cache git make

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the application
RUN make build

# Stage 2: Create the runtime container
FROM alpine:latest

# Install dependencies
RUN apk add --no-cache ca-certificates tzdata openssl

# Create non-root user for security
RUN adduser -D -g '' appuser

# Set working directory
WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/build/snippet /app/

# Create TLS directory and handle certificates
RUN mkdir -p /app/tls

# Generate self-signed certificates (they'll be used if no certs are mounted)
RUN openssl req -x509 -newkey rsa:2048 -keyout /app/tls/key.pem -out /app/tls/cert.pem -days 365 -nodes -subj "/CN=localhost"

COPY --from=builder /app/tls /app/tls-temp

RUN if [ -d "/app/tls" ]; then \
    echo "Using existing TLS certs"; \
    else \
    echo "Using generated TLS certs"; \
    mkdir -p /app/tls && \
    cp /app/tls-temp/* /app/tls/; \
    fi && \
    rm -rf /app/tls-temp

# Copy static assets
COPY --from=builder /app/ui /app/ui

# Set ownership to the non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE 80

# Set environment variables
ENV TZ=UTC

# Command to run the application with the ability to add flags via environment variable
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/app/snippet -addr=:${PORT} -dsn=${DSN} -static-dir=./ui/static -proxy=${USE_PROXY}"]
