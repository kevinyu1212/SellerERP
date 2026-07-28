# Scripts\Competitor-Monitor.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP"
$DatabaseDir = Join-Path $BaseDir "Database"

$CompFile = Join-Path $DatabaseDir "competitor_prices.csv"
$CompResultFile = Join-Path $DatabaseDir "competitor_monitoring_report.csv"

# 샘플 경쟁사 가격 비교 데이터 생성 (내 가격 vs 경쟁사 평균 가격)
"상품명,내판매가격,경쟁사최저가,가격차이메모`r`n프리미엄 원목 캣타워,65000,59000,경쟁사 우위`r`n고양이 자동 급식기,32000,34000,자사 우위" | Set-Content -Path $CompFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      🔍 [4번 확장] 경쟁사 가격 모니터링 봇 가동      " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$products = Import-Csv -Path $CompFile -Encoding UTF8
$monitoringReports = foreach ($item in $products) {
    $myPrice = [double]$item.내판매가격
    $compPrice = [double]$item.경쟁사최저가

    $alertStatus = if ($myPrice -gt $compPrice) { 
        $diff = $myPrice - $compPrice
        "⚠️ 경고: 경쟁사보다 $diff 원 비쌈 (가격 조정 검토)" 
    } else { 
        "✅ 안정: 경쟁사 대비 가격 경쟁력 확보 중" 
    }

    [PSCustomObject]@{
        상품명 = $item.상품명
        내가격 = "$myPrice 원"
        경쟁사최저가 = "$compPrice 원"
        모니터링결과 = $alertStatus
    }
}

$monitoringReports | Export-Csv -Path $CompResultFile -NoTypeInformation -Encoding utf8

Write-Host " • [모니터링 완료] 경쟁사 가격 비교 및 대응 리포트가 생성되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $CompResultFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
