# Premium\Scripts\Hometax-TaxPackaging.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP\Premium"
$DatabaseDir = Join-Path $BaseDir "Database"

$TaxPackageSource = Join-Path $DatabaseDir "hometax_raw_ledger.csv"
$TaxPackageResult = Join-Path $DatabaseDir "hometax_final_report.csv"

# 샘플 홈택스 신고용 세무 원장 데이터 생성
"분류,거래건수,공급가액합계,세액합계,제출상태`r`n과세매출(전자세금계산서),45,12500000,1250000,제출준비완료`r`n매입세액(사업용신용카드),32,4100000,410000,제출준비완료" | Set-Content -Path $TaxPackageSource -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      🧾 [Premium 4번] 홈택스 연동형 세무 패키징 가동     " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$ledgers = Import-Csv -Path $TaxPackageSource -Encoding UTF8
$packagedReports = foreach ($row in $ledgers) {
    [PSCustomObject]@{
        세무신고항목 = $row.분류
        총거래건수 = "$([int]$row.거래건수) 건"
        공급가액 = "$([int]$row.공급가액합계) 원"
        부가세액 = "$([int]$row.세액합계) 원"
        홈택스제출상태 = "✅ [패키징 완료] $($row.제출상태)"
    }
}

$packagedReports | Export-Csv -Path $TaxPackageResult -NoTypeInformation -Encoding utf8

Write-Host " • [세무 패키징 완료] 홈택스 제출용 종합 부가세 신고 데이터가 생성되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $TaxPackageResult" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
