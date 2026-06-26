# Security Policy

## Supported Versions

We release security patches for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| latest   | ✅ Yes |
| previous | ✅ Security fixes only |
| < N/A | ❌ No longer supported |

## Reporting a Vulnerability

**Please do NOT report security vulnerabilities via public GitHub issues.**

Instead, please report them via:

- **Email**: security@github.com
- **GitHub Security Advisory**: [Report a vulnerability](https://github.com/JWEB0689/android-kernel-build/security/advisories/new)

We will acknowledge receipt within 48 hours and provide a more detailed response within 7 days.

## Disclosure Policy

- We follow [Coordinated Vulnerability Disclosure](https://en.wikipedia.org/wiki/Coordinated_vulnerability_disclosure)
- We aim to patch critical vulnerabilities within 7 days
- We will credit reporters in the security advisory (unless anonymity requested)
- Public disclosure coordinated after fix is available

## Security Best Practices

### For Users

- Always use the latest stable release
- Verify signatures/checksums of downloads
- Keep dependencies updated
- Report suspicious behavior

### For Contributors

- Never commit secrets, keys, or tokens
- Run security scans before PR: `{{SECURITY_CMD}}`
- Follow secure coding practices for {{LANGUAGE}}
- Review dependencies for known vulnerabilities

## Security Features

Kernel build automation with patch management
GKI kernel support with KernelSU and SUSFS integration
AnyKernel3 ZIP generation for flashable kernels
ccache for build acceleration
Python-based patch manager with group-based patch application
Artifact and log upload for debugging

## Audit History

| Date | Version | Type | Description |
|------|---------|------|-------------|
| 2026-06-26 | current | Initial security audit | Repository reviewed for kernel build security best practices |

---

*Template based on rtk/odysseus security policies*