# Premium\Scripts\AutoCS-TemplateGenerator.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP\Premium"
$DatabaseDir = Join-Path $BaseDir "Database"

$CsMasterFile = Join-Path $DatabaseDir "cs_templates_source.csv"
$CsResultFile = Join-Path $DatabaseDir "cs_macro_clipboard.csv"

# 샘플 CS 응대 상황 및 맞춤 템플릿 데이터 생성
"문의유형,상황별키워드,자동응대템플릿`r`n배송지연,배송 언제 되나요?,고객님, 상품은 안전하게 출고 준비 중이며 택배사 사정에 따라 순차 배송되고 있습니다. 조금만 기다려 주시면 감사하겠습니다!`r`n파손문의,상품이 부서져서 왔어요.,고객님, 이용에 불편을 드려 대단히 죄송합니다. 파손된 부분의 사진을 남겨주시면 즉시 새 상품으로 맞교환 또는 환불 처리 도와드리겠습니다." | Set-Content -Path $CsMasterFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      🤖 [Premium 2번] 무인 자동 CS 템플릿 제너레이터 " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$templates = Import-Csv -Path $CsMasterFile -Encoding UTF8
$macroResults = foreach ($t in $templates) {
    [PSCustomObject]@{
        문의유형 = $t.문의유형
        인식키워드 = $t.상황별키워드
        클립보드매크로템플릿 = $t.자동응대템플릿
        매크로상태 = "⚡ 단축키 연동 대기중 (클립보드 복사 준비 완료)"
    }
}

$macroResults | Export-Csv -Path $CsResultFile -NoTypeInformation -Encoding utf8

Write-Host " • [CS 매크로 완료] 무인 자동 응대 템플릿 리포트가 생성되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $CsResultFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
