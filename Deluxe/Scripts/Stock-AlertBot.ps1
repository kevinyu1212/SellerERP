# Deluxe\Scripts\Stock-AlertBot.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP\Deluxe"
$DatabaseDir = Join-Path $BaseDir "Database"

$StockCheckFile = Join-Path $DatabaseDir "inventory_status.csv"
$AlertLogFile = Join-Path $DatabaseDir "stock_alert_log.csv"

# 샘플 재고 및 안전재고 데이터 생성
"상품명,현재고,안전재고`r`n프리미엄 원목 캣타워,2,5`r`n고양이 자동 급식기,12,5" | Set-Content -Path $StockCheckFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      🔔 [Deluxe 3번] 실시간 재고 품절 임박 스마트 알림 봇 " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$stocks = Import-Csv -Path $StockCheckFile -Encoding UTF8
$alerts = foreach ($item in $stocks) {
    $current = [int]$item.현재고
    $safe = [int]$item.안전재고

    $isWarning = $current -le $safe
    $statusMsg = if ($isWarning) { "🚨 [긴급경고] 품절 임박! 즉시 발주 필요" } else { "✅ [안정] 재고 여유 있음" }

    [PSCustomObject]@{
        상품명 = $item.상품명
        현재고 = "$current 개"
        안전재고기준 = "$safe 개"
        상태알림 = $statusMsg
    }
}

$alerts | Export-Csv -Path $AlertLogFile -NoTypeInformation -Encoding utf8

Write-Host " • [알림 봇 구동 완료] 실시간 품절 임박 검사 및 경고 로그가 생성되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $AlertLogFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
