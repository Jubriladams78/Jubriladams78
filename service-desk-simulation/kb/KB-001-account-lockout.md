# KB-001: Account Keeps Locking Out

## For end users
**Symptom:** You are locked out again shortly after an unlock, usually right after a password change.

**Most likely cause:** A device is still trying your old password: your phone's email app, a mapped drive, or a second computer you're signed in to.

**What to do:**
1. On your phone, open Settings > Accounts/Mail, remove your work account, and add it again with your new password.
2. Sign out of any other computer you were logged in to.
3. Call the Service Desk to unlock your account. Have your employee ID ready.

## For technicians
1. Verify the caller's identity (employee ID plus a callback or the manager's name).
2. `Get-ADUser <sam> -Properties LockedOut,BadLogonCount,LastBadPasswordAttempt`
3. Find the source: on the PDC emulator, Security log **Event ID 4740**. The `Caller Computer Name` field shows the source.
   ```powershell
   Get-WinEvent -ComputerName (Get-ADDomain).PDCEmulator -FilterHashtable @{LogName='Security';Id=4740} |
     Where-Object { $_.Properties[0].Value -eq '<sam>' } | Select-Object TimeCreated,@{n='Source';e={$_.Properties[1].Value}}
   ```
4. Fix the source first, then `Unlock-ADAccount <sam>`.
5. If more than 3 lockouts are reported within 30 minutes, **stop working them one by one** and escalate as a potential problem (see PRB-1010).
