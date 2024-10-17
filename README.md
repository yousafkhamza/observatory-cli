# Header Checker

The **Header Checker** is a simple Bash script that checks for important security HTTP headers on a specified URL. It helps identify potential vulnerabilities in web applications by ensuring that necessary security headers are properly configured.

## How It Works

The script performs the following actions:

1. **Fetch Headers:** It uses `curl` to fetch the HTTP headers from the specified URL.
2. **Check for Security Headers:** The script checks for the presence of the following important security headers:
   - `Strict-Transport-Security`
   - `Content-Security-Policy`
   - `X-Content-Type-Options`
   - `X-Frame-Options`
   - `X-XSS-Protection`
   - `Referrer-Policy`
3. **Scoring:** It assigns a score based on the number of security headers present, with a maximum score of 100. For each missing header, the score is reduced.
4. **Display Results:** The script outputs the fetched headers, the security score, and lists any missing headers.

## Why It Matters for Website Security

Implementing security headers is crucial for protecting web applications from various attacks, such as:

- **Cross-Site Scripting (XSS):** Prevents attackers from injecting malicious scripts.
- **Clickjacking:** Protects users from malicious sites that try to trick them into clicking on something different than what they perceive.
- **Data Leakage:** Helps prevent sensitive data from being exposed through improper content handling.

By regularly checking your website's headers, you can identify gaps in security and take corrective actions to enhance your web application's defenses.

## Installation

You can easily install the Header Checker script using the following command:

```bash
curl -sSL https://raw.githubusercontent.com/yousafkhamza/header-checker/main/install.sh | bash
