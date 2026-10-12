# KB-002: "No Internet" Troubleshooting Flow (Bottom-Up, OSI)

| Step | Command / check | If it fails, the problem is likely... |
|---|---|---|
| 1. Physical | Cable seated? Link light? Wi-Fi connected? | Cable, port, NIC, Wi-Fi |
| 2. IP address | `ipconfig /all` | `169.254.x.x` means DHCP failed. Try `ipconfig /release` then `/renew`, then check the DHCP scope |
| 3. Gateway | `ping <default gateway>` | Local network / VLAN / switch |
| 4. Outside IP | `ping 8.8.8.8` | Firewall / proxy / ISP |
| 5. DNS | `nslookup microsoft.com` | DNS server setting. Try `ipconfig /flushdns` |
| 6. Path | `tracert microsoft.com` | Shows which hop is dropping |
| 7. App | Browser / proxy settings | Proxy, certificate, app-specific issue |

**Rule:** If step 4 works but step 5 fails, it's DNS. Most "the internet is down" tickets are DNS or DHCP.

**Escalate** to Network when multiple users on the same switch or subnet are affected, or when a DHCP scope is above 90% used.
