#!/bin/bash
# Deploy script for Simple People Holdings LLC-S website
# Syncs local files to S3 and invalidates CloudFront cache

S3_BUCKET="s3://simplepeopleholdings.com"
CF_DISTRIBUTION="E3S07LFW1GWNWG"
AWS_PROFILE="sph"
SITE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Deploying Simple People Holdings LLC-S ==="
echo ""

# Sync files to S3 (exclude git files, deploy script itself)
echo "[1/3] Syncing files to S3..."
aws s3 sync "$SITE_DIR" "$S3_BUCKET" \
  --profile "$AWS_PROFILE" \
  --exclude ".git/*" \
  --exclude "deploy.sh" \
  --exclude ".gitignore" \
  --delete

if [ $? -ne 0 ]; then
  echo "ERROR: S3 sync failed."
  exit 1
fi
echo "      Done."
echo ""

# Invalidate CloudFront cache
echo "[2/3] Invalidating CloudFront cache..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id "$CF_DISTRIBUTION" \
  --paths "/*" \
  --profile "$AWS_PROFILE" \
  --query 'Invalidation.Id' \
  --output text)

if [ $? -ne 0 ]; then
  echo "ERROR: CloudFront invalidation failed."
  exit 1
fi
echo "      Invalidation ID: $INVALIDATION_ID"
echo ""

# Confirm
echo "[3/3] Deployment complete!"
echo "      Site: https://simplepeopleholdings.com"
echo "      CloudFront cache may take 1-2 minutes to fully update."
