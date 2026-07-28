# Scripts\Invoice-Mapper.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP"
$DatabaseDir = Join-Path $BaseDir "Database"
if (!(Test-Path $DatabaseDir)) { New-Item -ItemType Directory -Path $DatabaseDir -Force | Out-Null }

$OrderFile = Join-Path $DatabaseDir "integrated_orders.csv"
$InvoiceFile = Join-Path $DatabaseDir "courier_invoice.csv"
$ResultFile = Join-Path $DatabaseDir "final_shipping_sheet.csv"

# 샘플 통합 주문서 생성
"주문번호,수취인,상품명,수량`r`nORD-2026-001,홍길동,프리미엄 원목 캣타워,2`r`nORD-2026-002,김철수,고양이 자동 급식기,1" | Set-Content -Path $OrderFile -Encoding utf8

# 샘플 택배사 송장 데이터 생성
"주문번호,택배사,송장번호`r`nORD-2026-001,CJ대한통운,628123456789`r`nORD-2026-002,우체국택배,601987654321" | Set-Content -Path $InvoiceFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      📦 [2단계] 택배 송장 자동 매핑 엔진 가동      " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# CSV 데이터 읽기 및 병합 로직
$orders = Import-Csv -Path $OrderFile -Encoding UTF8
$invoices = Import-Csv -Path $InvoiceFile -Encoding UTF8

$mappedData = foreach ($order in $orders) {
    $matchedInvoice = $invoices | Where-Object { $_.주문번호 -eq $order.주문번호 }
    [PSCustomObject]@{
        주문번호 = $order.주문번호
        수취인 = $order.수취인
        상품명 = $order.상품명
        수량 = $order.수량
        택배사 = if ($matchedInvoice) { $matchedInvoice.택배사 } else { "미배정" }
        송장번호 = if ($matchedInvoice) { $matchedInvoice.송장번호 } else { "대기중" }
    }
}

$mappedData | Export-Csv -Path $ResultFile -NoTypeInformation -Encoding utf8

Write-Host " • [매핑 성공] 주문서와 택배 송장번호가 완벽하게 동기화되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $ResultFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
