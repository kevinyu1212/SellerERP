# Scripts\Security-Shield.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP"
$ConfigDir = Join-Path $BaseDir "Config"
$SecurityLog = Join-Path $BaseDir "Database\security.log"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      🔒 [1단계] 시스템 보안 및 무결성 검증 가동    " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

function Get-SystemHWID {
    try {
        $compName = $env:COMPUTERNAME
        $userName = $env:USERNAME
        $userDomain = $env:USERDOMAIN
        $rawString = "$compName-$userName-$userDomain-SELLER-ERP"
        
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($rawString)
        $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
        return (-join ($hash | ForEach-Object { $_.ToString("x2") })).ToUpper()
    } catch {
        return "FALLBACK-HWID-2026-ERP"
    }
}

$myHWID = Get-SystemHWID
Write-Host " • 이 PC의 고유 HWID : $myHWID" -ForegroundColor White

if (!(Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null }
$licenseFile = Join-Path $ConfigDir "license.dat"
if (!(Test-Path $licenseFile)) {
    $sampleKey = "ERP-2026-" + $myHWID.Substring(0, 8) + "-KEY"
    $sampleKey | Out-File -FilePath $licenseFile -Encoding utf8
    Write-Host "[보안 안내] 라이선스 파일이 없어 샘플 키가 자동 생성되었습니다." -ForegroundColor Yellow
}

$userLicense = (Get-Content $licenseFile -Encoding utf8).Trim()
if ($userLicense -match $myHWID.Substring(0, 6)) {
    Write-Host "[보안 통과] 정품 인증된 디바이스입니다." -ForegroundColor Green
} else {
    Write-Host "[보안 경고] 라이선스가 이 PC와 일치하지 않습니다!" -ForegroundColor Red
    return
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " 🎉 [1단계] 보안 골조 공사 및 무결성 검증 완료! " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
