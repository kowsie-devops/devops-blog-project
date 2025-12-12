#!/bin/bash
set -e
BACKUP_DIR=/opt/blog/backups
DATA_DIR=/opt/blog/data
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
mkdir -p ${BACKUP_DIR}
cp ${DATA_DIR}/blog.db ${BACKUP_DIR}/blog-${TIMESTAMP}.db
# Keep last 7 backups only
ls -1tr ${BACKUP_DIR}/blog-*.db | head -n -7 | xargs -r rm -f
# Optional: copy to s3
# aws s3 cp ${BACKUP_DIR}/blog-${TIMESTAMP}.db s3://your-bucket/backups/
