#!/bin/bash

# Author: Yousaf
# Date: 2024
# Description: This script checks the security headers of a given URL, including Cookies, Redirection, CORS, and Clickjacking protection.

url="$1"

# Ensure the URL starts with http:// or https://
if [[ -z "$url" ]]; then
  echo "Usage: $0 <url>"
  exit 1
elif [[ ! "$url" =~ ^https?:// ]]; then
  url="https://$url"  # Default to https if no scheme is provided
fi

# Function to display a simple progress bar
function progress_bar {
    local duration="$1"
    local interval=1  # Use whole seconds for the sleep duration
    local elapsed=0

    while [ $elapsed -lt $duration ]; do
        echo -n "."
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    echo
}

# Show progress while fetching the HTTP status code and headers in the background
{
    echo -n "Checking Site Score of "$url""
    progress_bar 5  # Adjust the duration if needed
} &  # Run the progress bar in the background

# Fetch the HTTP status code and headers from the URL
status_response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
http_code=$status_response

# Capture the background process ID
progress_pid=$!

# Check if the status code is valid
if [[ "$http_code" != "200" && "$http_code" != "301" && "$http_code" != "302" && "$http_code" != "307" && "$http_code" != "308" ]]; then
  echo -e "\033[1;31mError: Unable to reach $url. Status code: $http_code\033[0m"
  kill $progress_pid 2>/dev/null  # Safely kill the progress bar if it is still running
  exit 1
fi

# Kill the background progress bar
kill $progress_pid 2>/dev/null  # Safely kill the progress bar

# Fetch the headers using curl
headers=$(curl -I -L -s "$url")  # Added -L to follow redirections

# Display the header with big font style using ANSI escape codes (in pink)
echo -e "\n\033[1;35mResult for $url:\033[0m"  # Pink

# Initialize header check variable
relevant_headers_found=false

# Line separator
echo "----------------------------------------"

# Check for relevant security headers
if echo "$headers" | grep -qi "Strict-Transport-Security\|Content-Security-Policy\|X-Content-Type-Options\|X-Frame-Options\|X-XSS-Protection\|Referrer-Policy"; then
  # Display relevant headers in green
  echo -e "\033[1;33mHeaders found:\033[0m"
  echo -e "\033[1;32m$headers\033[0m" | grep -i "Strict-Transport-Security\|Content-Security-Policy\|X-Content-Type-Options\|X-XSS-Protection\|Referrer-Policy"
  relevant_headers_found=true
else
  echo -e "\033[1;31mNo relevant security headers found.\033[0m"  # Red
fi

# Define scoring mechanism
total_security_headers=7  # Increased to 7 for the additional CSP frame-ancestors
score_per_security_header=$((60 / total_security_headers)) # Each header is worth 8.57 points
total_score=100  # Total score including Cookies, Redirection, and CORS

# Check for missing security headers
missing_headers=()

for header in "Strict-Transport-Security" "Content-Security-Policy" "X-Content-Type-Options" "X-Frame-Options" "X-XSS-Protection" "Referrer-Policy"; do
  if ! echo "$headers" | grep -qi "$header"; then
    missing_headers+=("$header")
    total_score=$((total_score - score_per_security_header))  # Deduct points for missing headers
  fi
done

# Check for CSP frame-ancestors
if ! echo "$headers" | grep -qi "frame-ancestors"; then
  missing_headers+=("frame-ancestors is missing in CSP")
  total_score=$((total_score - score_per_security_header))  # Deduct points for missing frame-ancestors
fi

# Check for CSP frame-ancestors
if ! echo "$headers" | grep -qi "frame-src"; then
  missing_headers+=("frame-src is missing in CSP")
  total_score=$((total_score - score_per_security_header))  # Deduct points for missing frame-src
fi

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

# Check for clickjacking protection using X-Frame-Options and frame-ancestors
# Check for clickjacking protection using X-Frame-Options and frame-ancestors
echo -e "\033[1;33mChecking for Clickjacking Protection:\033[0m"

x_frame_options=$(echo "$headers" | grep -i "X-Frame-Options")
frame_ancestors=$(echo "$headers" | grep -i "frame-ancestors")
csp_header=$(echo "$headers" | grep -i "Content-Security-Policy")

# Extract frame-src and frame-ancestors from the CSP header
if [[ -n "$csp_header" ]]; then
    frame_src=$(echo "$csp_header" | grep -oP "frame-src [^;]+" || true)
    frame_ancestors=$(echo "$csp_header" | grep -oP "frame-ancestors [^;]+" || true)
else
    frame_src=""
    frame_ancestors=""
fi

if [[ -n "$x_frame_options" ]]; then
    echo -e "\033[1;32mX-Frame-Options header found:\033[0m"
    echo "$x_frame_options"
    # Additional analysis for X-Frame-Options
    if echo "$x_frame_options" | grep -iq "deny\|sameorigin"; then
        echo -e "\033[1;32mClickjacking protection via X-Frame-Options is enabled.\033[0m"
    else
        echo -e "\033[1;31mX-Frame-Options exists but is not properly set for protection.\033[0m"
    fi
else
    echo -e "\033[1;31mX-Frame-Options header missing.\033[0m"
fi

# Display extracted frame-ancestors
if [[ -n "$frame_ancestors" ]]; then
    echo -e "\033[1;32mframe-ancestors directive found:\033[0m"
    echo "$frame_ancestors"
else
    echo -e "\033[1;31mframe-ancestors directive missing in CSP.\033[0m"
    total_score=$((total_score - 10))  # Deduct points for missing frame-ancestors
fi

# Display extracted frame-src
if [[ -n "$frame_src" ]]; then
    echo -e "\033[1;32mframe-src directive found:\033[0m"
    echo "$frame_src"
else
    echo -e "\033[1;31mframe-src directive missing in CSP.\033[0m"
    total_score=$((total_score - 10))  # Deduct points for missing frame-src
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

# Summary of missing headers
if [ ${#missing_headers[@]} -gt 0 ]; then
  echo -e "\033[1;31mMissing Security Headers:\033[0m"
  for header in "${missing_headers[@]}"; do
    echo "- $header"
  done
else
  echo -e "\033[1;32mAll relevant security headers are present!\033[0m"
fi

echo -e "\033[1;34mCheck completed.\033[0m"
