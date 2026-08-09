$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI(gh)가 필요합니다: https://cli.github.com/"
    exit 1
}

# GitHub CLI 인증 확인
gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "GitHub CLI 인증이 필요합니다. 'gh auth login'을 먼저 실행해주세요."
    exit 1
}

# 현재 디렉터리의 GitHub 저장소 확인
$repo = gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repo)) {
    Write-Error "GitHub 저장소 디렉터리에서 실행해주세요."
    exit 1
}

Write-Host "대상 저장소: $repo"

# GitHub가 새 저장소에 기본으로 생성하는 라벨
$defaultLabels = @(
    "bug",
    "documentation",
    "duplicate",
    "enhancement",
    "good first issue",
    "help wanted",
    "invalid",
    "question",
    "wontfix"
)

# 현재 라벨 목록 조회
$existingLabels = @(gh label list --repo $repo --limit 100 --json name --jq '.[].name')
if ($LASTEXITCODE -ne 0) {
    Write-Error "현재 라벨 목록을 불러오지 못했습니다."
    exit 1
}

# 존재하는 GitHub 기본 라벨만 삭제
foreach ($label in $defaultLabels) {
    if ($existingLabels -contains $label) {
        Write-Host "기본 라벨 삭제: $label"
        gh label delete $label --repo $repo --yes 2>$null

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "라벨 삭제 실패: $label"
        }
    }
}

# 프로젝트 공통 라벨
# gh --color에는 #을 제외한 6자리 HEX 값을 전달한다.
$labels = @(
    @{ Name = "🛠 Refactor"; Color = "292a28"; Description = "기존 코드 및 아키텍처 개선" },
    @{ Name = "⚙️ Chore"; Color = "281d22"; Description = "개발 환경 구축 및 설정 변경 사항 (빌드, 의존성 업데이트 등)" },
    @{ Name = "✨ Feature"; Color = "cbb55d"; Description = "새 기능 혹은 요구 사항" },
    @{ Name = "🧹 Style"; Color = "DB6D28"; Description = "코드 포맷팅, 세미콜론 누락 등 기능과 무관한 스타일 수정" },
    @{ Name = "🐛 Bug"; Color = "3F9E12"; Description = "서버 오류, 코드 오류, 데이터 불일치" },
    @{ Name = "🐳 DevOps"; Color = "35588d"; Description = "배포, CI/CD 및 프로젝트 자동화" },
    @{ Name = "📚 Docs"; Color = "2a1f61"; Description = "프로젝트 문서 수정 및 추가" },
    @{ Name = "🔒 Security"; Color = "4d4047"; Description = "보안 관련 작업" },
    @{ Name = "🧪 Test"; Color = "1b2f28"; Description = "유닛 테스트, 통합 테스트 코드" },
    @{ Name = "👑 MVP"; Color = "D73A4A"; Description = "최소 기능 제품(MVP)에 포함되는 핵심 기능" }
    @{ Name = "🔥 2차 기능"; Color = "F97316"; Description = "MVP 이후 추가로 구현할 확장 기능" }
)

foreach ($label in $labels) {
    Write-Host "라벨 적용: $($label.Name) (#$($label.Color))"

    gh label create $label.Name `
        --repo $repo `
        --color $label.Color `
        --description $label.Description `
        --force

    if ($LASTEXITCODE -ne 0) {
        Write-Error "라벨 생성 또는 수정에 실패했습니다: $($label.Name)"
        exit 1
    }
}

Write-Host ""
Write-Host "Label 설정이 완료되었습니다."