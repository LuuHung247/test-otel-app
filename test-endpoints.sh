#!/bin/bash

BASE_URL="${1:-http://localhost:8080}"

echo "=================================="
echo "Testing OpenTelemetry App"
echo "Base URL: $BASE_URL"
echo "=================================="
echo ""

# Test health endpoint
echo "1. Testing health endpoint..."
curl -s "$BASE_URL/actuator/health" | jq '.' || curl -s "$BASE_URL/actuator/health"
echo ""
echo ""

# Test hello endpoint
echo "2. Testing hello endpoint..."
curl -s "$BASE_URL/api/hello" | jq '.' || curl -s "$BASE_URL/api/hello"
echo ""
echo ""

# Test all log levels
echo "3. Generating all log levels..."
curl -s "$BASE_URL/api/logs/all" | jq '.' || curl -s "$BASE_URL/api/logs/all"
echo ""
echo ""

# Test random logs
echo "4. Generating 5 random logs..."
for i in {1..5}; do
    curl -s "$BASE_URL/api/logs/random" | jq '.level' || curl -s "$BASE_URL/api/logs/random"
    sleep 0.5
done
echo ""
echo ""

# Test custom log
echo "5. Testing custom log..."
curl -s -X POST "$BASE_URL/api/logs/custom?level=INFO&message=Custom+test+message+from+script" | jq '.' || \
  curl -s -X POST "$BASE_URL/api/logs/custom?level=INFO&message=Custom+test+message+from+script"
echo ""
echo ""

# Test error simulation
echo "6. Simulating error..."
curl -s "$BASE_URL/api/simulate/error" | jq '.' || curl -s "$BASE_URL/api/simulate/error"
echo ""
echo ""

# Test traffic simulation
echo "7. Simulating traffic (20 logs)..."
curl -s "$BASE_URL/api/simulate/traffic?count=20" | jq '.' || \
  curl -s "$BASE_URL/api/simulate/traffic?count=20"
echo ""
echo ""

echo "=================================="
echo "Testing completed!"
echo "=================================="
echo ""
echo "Check logs in Grafana:"
echo "  Query: {service_name=\"test-otel-app\"}"
echo ""
echo "Or check pod logs:"
echo "  kubectl logs -n monitoring -l app=test-otel-app --tail=50"
