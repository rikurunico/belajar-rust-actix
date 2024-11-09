# Stage 1: Build the Rust project
FROM rust:1.72-alpine AS builder

# Set the working directory
WORKDIR /usr/src/app

# Install dependencies needed for building (alpine needs build tools)
RUN apk add --no-cache musl-dev gcc libssl-dev

# Copy Cargo.toml and Cargo.lock to cache dependencies first
COPY Cargo.toml Cargo.lock ./

# Fetch dependencies (this helps to cache dependencies if they don't change)
RUN cargo fetch

# Copy the source code and build the project
COPY . .

# Build the release version
RUN cargo build --release

# Stage 2: Create a minimal image to run the binary
FROM alpine:latest

# Install runtime dependencies (only what's needed for running the app)
RUN apk add --no-cache libssl1.1

# Set the working directory
WORKDIR /usr/src/app

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/app/target/release/my-actix-app .

# Expose the port the app runs on
EXPOSE 8080

# Run the compiled binary
CMD ["./my-actix-app"]
