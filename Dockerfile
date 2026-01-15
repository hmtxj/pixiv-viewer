# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build the application
RUN pnpm run build

# Production stage
FROM nginx:alpine

# Copy build artifacts
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Permissions for non-root user (Hugging Face Spaces often run as non-root)
RUN chmod -R 777 /var/cache/nginx /var/run /var/log/nginx

# Expose Hugging Face default port
EXPOSE 7860

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
