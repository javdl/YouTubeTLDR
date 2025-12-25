FROM rustlang/rust:nightly-alpine AS builder

RUN apk add --no-cache openssl-dev pkgconfig build-base

WORKDIR /YouTubeTLDR

# Copy source files
COPY Cargo.toml Cargo.lock ./
COPY src ./src
COPY static ./static

# Compress static files to .gz (in place, alongside originals)
RUN cd static && gzip -k index.html style.css script.js   # -k keeps originals; add more files if needed

# Now build (the .gz files exist, so include_bytes! succeeds)
RUN cargo build --release --no-default-features --features rustls-tls

# Runtime stage
FROM alpine:latest
RUN apk add --no-cache openssl
COPY --from=builder /YouTubeTLDR/target/release/YouTubeTLDR /usr/local/bin/YouTubeTLDR
COPY static /app/static   # Copy originals for any non-gz fallback if needed
WORKDIR /app
CMD ["/usr/local/bin/YouTubeTLDR"]
