# Deluxe\Scripts\Bulk-ProductRegister.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP\Deluxe"
$DatabaseDir = Join-Path $BaseDir "Database"
if (!(Test-Path $DatabaseDir)) { New-Item -ItemType Directory -Path $DatabaseDir -Force | Out-Null }

$BulkSourceFile = Join-Path $DatabaseDir "bulk_products_raw.csv"
$BulkResultFile = Join-Path $DatabaseDir "bulk_products_registered.csv"

# 샘플 대량 상품 원본 데이터 생성
"상품명,카테고리,판매가,재고수량,검색태그`r`n원목 캣타워 디럭스,반려동물용품,75000,50,고양이,캣타워,원목가구`r`n자동 급식기 스마트,반려동물용품,45000,30,펫가전,급식기,자동" | Set-Content -Path $BulkSourceFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      🚀 [Deluxe 1번] 대량 상품 등록 및 키워드 마스터 가동   " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$rawProducts = Import-Csv -Path $BulkSourceFile -Encoding UTF8
$registeredList = foreach ($item in $rawProducts) {
    # 상품 코드 자동 생성 (SKU-랜덤숫자)
    $sku = "SKU-" + (Get-Random -Minimum 10000 -Maximum 99999)
    $status = if ([int]$item.판매가 -gt 0 -and [int]$item.재고수량 -gt 0) { "✅ 등록 적합 (API 전송 대기)" } else { "❌ 반려 (가격/재고 오류)" }

    [PSCustomObject]@{
        상품코드SKU = $sku
        상품명 = $item.상품명
        카테고리 = $item.카테고리
        판매가 = "$([int]$item.판매가) 원"
        재고 = "$([int]$item.재고수량) 개"
        검색태그 = $item.검색태그
        검증상태 = $status
    }
}

$registeredList | Export-Csv -Path $BulkResultFile -NoTypeInformation -Encoding utf8

Write-Host " • [대량 등록 완료] 오픈마켓 API 연동 규격에 맞춘 상품 일괄 등록 데이터가 생성되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $BulkResultFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
