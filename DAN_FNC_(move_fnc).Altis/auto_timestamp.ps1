# ไฟล์ที่ต้องการให้เกิด timestamp stamp
$targetFiles = @(
    "FNC\core.sqf"
)

function Set-Timestamp {
    param($path)

    if (-not (Test-Path $path)) {
        Write-Warning "ไม่พบไฟล์: $path"
        return
    }

    $content = Get-Content $path
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $newLine = "DAN_V = `"Last Modified: $timestamp`";"

    if ($content.Length -gt 0 -and $content[0] -match '^DAN_V = "Last Modified:') {
        $content = $content[1..($content.Length-1)]
    }

    $newContent = @($newLine) + $content
    Set-Content $path $newContent

    Write-Host "✅ Stamped: $path"
}

# ถ้าส่ง path มาจาก args → stamp ไฟล์เดียว
# ถ้าไม่ส่ง → stamp ทุกไฟล์ใน list
if ($args[0]) {
    Set-Timestamp $args[0]
} else {
    foreach ($file in $targetFiles) {
        Set-Timestamp $file
    }
}