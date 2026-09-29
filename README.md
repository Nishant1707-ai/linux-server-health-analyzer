# 🐧 Linux Server Health & Log Analyzer

A Bash-based Linux server monitoring and log analysis tool designed to automate basic server health checks, service monitoring, security analysis, and report generation.

## 📌 Project Overview

The **Linux Server Health & Log Analyzer** collects important system information and evaluates the health of a Linux server using Bash and standard Linux utilities.

The script provides health statuses such as **HEALTHY, WARNING, and CRITICAL** based on configurable thresholds.

## 🚀 Features

* CPU usage monitoring
* Memory usage monitoring
* Disk usage monitoring
* CPU and memory process monitoring
* Linux service monitoring using `systemctl`
* System error analysis using `journalctl`
* Failed SSH login detection
* Failed-login source IP extraction
* SSH security status classification
* Internet connectivity check
* Overall server health status
* Timestamped health reports
* Basic error handling and command validation
* Modular Bash functions

## 🛠️ Technologies & Tools

* **Bash**
* **Linux**
* `systemctl`
* `journalctl`
* `awk`
* `grep`
* `sed`
* `df`
* `free`
* `ps`
* `ping`
* Git & GitHub

## 📂 Project Structure

```text
linux-server-health-analyzer/
│
├── server_health.sh
├── README.md
├── .gitignore
│
├── screenshots/
│   ├── health-dashboard.png
│   ├── service-monitoring.png
│   ├── log-analysis.png
│   └── security-analysis.png
│
└── reports/
    └── health_report_YYYY-MM-DD_HH-MM-SS.txt
```

## ⚙️ Requirements

The script is designed for a Linux environment with:

* Bash
* systemd
* `awk`
* `grep`
* `journalctl`
* `systemctl`
* `df`
* `free`
* `ps`
* `ping`

For RHEL-based systems, authentication logs are analyzed from:

```text
/var/log/secure
```

Root/sudo privileges may be required for accessing certain system logs.

## ▶️ Usage

Clone the repository:

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd linux-server-health-analyzer
```

Give execute permission:

```bash
chmod +x server_health.sh
```

Run the analyzer:

```bash
sudo ./server_health.sh
```

A timestamped report is automatically generated inside:

```text
reports/
```

## 📊 Health Thresholds

The analyzer uses thresholds to classify system conditions.

### CPU / Memory / Disk

| Usage         | Status   |
| ------------- | -------- |
| Below 70%     | HEALTHY  |
| 70%–89%       | WARNING  |
| 90% or higher | CRITICAL |

### SSH Security

| Failed Attempts | Status   |
| --------------- | -------- |
| 0–5             | HEALTHY  |
| 6–10            | WARNING  |
| More than 10    | CRITICAL |

These thresholds can be modified according to the environment.

## 🔐 Security Analysis

The script analyzes failed SSH authentication attempts from:

```text
/var/log/secure
```

It counts failed password attempts and extracts the source IP addresses associated with those events.

The extracted IP addresses are presented as **potentially suspicious sources**, not automatically identified as malicious.

## 📄 Report Generation

Each execution generates a timestamped report:

```text
reports/health_report_YYYY-MM-DD_HH-MM-SS.txt
```

Generated reports are excluded from Git tracking through `.gitignore`.

## 🎯 Learning Outcomes

Through this project, I practiced:

* Bash scripting
* Variables and command substitution
* Conditional statements
* Loops
* Arrays
* Functions
* Exit codes
* Linux process management
* Linux service management
* Log analysis
* Text processing with `grep` and `awk`
* Basic shell error handling
* Git/GitHub workflow

## 🔮 Possible Future Improvements

* Email or Slack notifications
* Cron-based scheduled monitoring
* JSON/CSV report output
* Additional security checks
* Configurable thresholds
* Log rotation analysis
* Integration with monitoring platforms

## 👨‍💻 Author

**Nishant**

This project was created as part of my hands-on DevOps and Linux automation learning journey.

