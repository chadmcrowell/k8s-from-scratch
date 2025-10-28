FROM ghost:6-alpine

# Switch to root to install packages
USER root

# Install minimal OpenTelemetry packages
RUN cd /var/lib/ghost && \
    npm install --save --production \
    @opentelemetry/api@^1.9.0 \
    @opentelemetry/auto-instrumentations-node@^0.50.0 && \
    npm cache clean --force

# Switch back to node user for security
USER node

EXPOSE 2368
