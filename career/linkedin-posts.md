# LinkedIn Post Series (publish one per week)

**Rules for every post:**
- Attach a screenshot or short video. Posts with real terminal or ADUC screenshots perform far better than text alone.
- Always say "simulation" or "home lab." **Never list Meridian Health Systems as an employer.** A hiring manager who finds that out will reject you, and they will find out.
- Post Tuesday through Thursday, 7 to 9 am Central. Reply to every comment within the first hour.
- Put the GitHub link in the **first comment**, not in the post. LinkedIn shows posts with external links to fewer people.

---

## Post 1: The launch

I spent 12 years in healthcare making sure nurses and caregivers could do their jobs without technology getting in the way. Now I'm making that my full-time job.

To show IT managers how I'd work their ticket queue, I built a service desk simulation for a fictional 62,000-employee health system and worked 10 realistic tickets end to end in my Windows Server 2025 lab:

🔐 Account lockouts. I traced the source with Event ID 4740 instead of just unlocking again and again.
🖨️ A wristband printer down on a clinical floor, treated as P2 because it delays patient admissions
🎣 A user who clicked a phishing link: contain first, then escalate to security
👥 5 new hires onboarded in minutes with a PowerShell script
📈 40 lockouts in an hour, recognized as a *problem* rather than 40 separate tickets

Every ticket includes triage, steps, root cause, and a knowledge base article.

What I learned: the technical fix is usually the easy part. The hard part is verifying identity before resetting MFA, explaining things clearly to a stressed user, and noticing patterns.

I'm looking for my first Service Desk / IT Support role in the Chicago area, ideally in healthcare. If you lead a help desk team, I'd value 10 minutes of your feedback on this project.

Link in comments 👇

#ITSupport #HelpDesk #HealthcareIT #ActiveDirectory #PowerShell #OpenToWork

---

## Post 2: One ticket, explained

"I keep getting locked out every 20 minutes."

This is one of the most common tickets on any help desk. Here's how I handle it in my lab:

1️⃣ Verify identity. Always, even when the person on the phone is a busy nurse.
2️⃣ Check the account: locked, with 5 bad password attempts
3️⃣ Find the *source*: Event ID 4740 on the domain controller
4️⃣ The source was the email server. The user's phone was still using the old password.
5️⃣ Fix the phone first, *then* unlock

If you unlock without finding the source, you get the same ticket again 20 minutes later and a frustrated user.

Help desk folks: what's your go-to tool for tracking down lockout sources?

[Attach: screenshot of the 4740 event + PowerShell output]

---

## Post 3: Security mindset

A user calls: "I clicked a DocuSign link, typed my password, and the page went blank."

In my service desk lab, I practice the order that matters:
1. Disable the account and revoke active sessions
2. Reset the password and require MFA to be set up again
3. Isolate the workstation
4. Escalate to the security team with the headers and the defanged URL
5. Thank the user for reporting it quickly

Step 5 matters. If people get blamed for clicking, they stop reporting, and an unreported click does far more damage than one that's reported quickly.

Security+ taught me the concepts. Working the ticket showed me what to do first.

---

## Post 4: Reflection / call to action

30 days ago I started building out my IT support portfolio in public. What I've done so far:
✅ A 10-ticket service desk simulation
✅ 3 PowerShell tools for real help desk tasks
✅ Knowledge base articles written for both end users and technicians
✅ [X] conversations with IT leaders, who gave me great feedback

The biggest lesson: help desk work is a mix of customer service, security, and pattern recognition, and the technical skills are only part of it. That's what I did in healthcare for 12 years, minus the PowerShell.

I'm still looking for my first Service Desk role. If your team is hiring, or you know someone who is, I'd be grateful for an introduction.
