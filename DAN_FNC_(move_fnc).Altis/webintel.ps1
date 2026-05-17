# =========================
# CONFIG
# =========================
$apiKey = "AIzaSyCnXfqhmdkbYDvGysThmJxy1drVME-fVbg"
$outputFile = "webIntel.txt"

$prompt = "Give me 5 short military-style intelligence reports about recent global conflicts. Each line short."

# =========================
# JSON BODY
# =========================
$jsonBody = @"
{
  "contents": [
    {
      "parts": [
        {
          "text": "$prompt"
        }
      ]
    }
  ]
}
"@

# =========================
# API URL (FIXED)
# =========================
$uri = "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey"

# =========================
# CALL API
# =========================
try {
    Write-Host "Connecting to Gemini API..." -ForegroundColor Cyan

    $response = Invoke-RestMethod `
        -Uri $uri `
        -Method Post `
        -ContentType "application/json" `
        -Body $jsonBody

    # SAFE GET (กัน null)
    if ($response.candidates -and $response.candidates.Count -gt 0) {
        $intel = $response.candidates[0].content.parts[0].text
    } else {
        $intel = "ERROR: No response from AI"
    }

    Write-Host "SUCCESS" -ForegroundColor Green
    Write-Host $intel

} catch {
    Write-Host "ERROR detected!" -ForegroundColor Red

    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $details = $reader.ReadToEnd()
        Write-Host "Details:" -ForegroundColor Yellow
        Write-Host $details
    } else {
        Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    $intel = "ERROR: Gemini request failed"
}

# =========================
# SAVE FILE (UTF8 BOM สำคัญมาก)
# =========================
try {
    $utf8 = New-Object System.Text.UTF8Encoding($true)  # 🔥 ต้อง true
    [System.IO.File]::WriteAllText($outputFile, $intel, $utf8)

    Write-Host "Saved → $outputFile" -ForegroundColor Cyan

} catch {
    Write-Host "Failed to save file: $($_.Exception.Message)" -ForegroundColor Red
}