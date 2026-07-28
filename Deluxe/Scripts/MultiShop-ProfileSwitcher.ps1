# Deluxe\Scripts\MultiShop-ProfileSwitcher.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP\Deluxe"
$DatabaseDir = Join-Path $BaseDir "Database"

$ProfileFile = Join-Path $DatabaseDir "multishop_accounts.csv"
$ProfileResultFile = Join-Path $DatabaseDir "active_profile_status.csv"

# 샘플 멀티샵 계정 프로필 데이터 생성
"채널명,사업자상호,API상태,활성여부`r`n네이버스마트스토어,펫러버즈몰,연동완료,ACTIVE`r`n쿠팡윙파트너스,펫러버즈코리아,연동완료,STANDBY" | Set-Content -Path $ProfileFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      🔀 [Deluxe 4번] 다계정 멀티샵 프로필 스위처 가동    " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$accounts = Import-Csv -Path $ProfileFile -Encoding UTF8
$profileStatus = foreach ($acc in $accounts) {
    $isActive = $acc.활성여부 -eq "ACTIVE"
    $statusText = if ($isActive) { "🟢 [현재 구동중] 메인 판매 채널" } else { "⚪ [대기중] 서브 채널 전환 대기" }

    [PSCustomObject]@{
        판매채널 = $acc.채널명
        상호명 = $acc.사업자상호
        API인증 = $acc.API상태
        채널구동상태 = $statusText
    }
}

$profileStatus | Export-Csv -Path $ProfileResultFile -NoTypeInformation -Encoding utf8

Write-Host " • [프로필 스위처 완료] 멀티샵 계정 환경 리포트가 생성되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $ProfileResultFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
