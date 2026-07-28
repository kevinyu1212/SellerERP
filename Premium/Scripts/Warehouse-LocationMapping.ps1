# Premium\Scripts\Warehouse-LocationMapping.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP\Premium"
$DatabaseDir = Join-Path $BaseDir "Database"
if (!(Test-Path $DatabaseDir)) { New-Item -ItemType Directory -Path $DatabaseDir -Force | Out-Null }

$WarehouseFile = Join-Path $DatabaseDir "warehouse_inventory.csv"
$PickingResultFile = Join-Path $DatabaseDir "warehouse_picking_list.csv"

# 샘플 창고 로케이션 및 재고 데이터 생성
"상품명,구역코드,선반번호,재고수량,입고일자`r`n프리미엄 원목 캣타워,A구역,RACK-01,15,2026-06-01`r`n고양이 자동 급식기,B구역,RACK-03,28,2026-06-10" | Set-Content -Path $WarehouseFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      📦 [Premium 1번] 창고 로케이션 및 피킹 동선 매핑   " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$inventory = Import-Csv -Path $WarehouseFile -Encoding UTF8
$pickingList = foreach ($item in $inventory) {
    # 동선 최적화 우선순위 부여 (A구역 우선 출고 등 시뮬레이션)
    $priority = if ($item.구역코드 -eq "A구역") { "🔥 1순위 피킹 (메인 출고 구역)" } else { "⚡ 2순위 피킹 (서브 보관 구역)" }

    [PSCustomObject]@{
        상품명 = $item.상품명
        보관구역 = $item.구역코드
        선반위치 = $item.선반번호
        현재고량 = "$([int]$item.재고수량) 개"
        출고우선순위 = $priority
    }
}

$pickingList | Export-Csv -Path $PickingResultFile -NoTypeInformation -Encoding utf8

Write-Host " • [물류 최적화 완료] 창고 피킹 동선 매핑 리포트가 생성되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $PickingResultFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
