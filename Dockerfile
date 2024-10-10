# Dockerfile.backend

# Use an official Maven image with OpenJDK for building
FROM maven:3.8.5-openjdk-17-slim AS build

# Set the working directory in the container
WORKDIR /app

# Copy the pom.xml and download dependencies
COPY pom.xml .

# Download all dependencies. Dependencies will be cached if the pom.xml is not changed
RUN mvn dependency:go-offline

# Copy the source code into the container
COPY . ./

# Install Node.js and npm using apk
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@6.14.13  # Install the desired npm version

# Package the application
RUN mvn package -DskipTests

# Second stage for running the application
FROM openjdk:17-jdk-alpine

# Set the working directory
WORKDIR /app

# Copy the jar file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the application port
EXPOSE 8080

# Command to run the application
CMD ["java", "-jar", "app.jar"]
