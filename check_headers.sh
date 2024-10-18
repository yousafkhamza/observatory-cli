#!/bin/bash

# Author: Yousaf
# Date: 2024
# Description: This script checks the security headers of a given URL, along with Cookies, Redirection, and CORS.
# It fetches the headers and evaluates the presence of important security headers.
# The script also calculates a score based on the headers found, including Cookies, Redirection, and CORS.

url="$1"

# Ensure the URL starts with http:// or https://
if [[ -z "$url" ]]; then
  echo "Usage: $0 <url>"
  exit 1
elif [[ ! "$url" =~ ^https?:// ]]; then
  url="https://$url"  # Default to https if no scheme is provided
fi

# Fetch the HTTP status code and headers from the URL
status_response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
http_code=$status_response

# Check if the status code is valid
if [[ "$http_code" != "200" && "$http_code" != "301" && "$http_code" != "302" && "$http_code" != "307" && "$http_code" != "308" ]]; then
  echo -e "\033[1;31mError: Unable to reach $url. Status code: $http_code\033[0m"
  exit 1
fi

# Fetch the headers using curl
headers=$(curl -I -L -s "$url")  # Added -L to follow redirections

# Display the header with big font style using ANSI escape codes (in pink)
echo -e "\033[1;35mResult for $url:\033[0m"  # Pink

# Initialize header check variable
relevant_headers_found=false

# Line separator
echo "----------------------------------------"

# Check for relevant security headers
if echo "$headers" | grep -qi "Strict-Transport-Security\|Content-Security-Policy\|X-Content-Type-Options\|X-Frame-Options\|X-XSS-Protection\|Referrer-Policy"; then
  # Display relevant headers in green
  echo -e "\033[1;33mHeaders found:\033[0m"  
  echo -e "\033[1;32m$headers\033[0m" | grep -i "Strict-Transport-Security\|Content-Security-Policy\|X-Content-Type-Options\|X-Frame-Options\|X-XSS-Protection\|Referrer-Policy"
  relevant_headers_found=true
else
  echo -e "\033[1;31mNo relevant security headers found.\033[0m"  # Red
fi

# Define scoring mechanism
total_security_headers=6
score_per_security_header=$((60 / total_security_headers)) # Each header is worth 10 points
total_score=100  # Total score including Cookies, Redirection, and CORS

# Check for missing security headers
missing_headers=()

for header in "Strict-Transport-Security" "Content-Security-Policy" "X-Content-Type-Options" "X-Frame-Options" "X-XSS-Protection" "Referrer-Policy"; do
  if ! echo "$headers" | grep -qi "$header"; then
    missing_headers+=("$header")
    total_score=$((total_score - score_per_security_header))  # Deduct points for missing headers
  fi
done

# Ensure score does not go below zero
if (( total_score < 0 )); then
  total_score=0
fi

# Line separator
echo "----------------------------------------"

# Additional scoring logic for Cookies, Redirection, and CORS

# Check for Cookies
if echo "$headers" | grep -qi "Set-Cookie"; then
  echo -e "\033[1;33mCookies found:\033[0m"
  echo "$headers" | grep -i "Set-Cookie"
else
  echo -e "\033[1;31mNo cookies found.\033[0m"
  total_score=$((total_score - 10))  # Deduct 10 points for missing cookies
fi

# Ensure score does not go below zero
if (( total_score < 0 )); then
  total_score=0
fi

# Line separator
echo "----------------------------------------"

# Check for Redirection based on HTTP status codes
if [[ "$http_code" == "301" || "$http_code" == "302" || "$http_code" == "307" || "$http_code" == "308" ]]; then
  echo -e "\033[1;33mRedirection detected (HTTP status $http_code).\033[0m"
else
  echo -e "\033[1;32mNo redirection detected (HTTP status $http_code).\033[0m"
fi

# Line separator
echo "----------------------------------------"

# Check for CORS (Cross-Origin Resource Sharing)
if echo "$headers" | grep -qi "Access-Control-Allow-Origin"; then
  echo -e "\033[1;33mCORS policy found:\033[0m"
  echo "$headers" | grep -i "Access-Control-Allow-Origin"
else
  echo -e "\033[1;31mNo CORS policy detected.\033[0m"
  total_score=$((total_score - 10))  # Deduct 10 points for missing CORS policy
fi

# Ensure score does not go below zero
if (( total_score < 0 )); then
  total_score=0
fi

# Line separator
echo "----------------------------------------"

# Display the total score with color-coded output based on the score
if (( total_score < 40 )); then
  echo -e "\033[1;31mSite Score: $total_score/100\033[0m"  # Red
elif (( total_score >= 40 && total_score <= 80 )); then
  echo -e "\033[1;33mSite Score: $total_score/100\033[0m"  # Yellow
else
  echo -e "\033[1;32mSite Score: $total_score/100\033[0m"  # Green
fi

# Line separator
echo "----------------------------------------"

# Report on missing security headers
if [ ${#missing_headers[@]} -eq 0 ]; then
  echo -e "\033[1;32mAll important security headers are present!\033[0m"
else
  echo -e "\033[1;31mMissing security headers:\033[0m"  # Red
  echo -e "\033[1;31m-----------------\033[0m"
  for header in "${missing_headers[@]}"; do
    echo "$header"
  done
fi
