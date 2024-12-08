# Step 1: Use Node.js image to build the application
FROM node:16 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files
COPY . ./

# Build the application
RUN npm run build

# Step 2: Use an nginx image to serve the app
FROM nginx:alpine

# Copy the build output to nginx's web directory
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx server
CMD ["nginx", "-g", "daemon off;"]
