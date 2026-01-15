# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Install pnpm and git
RUN npm install -g pnpm && apk add --no-cache git

# Clone from GitHub
RUN git clone https://github.com/hmtxj/pixiv-viewer.git .

# Set environment variables for build (Pixiv API configuration)
ENV VUE_APP_DEF_HIBIAPI_MAIN=https://api.obfs.dev/api/pixiv
ENV VUE_APP_DEF_PXIMG_MAIN=i.pixiv.re

# Install dependencies
RUN pnpm install --frozen-lockfile

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
