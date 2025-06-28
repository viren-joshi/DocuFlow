import resend

resend.api_key = ""

params: resend.Emails.SendParams = {
  "from": "Docuflow <docuflow-notifications@resend.dev>",
  "to": ["viren.joshi.ca@gmail.com"],
  "subject": "Approve this document",
  "html": "<p>it works!</p>"
}

email = resend.Emails.send(params)
print(email)