# Use an official Node.js image to build the React app
FROM node:20-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the package.json and package-lock.json
COPY package*.json ./

# Install the project dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Set the Node.js environment variable to handle OpenSSL issue
ENV NODE_OPTIONS=--openssl-legacy-provider

# Build the React app for production
RUN npm run build

# Use an Nginx image to serve the static files
FROM nginx:alpine

# Copy the build output to Nginx's default directory
COPY --from=build /app/target/classes/static/built /usr/share/nginx/html

# Expose port 80 to allow access
EXPOSE 80

# Command to run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
