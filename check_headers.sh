#!/bin/bash

url="$1"

# Ensure the URL starts with http:// or https://
if [[ -z "$url" ]]; then
  echo "Usage: $0 <url>"
  exit 1
elif [[ ! "$url" =~ ^https?:// ]]; then
  url="https://$url"  # Default to https if no scheme is provided
fi

# Fetch the headers using curl
headers=$(curl -I -s "$url")

echo "Headers for $url:"

# Check if headers are present
if [ -z "$headers" ]; then
  echo "----------------------------------------"
  echo "No headers found for $url"
  exit 1
fi

# Initialize header check variable
relevant_headers_found=false

# Display the headers if any relevant security headers are found
if echo "$headers" | grep -qi "Strict-Transport-Security\|Content-Security-Policy\|X-Content-Type-Options\|X-Frame-Options\|X-XSS-Protection\|Referrer-Policy"; then
  echo "----------------------------------------"
  echo "$headers" | grep -i "Strict-Transport-Security\|Content-Security-Policy\|X-Content-Type-Options\|X-Frame-Options\|X-XSS-Protection\|Referrer-Policy"
  relevant_headers_found=true
else
  echo "----------------------------------------"
  echo "No relevant security headers found."
fi

# Define scoring mechanism
total_headers=6
score_per_header=$((100 / total_headers)) # Each header is worth about 16 points
score=100

# Check for missing headers
missing_headers=()

for header in "Strict-Transport-Security" "Content-Security-Policy" "X-Content-Type-Options" "X-Frame-Options" "X-XSS-Protection" "Referrer-Policy"; do
  if ! echo "$headers" | grep -qi "$header"; then
    missing_headers+=("$header")
    score=$((score - score_per_header))  # Deduct points for missing headers
  fi
done

# Ensure score is zero if all headers are missing
if [ ${#missing_headers[@]} -eq $total_headers ]; then
  score=0
fi

# Show final score
echo "----------------------------------------"
echo "Security Header Score: $score/100"
echo "----------------------------------------"

# Report on missing headers
if [ ${#missing_headers[@]} -eq 0 ]; then
  echo "All important security headers are present!"
else
  echo "Missing headers:"
  for header in "${missing_headers[@]}"; do
    echo "$header"
  done
fi
