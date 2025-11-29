# Stage 1 — build the Angular app
FROM node:16-alpine AS builder
WORKDIR /app

# Install dependencies (use package-lock to get reproducible installs)
COPY package*.json ./
RUN npm ci

# Copy source and build the app (production)
COPY . .
# adjust this if your angular.json outputs to a different folder/name
RUN npm run build -- --configuration production

# Stage 2 — serve with nginx
FROM nginx:stable-alpine
# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy built files from the builder stage
# Many projects build to dist/<project-name> — using wildcard is robust
COPY --from=builder /app/dist/angular-mean-crud-tutorial/ /usr/share/nginx/html/


# Optional: add a custom nginx config (uncomment if you have one)
# ADD nginx.conf /etc/nginx/conf.d/default.conf

# Expose default HTTP port
EXPOSE 80

# Keep nginx running in the foreground
ENTRYPOINT ["nginx", "-g", "daemon off;"]
