# Scripts\Tax-Estimator.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP"
$DatabaseDir = Join-Path $BaseDir "Database"

$SalesSummaryFile = Join-Path $DatabaseDir "sales_summary.csv"
$TaxResultFile = Join-Path $DatabaseDir "tax_estimation_report.csv"

# 샘플 매출 요약 데이터 생성
"기간,과세매출액,매입세액공제액`r`n2026년 상반기,15000000,3000000" | Set-Content -Path $SalesSummaryFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      🧾 [3번 확장] 세무 및 부가세 간이 추정기 가동    " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$data = Import-Csv -Path $SalesSummaryFile -Encoding UTF8
$taxReports = foreach ($row in $data) {
    $sales = [double]$row.과세매출액
    $deduction = [double]$row.매입세액공제액
    
    # 일반 과세자 기준 부가세 산식 (매출액의 10% - 매입세액)
    $outputTax = $sales * 0.10
    $estimatedTax = $outputTax - $deduction
    if ($estimatedTax -lt 0) { $estimatedTax = 0 }

    [PSCustomObject]@{
        조회기간 = $row.기간
        과세매출 = "$sales 원"
        예상납부부가세 = "$([Math]::Round($estimatedTax)) 원"
        안내메모 = "💡 예상 납부액을 미리 확인하고 현금 흐름을 확보하세요!"
    }
}

$taxReports | Export-Csv -Path $TaxResultFile -NoTypeInformation -Encoding utf8

Write-Host " • [세무 추정 완료] 예상 부가가치세 산출 리포트가 생성되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $TaxResultFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
