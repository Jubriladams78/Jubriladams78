# KB-003: Printer Shows Jobs Stuck in Queue

## For end users
If your print job doesn't come out, **don't press Print again.** Repeated jobs make the queue worse. Call the Service Desk and tell us the printer name from the sticker on the printer.

## For technicians
1. Confirm the printer is reachable: `ping <printer IP>` and check its display for paper or toner errors.
2. On the print server (or a local PC for a direct-IP printer), run as admin:
   ```powershell
   Stop-Service -Name Spooler -Force
   Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*" -Force
   Start-Service -Name Spooler
   ```
3. Send a test page. Confirm with the user on the floor. For a clinical printer (wristbands, labels), **call the floor** rather than relying on email.
4. If the queue jams again within 24 hours, open a problem record: the cause may be a driver or a malformed job from one application.

**Impact note:** Wristband or label printers affect patient admission. Treat as P2 minimum.
