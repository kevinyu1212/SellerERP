# Scripts\Data-Crypto.ps1
$BaseDir = "C:\Users\유2023610042\Desktop\SellerERP"
$DatabaseDir = Join-Path $BaseDir "Database"
if (!(Test-Path $DatabaseDir)) { New-Item -ItemType Directory -Path $DatabaseDir -Force | Out-Null }

$TargetFile = Join-Path $DatabaseDir "sales_data.csv"
$EncryptedFile = Join-Path $DatabaseDir "sales_data.enc"

# 샘플 영업 장부 데이터 생성
"주문번호,상품명,수량,매출액`r`nORD-2026-001,프리미엄 원목 캣타워,2,120000" | Set-Content -Path $TargetFile -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      🔒 [보안] 로컬 데이터 AES 암호화 엔진 가동     " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 간단한 보안 키 기반 바이트 변환 암호화 로직
$SecretKey = [System.Text.Encoding]::UTF8.GetBytes("SellerERP-2026-Secure-Key!!") # 정확히 32바이트 맞춤용 해시 처리 가능
$Sha = [System.Security.Cryptography.SHA256]::Create()
$KeyBytes = $Sha.ComputeHash($SecretKey)

function Protect-LocalData {
    param([string]$Path, [string]$OutPath)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    # 간단하고 강력한 AES 스트림 암호화 적용
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $KeyBytes
    $aes.GenerateIV()
    $iv = $aes.IV
    
    $encryptor = $aes.CreateEncryptor()
    $encryptedBytes = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length)
    
    # IV + 암호화된 바이트 결합 저장
    $finalBytes = $iv + $encryptedBytes
    [System.IO.File]::WriteAllBytes($OutPath, $finalBytes)
    Write-Host " • [암호화 완료] 영업 장부 파일이 안전하게 암호화되었습니다: sales_data.enc" -ForegroundColor Green
}

Protect-LocalData -Path $TargetFile -OutPath $EncryptedFile

# 원본 평문 파일은 보안을 위해 삭제 (실무 환경 반영)
Remove-Item $TargetFile -Force
Write-Host " • [보안 강화] 타인이 볼 수 없도록 원본 평문 장부를 파기했습니다." -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
