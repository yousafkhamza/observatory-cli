#!/bin/bash

# Author: Yousaf
# Date: 2024
# Description: This script checks the security headers of a given URL.
# Usage: ./check_header.sh <url>
# Ensure the URL starts with http:// or https://
# It fetches the headers and evaluates the presence of important security headers.
# The script also calculates a score based on the headers found.

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

# Display the header with big font style using ANSI escape codes (in yellow)
echo -e "\033[1;33mHeaders for $url:\033[0m"  # Yellow

# Check if headers are present
if [ -z "$headers" ]; then
  echo "----------------------------------------"
  echo "No headers found for $url"
  exit 1
fi

# Initialize header check variable
relevant_headers_found=false

# Check for relevant security headers
if echo "$headers" | grep -qi "Strict-Transport-Security\|Content-Security-Policy\|X-Content-Type-Options\|X-Frame-Options\|X-XSS-Protection\|Referrer-Policy"; then
  echo "----------------------------------------"
  # Display relevant headers in green
  echo -e "\033[1;32m$headers\033[0m" | grep -i "Strict-Transport-Security\|Content-Security-Policy\|X-Content-Type-Options\|X-Frame-Options\|X-XSS-Protection\|Referrer-Policy"
  relevant_headers_found=true
else
  echo -e "\033[1;31m----------------------------------------\033[0m"  # Red
  echo -e "\033[1;31mNo relevant security headers found.\033[0m"  # Red
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

# Show final score in blue
echo -e "\033[1;34m----------------------------------------\033[0m"  # Blue
echo -e "\033[1;34mSecurity Header Score: $score/100\033[0m"  # Blue
echo -e "\033[1;34m----------------------------------------\033[0m"  # Blue

# Report on missing headers
if [ ${#missing_headers[@]} -eq 0 ]; then
  echo -e "\033[1;32mAll important security headers are present!\033[0m"
else
  echo -e "\033[1;31mMissing headers:\033[0m"  # Red
  echo -e "\033[1;31m-----------------\033[0m"
  for header in "${missing_headers[@]}"; do
    echo "$header" 
  done
fi
