# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Currently supported versions:

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in Bloudme, please report it responsibly by following these steps:

### 🚨 DO NOT create a public GitHub issue for security vulnerabilities

Instead, please:

1. **Email us directly** or create a private security advisory on GitHub
2. **Provide detailed information** including:
   - Description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact
   - Any suggested fixes (if you have them)

### What to Expect

- **Acknowledgment**: We'll acknowledge your report within 48 hours
- **Investigation**: We'll investigate and validate the issue
- **Timeline**: We aim to provide updates every 7 days until resolution
- **Credit**: We'll credit you in our security advisories (unless you prefer anonymity)

### Response Timeline

- **Critical vulnerabilities**: Patches within 7 days
- **High severity**: Patches within 14 days
- **Medium/Low severity**: Patches within 30 days

## Security Best Practices for Users

### For Developers
- Keep your Ruby and Rails versions up to date
- Regularly update gem dependencies: `bundle update`
- Use environment variables for sensitive configuration
- Enable Rails security headers in production
- Review code for potential security issues before deployment

### For Deployment
- Use HTTPS in production environments
- Keep your database and Redis instances secure
- Regularly backup your data
- Monitor your application for unusual activity
- Use strong passwords and enable 2FA where possible

## Security Features

Bloudme includes several built-in security features:

- **Authentication**: Secure session-based authentication with bcrypt
- **CSRF Protection**: Rails built-in CSRF protection
- **SQL Injection Protection**: Using Rails parameter binding
- **XSS Protection**: Rails automatic HTML escaping
- **Content Security Policy**: Configured CSP headers
- **Secure Headers**: Security-focused HTTP headers
- **Parameter Filtering**: Sensitive parameters filtered from logs

## Known Security Considerations

- RSS feeds are parsed from external sources - we sanitize content but be cautious
- User-generated bookmarks and feeds go through validation
- All external HTTP requests are made with appropriate timeouts
- Session tokens are generated securely and rotated appropriately

## Security Tools Used

- **Brakeman**: Static analysis security scanner
- **Bundler Audit**: Checks for vulnerable gem versions
- **Rails built-in security features**: CSRF, parameter filtering, etc.
- **Sentry**: Error monitoring and alerting

Thank you for helping keep Bloudme and our users safe!