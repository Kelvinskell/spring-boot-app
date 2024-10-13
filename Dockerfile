# First stage
FROM maven:3.8.5-openjdk-17-slim AS build

# Set the working directory in the container
WORKDIR /app

# Copy the pom.xml and download dependencies
COPY pom.xml .

# Download all dependencies.
RUN mvn dependency:go-offline

# Install Node.js and npm for building the frontend 
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@6.14.13 

# Copy the source code into the container
COPY . ./

# Run frontend build
RUN cd src/main/resources/static && npm install && npm run build

# Package the Spring Boot application
RUN mvn package -DskipTests

# Second stage (Using a lightweight image)
FROM openjdk:17-jdk-alpine

# Set the working directory
WORKDIR /app

# Copy the jar file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the application port
EXPOSE 8080

# Command to run the application
CMD ["java", "-jar", "app.jar"]
