# Ticket Log: Meridian Health Systems (Simulation)

Format follows a typical ServiceNow incident record. Priority = Impact × Urgency.

| Priority | Meaning | Response target | Resolve target |
|---|---|---|---|
| P1 | Critical, many users or patient care affected | 15 min | 4 hrs |
| P2 | High, a department or a clinical workflow affected | 30 min | 8 hrs |
| P3 | Medium, one user blocked | 4 hrs | 2 business days |
| P4 | Low, request or minor issue | 1 business day | 5 business days |

---

## INC-1001 | P3 | Account locked out repeatedly

**Caller:** RN, Clinical, 4 West
**Description:** "I changed my password this morning and I keep getting locked out every 20 minutes."

**Triage:** One user, can't log in to the EHR workstation, workaround available (a colleague's session is NOT allowed under HIPAA, so no workaround). Kept at P3 because one user is affected, and flagged urgent because it touches patient care.

**Steps:**
1. Verified the caller's identity with the employee ID plus the manager's name.
2. `Get-ADUser jdoe -Properties LockedOut, BadLogonCount, LastBadPasswordAttempt`, which confirmed locked with 5 bad attempts.
3. Checked Event ID **4740** on the DC (Security log) to find the lockout source computer: `CALLER_COMPUTER_NAME` was blank, and source was the Exchange/ActiveSync server.
4. Asked the user: "Do you have work email on your phone?" Yes. The phone was still using the old password.
5. Unlocked: `Unlock-ADAccount jdoe`. Had the user remove and re-add the mail account on the phone.

**Root cause:** Mobile device retrying the old password.
**Resolution:** Unlocked the account and updated the stored credentials on the phone. Monitored for 30 minutes with no further lockouts.
**KB:** [KB-001](../kb/KB-001-account-lockout.md)

---

## INC-1002 | P3 | Cannot complete MFA on new phone

**Caller:** Billing specialist, Corporate
**Description:** "Got a new phone, Authenticator app is empty, can't sign in to Outlook."

**Steps:**
1. **Identity verification is mandatory before any MFA reset** (this is the most common social engineering vector). I verified through a callback to the number on file in HR, not the number the caller gave.
2. Entra admin center: User > Authentication methods > *Require re-register MFA*.
3. Walked the user through registering Microsoft Authenticator on the new phone at `aka.ms/mysignins`.

**Resolution:** MFA re-registered and the user was able to sign in.
**Note to self:** I would never reset MFA because a caller sounded urgent or claimed to be an executive. Verify every time.

---

## INC-1003 | P3 | Laptop extremely slow

**Caller:** Analyst, Finance
**Steps:**
1. Remote session (with user consent). Ran [`Get-EndpointHealth.ps1`](../scripts/Get-EndpointHealth.ps1): C: at **98% used**, uptime 41 days, a reboot was pending.
2. Found 31 GB in `C:\Users\<user>\OneDrive`. The files were set to "Always keep on this device".
3. Changed OneDrive to Files On-Demand, ran Disk Cleanup (temp files, Windows Update cleanup), and rebooted.
4. After the reboot: C: at 54%, and the user confirmed it was responsive.

**Root cause:** Full disk from OneDrive offline files, plus 41 days without a reboot.
**Prevention:** Suggested to Tier 2 that the GPO/Intune policy enforce Files On-Demand.

---

## SR-1004 | P4 | Access to department shared drive

**Requester:** New marketing coordinator
**Steps:**
1. **Did not grant access on the user's request alone.** Sent an approval request to the data owner (the Marketing manager).
2. After approval, added the user to the security group `SG-Marketing-Share-RW`. I gave access through the group, never by adding the user directly to the folder ACL.
3. User signed out and back in to refresh the Kerberos ticket. The S: drive appeared through the GPO drive map.

**Principle:** Least privilege, approval documented in the ticket, access granted through groups.

---

## INC-1005 | P2 | Wristband printer not printing on clinical floor

