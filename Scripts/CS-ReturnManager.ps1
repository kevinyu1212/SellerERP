# Scripts\CS-ReturnManager.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP"
$DatabaseDir = Join-Path $BaseDir "Database"
if (!(Test-Path $DatabaseDir)) { New-Item -ItemType Directory -Path $DatabaseDir -Force | Out-Null }

$CsFile = Join-Path $DatabaseDir "cs_raw_requests.csv"
$CsResultFile = Join-Path $DatabaseDir "cs_return_report.csv"

# 샘플 반품/교환 CS 데이터 생성
"주문번호,고객명,요청유형,반품사유,진행상태`r`nORD-2026-001,홍길동,반품,상품 불량 (파손),수거 대기중`r`nORD-2026-002,김철수,교환,단순 변심(색상 변경),수거 완료" | Set-Content -Path $CsFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      🎧 [1번 확장] CS 및 반품/교환 자동 관리 가동    " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$requests = Import-Csv -Path $CsFile -Encoding UTF8
$processedCs = foreach ($req in $requests) {
    $actionGuide = if ($req.반품사유 -like "*불량*") { "🔍 제조사/택배사 과실 확인 후 보상 청구 필요" } 
                   elseif ($req.반품사유 -like "*변심*") { "💡 왕복 배송비 입금 확인 및 검수 후 환급" } 
                   else { "📌 일반 CS 처리 진행" }

    [PSCustomObject]@{
        주문번호 = $req.주문번호
        고객명 = $req.고객명
        요청유형 = $req.요청유형
        반품사유 = $req.반품사유
        처리상태 = $req.진행상태
        실무대응가이드 = $actionGuide
    }
}

$processedCs | Export-Csv -Path $CsResultFile -NoTypeInformation -Encoding utf8

Write-Host " • [CS 분석 완료] 반품/교환 접수 건에 대한 대응 가이드 리포트가 생성되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $CsResultFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
