# Collect device & user information from macOS device managed by Intune

This script collects user identity and device identity information from a macOS device that is enrolled in Microsoft Intune and signed in to Microsoft Company Portal.

It produces a structured JSON output that can be used for inventory, troubleshooting, or downstream automation (Logic Apps, Azure Functions, etc.), without requiring Microsoft Graph access from the device itself.


upn  --> User Principal Name of the signed-in user

tenantId --> Microsoft Entra tenant ID


IntunedeviceId --> This will be NOT entra deviceId or Object Id instead it is IntunedeviceID, it is sourced from ~/Library/Application Support/com.microsoft.CompanyPortalMac.usercontext.info

This file is created and maintained by Microsoft Company Portal after a successful user sign-in and represents the most reliable local source of user identity context on macOS.


serialNumber --> Hardware serial number


IntunedeviceId --> Device ID used by Intune / Microsoft Entra, here deviceId is sourced from /Library/Logs/Microsoft/Intune/IntuneMDMDaemon*.log.

IntunedeviceId --> Device ID used by Intune / Microsoft Entra, here deviceId is sourced from /Library/Logs/Microsoft/Intune/IntuneMDMDaemon*.log



1.	Validates Company Portal user context
	•	Confirms that the Company Portal user context file exists
	•	Ensures the user is signed in

2.	Parses Company Portal cache
	•	Reads and extracts UPN, tenant ID, and home account ID

3.	Reads Intune MDM logs
	•	Locates the first IntuneMDMDaemon log
	•	Extracts the device GUID using a strict GUID regex

4.	Builds JSON output
	•	Escapes special characters
	•	Outputs a structured JSON object
