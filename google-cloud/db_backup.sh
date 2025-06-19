#!/bin/bash

# Database Export to Google Cloud Storage Script
# Usage: ./export_db.sh -d <database-name> [OPTIONS]
# Make sure to have gcloud and gsutil installed and authenticated.
# In GCS the path will be: gs://sql_db_dumps/<instance-name>/<database-name>/export_<timestamp>.sql

set -e  # Exit on any error

# Default values
PROJECT_ID="pom-proxy-1"
ENVIRONMENT="dev"
INSTANCE_NAME="wonderful-dev"
DATABASE_NAME=""
EXPORT_FORMAT="SQL"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OFFLOAD="false"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Export a Google Cloud SQL database to Google Cloud Storage

OPTIONS:
    -e, --environment  Environment name (default: dev)
    -d, --database      Database name (required)
    -h, --help          Show this help message

EXAMPLES:
    $0 -p -d mydb -b my-bucket
EOF
}

# Function to log messages
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -d|--database)
            DATABASE_NAME="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$DATABASE_NAME" ]]; then
    log_error "Missing database name. Use -d or --database to specify it."
    usage
    exit 1
fi

# If  environment is set, adjust project and instance names
if [[ "$ENVIRONMENT" == "prod" ]]; then
    INSTANCE_NAME="wonderful-production"
fi
EXPORT_FILENAME="export_${TIMESTAMP}.sql"

# Set bucket path
BUCKET_PATH="sql_db_dumps/$INSTANCE_NAME/$DATABASE_NAME"

# Full GCS path
GCS_URI="gs://${BUCKET_PATH}/${EXPORT_FILENAME}"

log "Starting database export..."
log "Project: $PROJECT_ID"
log "Instance: $INSTANCE_NAME"
log "Database: $DATABASE_NAME"
log "Bucket: $BUCKET_PATH"
log "Format: $EXPORT_FORMAT"
log "Output file: $EXPORT_FILENAME"

# Check if gcloud is installed and authenticated
if ! command -v gcloud &> /dev/null; then
    log_error "gcloud CLI is not installed. Please install it first."
    exit 1
fi

# Check authentication
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    log_error "No active gcloud authentication found. Please run 'gcloud auth login'"
    exit 1
fi

# Verify instance exists
log "Verifying Cloud SQL instance exists..."
if ! gcloud sql instances describe "$INSTANCE_NAME" &> /dev/null; then
    log_error "Cloud SQL instance '$INSTANCE_NAME' not found in project '$PROJECT_ID'"
    exit 1
fi

# Verify database exists
log "Verifying database exists..."
if ! gcloud sql databases describe "$DATABASE_NAME" --instance="$INSTANCE_NAME" &> /dev/null; then
    log_error "Database '$DATABASE_NAME' not found in instance '$INSTANCE_NAME'"
    exit 1
fi

# Verify bucket exists
log "Verifying GCS bucket exists..."
if ! gsutil ls -b "gs://$BUCKET_NAME" &> /dev/null; then
    log_error "GCS bucket '$BUCKET_NAME' not found or not accessible"
    exit 1
fi

# Build export command
EXPORT_CMD="gcloud sql export"

case $EXPORT_FORMAT in
    "SQL")
        EXPORT_CMD="$EXPORT_CMD sql"
        ;;
    "CSV")
        EXPORT_CMD="$EXPORT_CMD csv"
        ;;
esac

EXPORT_CMD="$EXPORT_CMD $INSTANCE_NAME $GCS_URI"

# Add database parameter
EXPORT_CMD="$EXPORT_CMD --database=$DATABASE_NAME"
log "Export command: $EXPORT_CMD"

# Execute the export
log "Executing export command..."
log "Command: $EXPORT_CMD"

if eval "$EXPORT_CMD"; then
    log "✅ Database export completed successfully!"
    log "Export file location: $GCS_URI"
else
    log_error "❌ Database export failed!"
    exit 1
fi