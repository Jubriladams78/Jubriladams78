# Enterprise Service Desk Simulation: Meridian Health Systems

> **Simulation lab.** Meridian Health Systems is a fictional company I designed to practice Tier 1 and Tier 2 service desk work at Fortune 500 scale. The tickets, users, and metrics here are simulated. Everything technical, including the scripts, the AD changes, and the troubleshooting steps, was performed in my own Hyper-V lab running Windows Server 2025 and Windows 11.

## The Scenario

| Item | Value |
|---|---|
| Company | Meridian Health Systems (fictional) |
| Industry | Healthcare delivery, Fortune 500 scale |
| Employees | ~62,000 across 38 hospitals and 210 clinics |
| Identity | On-prem Active Directory synced to Microsoft Entra ID |
| Endpoints | Windows 11 Enterprise, managed by Group Policy and Intune |
| Productivity | Microsoft 365 (Exchange Online, Teams, OneDrive) |
| Clinical system | EHR (generic; access controlled by AD security groups) |
| Compliance | HIPAA. Every ticket that touches patient data access is handled under least privilege and logged |
| ITSM model | ITIL 4: Incident, Service Request, Problem, Change |
| My role | Service Desk Analyst, Tier 1 with Tier 2 escalation |

## What This Project Demonstrates

| Hiring manager asks | Where the evidence is |
|---|---|
| Can you work a ticket queue and prioritize? | [`tickets/`](tickets/): 10 tickets, P1 to P4, with triage, steps, root cause, and closure notes |
| Do you know Active Directory? | [`scripts/New-BulkUsers.ps1`](scripts/New-BulkUsers.ps1), [`scripts/Get-ADAccountHealth.ps1`](scripts/Get-ADAccountHealth.ps1) |
| Can you troubleshoot endpoints? | [`scripts/Get-EndpointHealth.ps1`](scripts/Get-EndpointHealth.ps1), tickets INC-1003, INC-1006, INC-1008 |
| Can you write documentation users can follow? | [`kb/`](kb/): knowledge base articles in two versions, one for end users and one for technicians |
| Do you understand onboarding and offboarding? | [`runbooks/onboarding-offboarding.md`](runbooks/onboarding-offboarding.md) |
| Can you communicate during an outage? | [`runbooks/major-incident-communication.md`](runbooks/major-incident-communication.md) |
| Do you understand security? | Phishing ticket INC-1007, MFA ticket INC-1002, offboarding access removal |

## Lab Architecture

```
                 ┌────────────────────────────┐
                 │  Hyper-V host (my PC)      │
                 │                            │
  ┌──────────────┴───────┐      ┌─────────────┴──────────┐
  │ MHS-DC01             │      │ MHS-WS-0142            │
  │ Windows Server 2025  │◄────►│ Windows 11 Enterprise  │
  │ AD DS, DNS, DHCP,    │      │ Domain-joined client   │
  │ GPO, File shares     │      │ (end-user simulation)  │
  └──────────────────────┘      └────────────────────────┘
     Domain: corp.meridianhealth.lab
     OUs: Corporate / Clinical / IT / Disabled Users
```

## Ticket Summary

| ID | Priority | Category | Issue | Outcome |
|---|---|---|---|---|
| INC-1001 | P3 | Identity | Nurse locked out after password change | Resolved. Found stale credentials on a mobile device |
| INC-1002 | P3 | Identity / MFA | New phone, cannot complete MFA | Resolved through an identity-verified MFA reset |
| INC-1003 | P3 | Endpoint | Laptop very slow, disk 98% full | Resolved. Cleanup plus a root cause in OneDrive sync |
| SR-1004 | P4 | Access | Request access to the department shared drive | Fulfilled after manager approval |
| INC-1005 | P2 | Printing | Clinical floor printer not printing wristbands | Resolved. Stuck spooler, documented in KB-003 |
| INC-1006 | P3 | Network | "No internet" on one workstation | Resolved. APIPA address, DHCP lease renewal |
| INC-1007 | P2 | Security | User clicked a phishing link | Contained, escalated to SOC, credentials reset |
| INC-1008 | P3 | M365 | Outlook not syncing, stuck "Disconnected" | Resolved by rebuilding the Outlook profile |
| SR-1009 | P4 | Onboarding | 5 new hires starting Monday | Fulfilled with the bulk AD script |
| PRB-1010 | P1 | Problem | 40 lockouts in 1 hour after a password policy change | Root cause found, change rolled back |

## How to Reproduce

1. Build a domain controller and a client (see my [Windows Server 2025 lab](https://github.com/Jubriladams78/windows-server-2025-ad-dns-gpo-lab)).
2. Create the OUs: `Corporate`, `Clinical`, `IT`, `Disabled Users`.
3. Run `scripts/New-BulkUsers.ps1 -CsvPath data/new_hires.csv -WhatIf` first, then run it without `-WhatIf`.
4. Work through each ticket in `tickets/` on your own lab.

## Skills Used

Active Directory Users and Computers, PowerShell (ActiveDirectory module), Group Policy, DNS, DHCP, ipconfig/nslookup/ping/tracert, Event Viewer, Print Management, Microsoft 365 admin concepts, Entra ID MFA, ITIL 4 incident/request/problem management, HIPAA-aware access handling, knowledge base writing.
