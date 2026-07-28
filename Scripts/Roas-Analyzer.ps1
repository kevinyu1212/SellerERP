# Scripts\Roas-Analyzer.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP"
$DatabaseDir = Join-Path $BaseDir "Database"

$AdFile = Join-Path $DatabaseDir "ad_performance.csv"
$RoasResultFile = Join-Path $DatabaseDir "roas_analysis_report.csv"

# 샘플 광고 성과 데이터 생성
"상품명,총매출액,광고비,마진율`r`n프리미엄 원목 캣타워,350000,50000,0.30`r`n고양이 자동 급식기,120000,40000,0.25" | Set-Content -Path $AdFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      💰 [4단계] 광고비 효율 (ROAS) 분석기 가동      " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$ads = Import-Csv -Path $AdFile -Encoding UTF8
$analysisList = foreach ($item in $ads) {
    $revenue = [double]$item.총매출액
    $adCost = [double]$item.광고비
    $marginRate = [double]$item.마진율
    
    # ROAS 계산 (매출액 / 광고비 * 100)
    $roas = if ($adCost -gt 0) { [Math]::Round(($revenue / $adCost) * 100, 2) } else { 0 }
    
    # 순이익 산출 (매출액 * 마진율 - 광고비)
    $netProfit = ($revenue * $marginRate) - $adCost
    
    $status = if ($roas -ge 400) { "🔥 고효율 (확대 추천)" } elseif ($roas -ge 200) { "💡 보통 (유지)" } else { "⚠️ 저효율 (광고비 조정 필요)" }

    [PSCustomObject]@{
        상품명 = $item.상품명
        ROAS = "$roas%"
        순이익 = "$netProfit 원"
        효율상태 = $status
    }
}

$analysisList | Export-Csv -Path $RoasResultFile -NoTypeInformation -Encoding utf8

Write-Host " • [ROAS 분석 완료] 광고 집행 상품별 효율 및 순이익 산출 리포트가 생성되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $RoasResultFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
