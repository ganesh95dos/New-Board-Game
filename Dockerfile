# Multi-stage build for Board Game Web Application
# Stage 1: Build stage - Use Java 11 to match pom.xml requirements
FROM maven:3.8.4-openjdk-11-slim AS builder

WORKDIR /app

# Copy only pom.xml first for dependency caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests -B

# -------------------
# Stage 2: Runtime stage - Use Java 11 JRE
FROM openjdk:11-jre-slim

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser -m appuser

# Switch to non-root user
USER appuser

WORKDIR /home/appuser

# Copy JAR file from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose port 8080 (matches your application)
EXPOSE 8080

# Set JVM options optimized for containers
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Set default Spring profile for Docker
ENV SPRING_PROFILES_ACTIVE=docker

# Run the application with optimized JVM settings
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE} -jar app.jar"]
