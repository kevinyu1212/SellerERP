# Scripts\Purchase-Generator.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP"
$DatabaseDir = Join-Path $BaseDir "Database"

$StockFile = Join-Path $DatabaseDir "stock_status.csv"
$PurchaseFile = Join-Path $DatabaseDir "auto_purchase_sheet.csv"

# 샘플 재고 현황 데이터 생성 (캣타워 재고 부족 상황 연출)
"상품명,현재고,안전재고,일일출고량`r`n프리미엄 원목 캣타워,2,5,2`r`n고양이 자동 급식기,15,5,1" | Set-Content -Path $StockFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      📋 [3단계] 엑셀 자동 발주서 생성기 가동       " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$stocks = Import-Csv -Path $StockFile -Encoding UTF8
$purchaseList = foreach ($item in $stocks) {
    $currentStock = [int]$item.현재고
    $safeStock = [int]$item.안전재고
    
    if ($currentStock -le $safeStock) {
        $neededQty = ($safeStock * 2) - $currentStock # 여유 있게 안전재고의 2배 수준으로 발주 산정
        [PSCustomObject]@{
            상품명 = $item.상품명
            현재고 = $currentStock
            권장발주수량 = $neededQty
            상태 = "🚨 긴급 발주 필요"
        }
    }
}

if ($purchaseList) {
    $purchaseList | Export-Csv -Path $PurchaseFile -NoTypeInformation -Encoding utf8
    Write-Host " • [발주서 생성 완료] 안전재고 미만 품목에 대한 사입 발주서가 자동 생성되었습니다!" -ForegroundColor Green
    Write-Host " • [출력 파일] $PurchaseFile" -ForegroundColor Yellow
} else {
    Write-Host " • [안정] 현재 긴급하게 발주가 필요한 품목이 없습니다." -ForegroundColor Green
}

Write-Host "==================================================" -ForegroundColor Cyan
