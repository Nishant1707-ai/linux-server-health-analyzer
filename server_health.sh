#!/bin/bash

update_status() {
    if [ "$1" = "CRITICAL" ]; then
        OVERALL_STATUS="CRITICAL"
    elif [ "$1" = "WARNING" ] && [ "$OVERALL_STATUS" != "CRITICAL" ]; then
        OVERALL_STATUS="WARNING"
    fi
}
if [ "$(uname -s)" != "Linux" ]; then
    echo "ERROR: This script must be run on Linux."
    exit 1
fi

REPORT_DIR="reports"
REPORT_FILE="$REPORT_DIR/health_report_$(date +%Y-%m-%d_%H-%M-%S).txt"

mkdir -p "$REPORT_DIR"

exec > >(tee "$REPORT_FILE") 2>&1

OVERALL_STATUS="HEALTHY"

echo "========================================="
echo "      LINUX SERVER HEALTH ANALYZER"
echo "========================================="

echo
echo "Hostname:"
hostname

echo
echo "Current Date & Time:"
date

echo
echo "System Uptime:"
uptime -p

required_commands=("awk" "grep" "systemctl" "journalctl" "df" "free" "ps")

for command in "${required_commands[@]}"
do
    if ! command -v "$command" > /dev/null 2>&1
    then
        echo "ERROR: Required command '$command' is not installed."
        exit 1
    fi
done
show_usage() {
    echo "Usage: $0"
    echo
    echo "Linux Server Health & Log Analyzer"
    echo "Checks CPU, memory, disk, services, logs, SSH security,"
    echo "processes, and network connectivity."
}

check_cpu() {
echo
echo "========================================="
echo "CPU INFORMATION"
echo "========================================="

echo "CPU Cores:"
nproc

echo
echo "CPU Load:"
uptime | awk -F'load average:' '{ print $2 }'
CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {print 100 - $8}')

CPU_USAGE=${CPU_USAGE%.*}

echo
echo "CPU Usage: ${CPU_USAGE}%"

if [ "$CPU_USAGE" -lt 70 ]; then
    echo "CPU Status: HEALTHY"
elif [ "$CPU_USAGE" -lt 90 ]; then
    echo "CPU Status: WARNING"
else
    echo "CPU Status: CRITICAL"
fi
}

check_memory() {
echo
echo "========================================="
echo "MEMORY INFORMATION"
echo "========================================="

free -h
MEMORY_USAGE=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')

echo
echo "Memory Usage: ${MEMORY_USAGE}%"

if [ "$MEMORY_USAGE" -lt 70 ]; then
    echo "Memory Status: HEALTHY"
elif [ "$MEMORY_USAGE" -lt 90 ]; then
    echo "Memory Status: WARNING"
else
    echo "Memory Status: CRITICAL"
fi
}

check_disk() {
echo
echo "========================================="
echo "DISK INFORMATION"
echo "========================================="

df -h
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

echo
echo "Disk Usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -lt 70 ]; then
    echo "Disk Status: HEALTHY"
elif [ "$DISK_USAGE" -lt 90 ]; then
    echo "Disk Status: WARNING"
else
    echo "Disk Status: CRITICAL"
fi
}

check_service() {

echo
echo "========================================="
echo "SERVICE HEALTH"
echo "========================================="

services=("sshd" "nfs-server" "nginx")

for service in "${services[@]}"
do
    if systemctl is-active --quiet "$service"
    then
        echo "$service : RUNNING"
    else
    echo "$service : STOPPED"
    update_status "WARNING"
fi
done
}

analyze_logs() {
echo "========================================="
echo "LOG ANALYSIS"
echo "========================================="

echo
echo "Recent ERROR messages:"
journalctl -p err -n 10 --no-pager
}

check_ssh() {
echo "========================================="
echo "FAILED SSH LOGIN ATTEMPTS"
echo "========================================="

if [ ! -f /var/log/secure ]; then
    echo "WARNING: /var/log/secure not found."
    return 0
fi

FAILED_COUNT=$(grep -ic "Failed password" /var/log/secure)

echo "Failed SSH Attempts: $FAILED_COUNT"

if [ "$FAILED_COUNT" -le 5 ]; then
    echo "SSH Security Status: HEALTHY"
elif [ "$FAILED_COUNT" -le 10 ]; then
    echo "SSH Security Status: WARNING"
    update_status "WARNING"
else
    echo "SSH Security Status: CRITICAL"
    update_status "CRITICAL"
fi
echo
echo "Suspicious IP Addresses:"

grep "Failed password" /var/log/secure \
| awk '{print $(NF-3)}' \
| sort \
| uniq -c \
| sort -nr \
| head -10

echo
echo "========================================="
echo "SECURITY SUMMARY"
echo "========================================="

echo "Failed SSH Attempts : $FAILED_COUNT"

if [ "$FAILED_COUNT" -eq 0 ]; then
    echo "Overall Security   : HEALTHY"
elif [ "$FAILED_COUNT" -le 10 ]; then
    echo "Overall Security   : WARNING"
else
    echo "Overall Security   : CRITICAL"
fi

echo
echo "Top Failed Login Sources:"
grep "Failed password" /var/log/secure \
| awk '{print $(NF-3)}' \
| sort \
| uniq -c \
| sort -nr \
| head -5
}

check_processes() {
echo
echo "========================================="
echo "TOP CPU PROCESSES"
echo "========================================="

ps -eo pid,comm,%cpu --sort=-%cpu | head -6

echo
echo "========================================="
echo "TOP MEMORY PROCESSES"
echo "========================================="

ps -eo pid,comm,%mem --sort=-%mem | head -6
}

check_network() {
echo
echo "========================================="
echo "NETWORK CONNECTIVITY"
echo "========================================="

if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1
then
    echo "Internet Connectivity: OK"
else
    echo "Internet Connectivity: FAILED"
    update_status "CRITICAL"
fi
}

echo
echo "========================================="
echo "HEALTH CHECK COMPLETED"
echo "========================================="

show_overall_status() {
    echo
    echo "========================================="
    echo "OVERALL SERVER STATUS"
    echo "========================================="

    echo "Overall Server Status: $OVERALL_STATUS"
}
show_usage
check_cpu
check_memory
check_disk
check_service
analyze_logs
check_ssh
check_processes
check_network
show_overall_status

