# Stage 1: Build the Angular application
# Use a Node image for building
FROM node:18-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (or npm-shrinkwrap.json)
# This allows Docker to cache the dependencies layer better
COPY package*.json ./

# Install dependencies (using 'ci' for clean installs)
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the Angular application for production
# The output will be in the 'dist/your-app-name' folder (check your angular.json)
# You might need to adjust the path based on your project's angular.json file's outputPath
RUN npm run build -- --configuration production

---

# Stage 2: Serve the application with a lightweight web server (Nginx)
# Use a super-lightweight Nginx image for serving static files
FROM nginx:alpine

# Copy the built files from the 'builder' stage into the Nginx public folder
# IMPORTANT: Replace 'dist/my-angular-app' with the actual output folder from your build
# Check the 'outputPath' in your angular.json file.
COPY --from=builder /app/dist/my-angular-app /usr/share/nginx/html

# Optionally copy a custom Nginx configuration file
# If you need specific routing (like for deep linking/history mode), you'll need a custom config.
# COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf

# 🌐 EXPOSE the port Nginx runs on
# Nginx default is port 80
EXPOSE 80

# 🚀 ENTRYPOINT/CMD to start the server
# The default Nginx CMD will start the server, so you don't always need to explicitly define it.
# The base Nginx image already has a suitable CMD. If you want to be explicit:
CMD ["nginx", "-g", "daemon off;"]