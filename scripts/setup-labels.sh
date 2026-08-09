#!/usr/bin/env bash
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI(gh)가 필요합니다: https://cli.github.com/"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI 인증이 필요합니다. 'gh auth login'을 먼저 실행해주세요."
  exit 1
fi

if ! gh repo view >/dev/null 2>&1; then
  echo "GitHub 저장소 디렉터리에서 실행해주세요."
  exit 1
fi

default_labels=(
  "bug"
  "documentation"
  "duplicate"
  "enhancement"
  "good first issue"
  "help wanted"
  "invalid"
  "question"
  "wontfix"
)

for label in "${default_labels[@]}"; do
  gh label delete "$label" --yes >/dev/null 2>&1 || true
done

create_label() {
  local name="$1"
  local color="$2"
  local description="$3"

  gh label create "$name" \
    --color "$color" \
    --description "$description" \
    --force
}

create_label "🛠 Refactor" "292a28" "기존 코드 및 아키텍처 개선"
create_label "⚙️ Chore" "281d22" "개발 환경 구축 및 설정 변경 사항 (빌드, 의존성 업데이트 등)"
create_label "✨ Feature" "cbb55d" "새 기능 혹은 요구 사항"
create_label "🧹 Style" "DB6D28" "코드 포맷팅, 세미콜론 누락 등 기능과 무관한 스타일 수정"
create_label "🐛 Bug" "3F9E12" "서버 오류, 코드 오류, 데이터 불일치"
create_label "🐳 DevOps" "35588d" "배포, CI/CD 및 프로젝트 자동화"
create_label "📚 Docs" "2a1f61" "프로젝트 문서 수정 및 추가"
create_label "🔒 Security" "4d4047" "보안 관련 작업"
create_label "🧪 Test" "1b2f28" "유닛 테스트, 통합 테스트 코드"
create_label "👑 MVP" "D73A4A" "최소 기능 제품(MVP)에 포함되는 핵심 기능"
create_label "🔥 2차 기능" "F97316" "MVP 이후 추가로 구현할 확장 기능"

echo "Label 설정이 완료되었습니다."
