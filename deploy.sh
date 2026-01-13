#!/bin/bash

# This is a wrapper script that calls deploy-all.sh
# You can also use deploy-monitoring.sh or deploy-app.sh separately

echo "This script will deploy the complete observability stack."
echo ""
echo "Other options:"
echo "  - ./deploy-monitoring.sh  : Deploy only monitoring stack"
echo "  - ./deploy-app.sh         : Deploy only the application"
echo "  - ./deploy-all.sh         : Deploy everything (this script)"
echo ""

./deploy-all.sh
