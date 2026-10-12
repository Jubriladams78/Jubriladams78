# Onboarding and Offboarding Runbook

## Onboarding (Service Request)
- [ ] HR ticket received with employee ID, start date, manager, department, and role
- [ ] AD account created in the correct OU (`New-BulkUsers.ps1`)
- [ ] Role-based security groups assigned (department share, EHR role group)
- [ ] Microsoft 365 license assigned through the group, and the mailbox confirmed
- [ ] MFA registration instructions included in the welcome packet
- [ ] Laptop imaged/enrolled (Intune Autopilot), asset tag recorded against the user
- [ ] Temporary password delivered to the **manager** through a secure channel
- [ ] Day-1 check-in call scheduled with the user

## Offboarding (security-critical, same day)
- [ ] Ticket from HR with **termination date and time** (involuntary terminations are handled immediately)
- [ ] Disable the AD account and **revoke Entra sessions**
- [ ] Reset the password (a random value, not given to anyone)
- [ ] Remove from all groups except Domain Users and record the removed groups in the ticket
- [ ] Move to the `Disabled Users` OU and add the description `Disabled <date> per <ticket>`
- [ ] Convert the mailbox to shared or forward it to the manager if HR approves
- [ ] Remove the MFA methods and the mobile device from Intune (wipe company data)
- [ ] Recover the laptop and badge, and update the asset record
- [ ] `Get-ADAccountHealth.ps1` confirms the user no longer appears as "Disabled but still in groups"

**Why it matters:** At a healthcare company, an account left active after an employee leaves is a potential HIPAA breach.
