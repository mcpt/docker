#!/bin/sh

set -eo pipefail

# Check for required environment variables
if [ -z "${S3_ACCESS_KEY_ID}" ]; then
  echo "Warning: S3_ACCESS_KEY_ID is not set."
fi

if [ -z "${S3_SECRET_ACCESS_KEY}" ]; then
  echo "Warning: S3_SECRET_ACCESS_KEY is not set."
fi

if [ -z "${S3_BUCKET}" ]; then
  echo "Error: S3_BUCKET is required."
  exit 1
fi

if [ -z "${MYSQL_HOST}" ]; then
  echo "Error: MYSQL_HOST is required."
  exit 1
fi

if [ -z "${MYSQL_USER}" ]; then
  echo "Error: MYSQL_USER is required."
  exit 1
fi

if [ -z "${MYSQL_PASSWORD}" ]; then
  echo "Error: MYSQL_PASSWORD is required or link to a MYSQL container."
  exit 1
fi

# Set AWS credentials if not using IAM role
if [ "${S3_IAMROLE}" != "true" ]; then
  export AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY_ID"
  export AWS_SECRET_ACCESS_KEY="$S3_SECRET_ACCESS_KEY"
  export AWS_DEFAULT_REGION="$S3_REGION"
fi

# MySQL connection options
MYSQL_HOST_OPTS="-h $MYSQL_HOST -P $MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD"
DUMP_START_TIME=$(date +"%Y-%m-%dT%H%M%SZ")

# Function to copy file to S3
copy_s3 () {
  local SRC_FILE=$1
  local DEST_FILE=$2
  local AWS_ARGS=""

  if [ -n "${S3_ENDPOINT}" ]; then
    AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
  fi

  if [ "${S3_ENSURE_BUCKET_EXISTS}" != "no" ]; then
    echo "Ensuring S3 bucket $S3_BUCKET exists"
    if ! aws "$AWS_ARGS" s3api head-bucket --bucket "$S3_BUCKET" >/dev/null 2>&1; then
      echo "Creating bucket $S3_BUCKET"
      aws "$AWS_ARGS" s3api create-bucket --bucket "$S3_BUCKET"
    fi
  fi

  echo "Uploading ${DEST_FILE} to S3..."
  if ! aws "$AWS_ARGS" s3 cp "$SRC_FILE" s3://"$S3_BUCKET"/"$S3_PREFIX"/"$DEST_FILE"; then
    echo "Error uploading ${DEST_FILE} to S3" >&2
  fi

  rm "$SRC_FILE"
}

# Add extra mysqldump options if provided
MYSQLDUMP_OPTIONS="${MYSQLDUMP_OPTIONS} ${MYSQLDUMP_EXTRA_OPTIONS}"

# Multi-file dumps
if [ ! -z "$(echo "$MULTI_FILES" | grep -i -E "(yes|true|1)")" ]; then
  if [ "${MYSQLDUMP_DATABASE}" == "--all-databases" ]; then
    DATABASES=$(mysql "$MYSQL_HOST_OPTS" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys|innodb)")
  else
    DATABASES=$MYSQLDUMP_DATABASE
  fi

  for DB in $DATABASES; do
    echo "Dumping ${DB} from ${MYSQL_HOST}..."
    DUMP_FILE="/tmp/${DB}.sql.gz"

    mysqldump "$MYSQL_HOST_OPTS" "$MYSQLDUMP_OPTIONS" --databases "$DB" | gzip > "$DUMP_FILE"

    if [ $? -eq 0 ]; then
      S3_FILE="${S3_FILENAME:-$DUMP_START_TIME}.${DB}.sql.gz"
      copy_s3 "$DUMP_FILE" "$S3_FILE"
    else
      echo "Error dumping ${DB}" >&2
    fi
  done

# Single-file dump
else
  echo "Dumping ${MYSQLDUMP_DATABASE} from ${MYSQL_HOST}..."
  DUMP_FILE="/tmp/dump.sql.gz"
  mysqldump "$MYSQL_HOST_OPTS" "$MYSQLDUMP_OPTIONS" "$MYSQLDUMP_DATABASE" | gzip > "$DUMP_FILE"

  if [ $? -eq 0 ]; then
    S3_FILE="${S3_FILENAME:-$DUMP_START_TIME}.dump.sql.gz"
    copy_s3 "$DUMP_FILE" "$S3_FILE"
  else
    echo "Error creating dump" >&2
  fi
fi

echo "SQL backup finished"