# 🔐 Security Policy

## Supported Versions

Security updates are provided for the **latest stable release** of this project.

| Version               | Supported |
| --------------------- | --------- |
| Latest release        | ✅ Yes     |
| All previous versions | ❌ No      |

> Users are strongly encouraged to run the latest version to receive security fixes.

---

## 🛡️ Reporting a Vulnerability

If you believe you have found a security vulnerability, please report it responsibly.

### How to Report

* **Do not** open a public GitHub issue.
* Report vulnerabilities via **private communication** with the project maintainer.
* Include the following information when possible:

  * A detailed description of the vulnerability
  * Steps to reproduce the issue
  * Potential impact
  * Any relevant screenshots, logs, or proof-of-concept

### Response Timeline

* You can expect an **initial response within 72 hours**
* If the vulnerability is accepted:

  * A fix or mitigation will be prioritized
  * A patched release will be published when ready
* If the report is declined, an explanation will be provided

---

## 🔍 Security Scope

### Current Scope

At present, this Flutter Chess App is primarily an **offline-first mobile application**.

Security considerations currently include:

* Game logic integrity and state manipulation
* Input validation and crash prevention
* Safe handling of assets and local storage
* Dependency-related vulnerabilities

---

### Future Scope (Planned Features)

As the project evolves, future versions may introduce:

* Online multiplayer functionality
* User authentication and profiles
* Backend APIs and real-time communication
* Cloud-based game state storage

When these features are introduced, the security scope will expand to include:

* Authentication and authorization
* Secure network communication
* Data privacy and protection
* Abuse prevention and rate limiting

Security policies will be updated accordingly as new features are added.

---

## 📦 Third-Party Dependencies

This project depends on third-party Flutter and Dart packages.
Vulnerabilities affecting these dependencies should be reported **if they have a direct security impact on the application**.

---

## 🤝 Responsible Disclosure

Please allow reasonable time for investigation and remediation before public disclosure. Responsible reporting helps maintain the safety and integrity of the project and its users.


