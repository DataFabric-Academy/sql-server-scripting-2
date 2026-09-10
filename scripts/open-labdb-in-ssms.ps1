<#
.SYNOPSIS
  เปิด SqlPgSp.LabDb.sqlproj ด้วย SSMS 22 (ไม่ใช่ Visual Studio)
#>
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $repoRoot 'src\SqlPgSp.LabDb\SqlPgSp.LabDb.sqlproj'))) {
    $repoRoot = $PSScriptRoot
}

$sqlproj = Join-Path $repoRoot 'src\SqlPgSp.LabDb\SqlPgSp.LabDb.sqlproj'
if (-not (Test-Path $sqlproj)) {
    throw "ไม่พบไฟล์: $sqlproj"
}

$ssmsCandidates = @(
    "${env:ProgramFiles}\Microsoft SQL Server Management Studio 22\Common7\IDE\Ssms.exe",
    "${env:ProgramFiles(x86)}\Microsoft SQL Server Management Studio 22\Common7\IDE\Ssms.exe"
)

$ssms = $ssmsCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $ssms) {
    Write-Host @"
ไม่พบ SSMS 22

1) ติดตั้ง SSMS 22 แล้ว Modify → ติ๊ก workload Database DevOps
2) หรือเปิด SSMS เอง แล้วใช้เมนู:
   File → Open → Project/Solution → เลือก
   $sqlproj

อย่าดับเบิลคลิก SqlPgSp.sln (Windows จะเปิด Visual Studio ซึ่งไม่รองรับโปรเจกต์นี้)
"@
    exit 1
}

Write-Host "Opening with SSMS:`n  $ssms`n  $sqlproj"
Start-Process -FilePath $ssms -ArgumentList "`"$sqlproj`""
