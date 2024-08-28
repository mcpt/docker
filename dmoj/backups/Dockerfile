FROM alpine:latest
LABEL org.opencontainers.image.source="https://github.com/mcpt/docker"

# Install necessary packages and clean up
RUN apk add --no-cache \
    mysql-client \
    mariadb-connector-c \
    python3 \
    py3-pip \
  && pip install awscli \
  && rm -rf /var/cache/apk/*

# Set default environment variables
ENV MYSQLDUMP_OPTIONS "--quote-names --quick --add-drop-table --add-locks --allow-keywords --disable-keys --extended-insert --single-transaction --create-options --comments --net_buffer_length=16384"
ENV MYSQLDUMP_EXTRA_OPTIONS ''
ENV MYSQLDUMP_DATABASE "--all-databases"
ENV MYSQL_HOST '' # Set to empty string
ENV MYSQL_PORT 3306
ENV MYSQL_USER '' # Set to empty string
ENV MYSQL_PASSWORD '' # Set to empty string
ENV S3_ACCESS_KEY_ID '' # Set to empty string
ENV S3_SECRET_ACCESS_KEY '' # Set to empty string
ENV S3_BUCKET '' # Set to empty string
ENV S3_REGION us-west-1
ENV S3_ENDPOINT '' # Set to empty string
ENV S3_S3V4 no
ENV S3_PREFIX 'backup'
ENV S3_FILENAME '' # Set to empty string
ENV S3_ENSURE_BUCKET_EXISTS yes
ENV MULTI_FILES no
ENV SCHEDULE '' # Set to empty string

# Copy scripts to the image
COPY run.sh backup.sh /

# Make scripts executable
RUN chmod +x /run.sh /backup.sh

# Set the entrypoint
CMD ["sh", "/run.sh"]