**Impact:** Patient admission on 3 East delayed. A clinical workflow is affected, so P2.
**Steps:**
1. Confirmed the printer was online (it responded to ping) and the queue showed 14 stuck jobs.
2. Print server: `Stop-Service Spooler -Force`, cleared `C:\Windows\System32\spool\PRINTERS\*`, then `Start-Service Spooler`.
3. Sent a test print. Success.
4. Called the charge nurse to confirm wristbands were printing.

**Resolution time:** 22 minutes.
**KB:** [KB-003](../kb/KB-003-print-spooler.md)

---

## INC-1006 | P3 | "No internet" on one workstation

**Steps:**
1. `ipconfig /all` showed IP **169.254.x.x** (APIPA), which means the PC never got a DHCP lease.
2. Checked the physical layer: the cable was seated and the link light was on.
3. `ipconfig /release` then `ipconfig /renew` returned a valid 10.20.x.x address.
4. `nslookup corp.meridianhealth.lab` resolved, and `ping 8.8.8.8` succeeded.
5. Checked the DHCP scope on the server: it was at 97% usage. **Escalated to the network team** to extend the scope and shorten lease duration.

**Lesson:** Fixing the one PC closed the ticket. Spotting that the scope was nearly full prevented the next 20 tickets.

---

## INC-1007 | P2 | User clicked a phishing link

**Caller:** HR generalist. "I clicked a DocuSign link and entered my password, then it went to a blank page."

**Steps (in order, because speed matters):**
1. **Contain:** disabled the account temporarily and revoked sessions (`Revoke-MgUserSignInSession` / Entra "Revoke sessions").
2. Reset the password and forced MFA re-registration.
3. Isolated the workstation from the network per the security runbook.
4. **Escalated to the SOC** with the email headers, the URL (defanged: `hxxps://docu-sign-secure[.]example`), and the time of the click.
5. Reported the email with "Report Phishing" so it could be purged from other mailboxes.

**Tone with the user:** No blame. Thanked them for reporting quickly, because fast reporting is what we want people to do.

---

## INC-1008 | P3 | Outlook stuck "Disconnected"

**Steps:**
1. Checked Outlook on the web. It worked, so the mailbox was fine and the problem was on the client side.
2. Ran Microsoft Support and Recovery Assistant (SaRA). It found nothing conclusive.
3. Control Panel > Mail > Profiles: created a new profile and set it as default.
4. Outlook connected and synced.

**Root cause:** Corrupted Outlook profile / OST.

---

## SR-1009 | P4 | Onboard 5 new hires

**Steps:**
1. Received the HR onboarding form (`data/new_hires.csv`).
2. Ran `New-BulkUsers.ps1 -WhatIf` to preview, then ran it for real. Accounts were created in the correct OUs and groups.
3. Followed the [onboarding checklist](../runbooks/onboarding-offboarding.md): license, mailbox, EHR role group, and hardware.
4. Sent temporary credentials to each manager through a secure channel, never by plain email.

**Time saved:** about 10 minutes per user done manually, about 1 minute with the script.

---

## PRB-1010 | P1 (Problem record) | Mass lockouts

**Trigger:** 40 lockout tickets in 60 minutes, all after a Change (CHG-0331) that lowered the lockout threshold from 10 to 3.

**My role as Tier 1:**
1. **Recognized the pattern** after the 4th similar ticket and stopped treating each one as an isolated incident.
2. Linked all incidents to a parent ticket and notified the Service Desk lead.
3. Posted a status message using the [major incident template](../runbooks/major-incident-communication.md).
4. Ran `Get-ADAccountHealth.ps1` to give Tier 2 the exact list of locked accounts.

**Root cause (Tier 2):** The threshold of 3 was too aggressive given cached credentials on mobile devices.
**Fix:** CHG-0331 rolled back. Bulk unlock performed. A new change was raised with a threshold of 8 and user communication planned in advance.
