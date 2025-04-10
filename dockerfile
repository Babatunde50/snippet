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
RUN apk add --no-cache ca-certificates tzdata

# Create non-root user for security
RUN adduser -D -g '' appuser

# Set working directory
WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/build/snippet /app/

# Copy required application files
COPY --from=builder /app/tls /app/tls
COPY --from=builder /app/ui /app/ui

# Set ownership to the non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE 80

# Set environment variables
ENV TZ=UTC

# Command to run the application with the ability to override DSN via environment variable
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/app/snippet -addr=:4000 -dsn=${DSN:-web:pass@tcp(mysql:3306)/snippetbox?parseTime=true} -static-dir=./ui/static"]
