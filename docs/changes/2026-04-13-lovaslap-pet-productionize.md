# 2026-04-13 - LovaSlap-PET productionize

## 배경

기존 저장소는 프로토타입 성격의 고정 장면 앱과 문서 구성이었고, 배포/설명/검증 측면에서 프로덕션 기준에 미치지 못했습니다.

## 문제 또는 목표

- 데스크톱 위에 바로 띄워지는 형태로 전환
- 내장 프리셋 애니메이션 제공
- slap 시 일시적인 반응 이미지/포즈 후 기본 모션 복귀
- 새 GitHub 저장소 기준으로 문서와 배포 경로 정리

## 변경 내용

- 투명 오버레이 창 기반 데스크톱 펫 구조로 전환
- 프리셋 카탈로그와 프리셋별 idle 프레임 추가
- 클릭 slap 복원 및 물리 slap 공통 파이프라인 유지
- 실행 파일 내장 self-check 추가
- 릴리스용 DMG 패키징 추가
- README / AGENTS / 아키텍처 / 릴리스 문서 추가
- GitHub Actions CI 추가

## 설계 이유

- 외부 에셋/의존성 없이도 유지보수 가능한 데스크톱 펫 구조를 유지하기 위해
- SwiftPM 테스트 프레임워크 사용 불가 환경에서도 자동 검증을 확보하기 위해

## 영향 범위

- 창 동작
- 렌더링 루프
- slap 반응 상태 전이
- 문서 / CI / 배포 메타데이터

## 검증 방법

- `swift build`
- `swift run MiyeonSlap --self-check`
- `zsh scripts/build_app_bundle.sh`
- `zsh scripts/package_release_zip.sh`
- `zsh scripts/package_release_dmg.sh`

## 남아 있는 한계

- 프리셋 선택 UI는 아직 없음
- true wallpaper embedding은 아님
- 물리 slap 감도는 기기마다 조정이 필요할 수 있음

## 후속 과제

- 프리셋 수 확대
- 물리 slap 감도 설정
- 릴리스 자동화 확장
