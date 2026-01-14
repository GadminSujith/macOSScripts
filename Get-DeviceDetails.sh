#!/bin/sh
set -eu

file="$HOME/Library/Application Support/com.microsoft.CompanyPortalMac.usercontext.info"

json_escape() {
  # escape backslash, quotes, CR/LF for JSON strings
  s=$1
  s=$(printf "%s" "$s" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\r/\\r/g; s/\n/\\n/g')
  printf "%s" "$s"
}

first_match() {
  data=$1
  re=$2
  printf "%s\n" "$data" | grep -iE "$re" | head -n 1
}

IntunedeviceId=$(logfile=$(ls /Library/Logs/Microsoft/Intune/*.log | grep -m1 "IntuneMDMDaemon")
grep -m1 "DeviceId:" "$logfile" | grep -oE '[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}' | head -n 1)


if [ ! -f "$file" ]; then
  printf '{\n  "error": "Company Portal user context file not found (user not signed in?)",\n  "path": "%s"\n}\n' "$(json_escape "$file")"
  exit 1
fi

# Pull only <string>...</string> inner values
vals=$(strings "$file" | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p')

upn=$(first_match "$vals" '^[^<>" ]+@[^<>" ]+\.[^<>" ]+$')
tenantId=$(first_match "$vals" '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$')
homeAccountId=$(first_match "$vals" '^[0-9a-f-]+\.[0-9a-f-]+$')

serial=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F\" '/IOPlatformSerialNumber/{print $4}' | head -n 1)
#hardwareUuid=$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Hardware UUID/{print $2}' | head -n 1)

printf '{\n'
printf '  "upn": "%s",\n' "$(json_escape "$upn")"
printf '  "tenantId": "%s",\n' "$(json_escape "$tenantId")"
printf '  "homeAccountId": "%s",\n' "$(json_escape "$homeAccountId")"
printf '  "device": {\n'
printf '    "serialNumber": "%s",\n' "$(json_escape "$serial")"
printf '    "IntunedeviceId": "%s"\n' "$(json_escape "$IntunedeviceId")"
printf '  }\n'
printf '}\n'