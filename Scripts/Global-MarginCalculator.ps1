# Scripts\Global-MarginCalculator.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP"
$DatabaseDir = Join-Path $BaseDir "Database"

$GlobalFile = Join-Path $DatabaseDir "global_sales_data.csv"
$GlobalResultFile = Join-Path $DatabaseDir "global_margin_report.csv"

# 샘플 글로벌 역직구 상품 데이터 생성 (USD 기준)
"상품명,현지판매가USD,매입원가KRW,국제배송비KRW`r`n프리미엄 원목 캣타워,89.00,35000,15000`r`n고양이 자동 급식기,45.00,18000,8000" | Set-Content -Path $GlobalFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      🌍 [2번 확장] 글로벌 환율 및 마진 계산기 가동    " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 가상의 기준 환율 (1 USD = 1,350원 가정)
$ExchangeRate = 1350.0

$items = Import-Csv -Path $GlobalFile -Encoding UTF8
$globalReports = foreach ($item in $items) {
    $usdPrice = [double]$item.현지판매가USD
    $purchaseCost = [double]$item.매입원가KRW
    $shippingCost = [double]$item.국제배송비KRW
    
    $revenueKrw = $usdPrice * $ExchangeRate
    # 플랫폼 수수료 약 15% 가정
    $platformFee = $revenueKrw * 0.15
    $netProfit = $revenueKrw - $purchaseCost - $shippingCost - $platformFee
    $marginRate = [Math]::Round(($netProfit / $revenueKrw) * 100, 2)

    [PSCustomObject]@{
        상품명 = $item.상품명
        원화환산매출 = "$revenueKrw 원"
        예상순이익 = "$([Math]::Round($netProfit)) 원"
        예상순이익률 = "$marginRate %"
    }
}

$globalReports | Export-Csv -Path $GlobalResultFile -NoTypeInformation -Encoding utf8

Write-Host " • [글로벌 계산 완료] 환율 적용 및 예상 순이익 리포트가 생성되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $GlobalResultFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
