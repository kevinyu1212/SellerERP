# Deluxe\Scripts\AI-ReviewAnalyzer.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP\Deluxe"
$DatabaseDir = Join-Path $BaseDir "Database"

$ReviewFile = Join-Path $DatabaseDir "customer_reviews.csv"
$ReviewResultFile = Join-Path $DatabaseDir "review_sentiment_report.csv"

# 샘플 고객 리뷰 데이터 생성
"주문번호,상품명,평점,리뷰내용`r`nORD-2026-101,프리미엄 원목 캣타워,5,마감이 정말 깔끔하고 고양이가 너무 좋아해요! 배송도 빨랐습니다.`r`nORD-2026-102,고양이 자동 급식기,2,설정이 너무 복잡하고 소음이 좀 나서 아쉽네요. 설명서가 불친절합니다." | Set-Content -Path $ReviewFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      💬 [Deluxe 2번] AI 리뷰 분석 및 평판 관리 봇 가동    " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$reviews = Import-Csv -Path $ReviewFile -Encoding UTF8
$analyzedReviews = foreach ($rev in $reviews) {
    $score = [int]$rev.평점
    $text = $rev.리뷰내용

    $sentiment = if ($score -ge 4) { "🌟 긍정 (만족)" } elseif ($score -eq 3) { "💡 보통 (개선 여지)" } else { "⚠️ 부정 (불만족/조치 필요)" }
    
    $keywordIssue = if ($text -like "*배송*") { "물류/배송" } 
                    elseif ($text -like "*설정*" -or $text -like "*설명서*" -or $text -like "*소음*") { "상품 기능 및 매뉴얼" } 
                    elseif ($text -like "*마감*" -or $text -like "*품질*") { "상품 품질" } 
                    else { "기타 일반" }

    [PSCustomObject]@{
        주문번호 = $rev.주문번호
        상품명 = $rev.상품명
        평점 = "$score 점"
        감성분류 = $sentiment
        핵심이슈키워드 = $keywordIssue
        대응방향 = if ($score -le 2) { "🚨 CS 전담 부서 확인 및 상세페이지 보완 권장" } else { "👍 우수 리뷰 선정 및 마케팅 활용" }
    }
}

$analyzedReviews | Export-Csv -Path $ReviewResultFile -NoTypeInformation -Encoding utf8

Write-Host " • [리뷰 분석 완료] 고객 리뷰 감성 분석 및 이슈 키워드 리포트가 생성되었습니다!" -ForegroundColor Green
Write-Host " • [출력 파일] $ReviewResultFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
