# Observatory-CLI

Observatory-CLI is a bash script that checks the security headers of a given URL, along with Cookies, Redirection, and CORS. It fetches the headers and evaluates the presence of important security headers, calculating a score based on the findings.

## Features

- Checks for important security headers
- Evaluates cookies
- Detects redirection
- Checks for CORS policy
- Calculates a security score
- Provides color-coded output for easy interpretation

## Installation

You can easily install the Observatory-CLI script using the following command:

```bash
curl -sSL https://raw.githubusercontent.com/yousafkhamza/observatory-cli/main/install.sh | bash
```

## Usage

After installation, you can run the script by providing a URL as an argument:

```bash
observatory-checker <url>
```

## if you're face any issues in the above installation you can use the script directly via clone

```bash
git clone https://github.com/yousafkhamza/observatory-cli.git
cd observatory-cli
chmod +x setup.sh
./setup.sh
```

If you don't provide the `http://` or `https://` prefix, the script will default to `https://`.

## Sample Output

```
Checking Site Score of https://github.com.
Result for https://github.com:
----------------------------------------
Headers found:
strict-transport-security: max-age=31536000; includeSubdomains; preload
x-frame-options: deny
x-content-type-options: nosniff
x-xss-protection: 0
referrer-policy: origin-when-cross-origin, strict-origin-when-cross-origin
content-security-policy: default-src 'none'; base-uri 'self'; child-src github.com/assets-cdn/worker/ ...
----------------------------------------
Cookies found:
set-cookie: _gh_sess=T7QyhOdcTGtbwZvsecV6e852qHa2lw0Rt9r2%2BCKmr6mW%2ByQCQvt8BiiGK28%2BJ6pnc%2BC20IKIapFH8%2Bom3Q%2BQrr12VjFzMyQmcRJk9tmEB1JZHqrvIoS4m6iWVoU1UHOQ5S1xlcaLYDzNkcfjfajhxpgfqkXAgZyn4DEfq%2FhteWPn4bVC9A2o%2FBFi%2BobvJULR2P8XcBtVzMxxPa3SqJ5wJxzotRavha%2FtsxFX74%2FP%2BbB8EKP8kspEkMEVjji4pII3MCLDhiE6fNh%2FKPBjVgepHg%3D%3D--KcFsOGmdH364QW7Z--13%2ByAzyytTenMLEvOUH75A%3D%3D; Path=/; HttpOnly; Secure; SameSite=Lax
set-cookie: _octo=GH1.1.1182069113.1729302626; Path=/; Domain=github.com; Expires=Sun, 19 Oct 2025 01:50:26 GMT; Secure; SameSite=Lax
set-cookie: logged_in=no; Path=/; Domain=github.com; Expires=Sun, 19 Oct 2025 01:50:26 GMT; HttpOnly; Secure; SameSite=Lax
----------------------------------------
No redirection detected (HTTP status 200).
----------------------------------------
No CORS policy detected.
----------------------------------------
Site Score: 90/100
----------------------------------------
All important security headers are present!
```

## How It Works

1. The script takes a URL as input.
2. It fetches the HTTP headers for the given URL.
3. It checks for the presence of important security headers:
   - Strict-Transport-Security
   - Content-Security-Policy
   - X-Content-Type-Options
   - X-Frame-Options
   - X-XSS-Protection
   - Referrer-Policy
4. It evaluates cookies and CORS policies.
5. It calculates a score based on the presence of security headers and other factors.
6. The script provides a color-coded output for easy interpretation of the results.

## Author

Yousaf

## License

This project is open source and available under the [MIT License](LICENSE).
