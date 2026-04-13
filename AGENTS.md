# AGENTS.md

## 프로젝트 목적

LovaSlap-PET은 macOS에서 동작하는 도트 스타일 데스크톱 펫 저장소입니다. 핵심은 투명 오버레이 창, 내장 프리셋 애니메이션, slap 반응 파이프라인입니다.

## 빠른 시작 명령

```bash
swift build
swift run
swift run MiyeonSlap --self-check
zsh scripts/build_app_bundle.sh
zsh scripts/package_release_zip.sh
zsh scripts/package_release_dmg.sh
```

## 설치 / 실행 / 테스트 명령

- 빌드: `swift build`
- 개발 실행: `swift run`
- 자동 회귀 점검: `swift run MiyeonSlap --self-check`
- 앱 번들 생성: `zsh scripts/build_app_bundle.sh`
- 릴리스 ZIP 생성: `zsh scripts/package_release_zip.sh`
- 릴리스 DMG 생성: `zsh scripts/package_release_dmg.sh`

## 기본 작업 순서

1. `README.md`, `AGENTS.md`, `docs/` 확인
2. `swift build` 및 `swift run MiyeonSlap --self-check`로 현재 상태 확인
3. 최소 변경으로 기능 구현
4. 문서 갱신
5. 번들/패키징 포함 전체 검증
6. 기능 브랜치에서 PR 준비

## 완료 조건

- 요청 기능이 실제 코드에 반영됨
- `swift build` 통과
- `swift run MiyeonSlap --self-check` 통과
- 필요 시 번들/패키징 스크립트까지 통과
- README / docs / AGENTS가 실제 동작과 일치함

## 코드 스타일 원칙

- AppKit 기반 프로그램 구조 유지
- 렌더링 중심 파일은 `SceneView.swift`
- 상태 계산은 `GameState.swift`에 유지
- slap 입력은 클릭이든 물리 충격이든 공통 파이프라인으로 연결
- 외부 의존성 추가는 마지막 수단

## 파일 구조 원칙

- `Sources/MiyeonSlap/main.swift` - 진입점 + self-check
- `Sources/MiyeonSlap/MainWindowController.swift` - 창/위치/오버레이 동작
- `Sources/MiyeonSlap/SceneView.swift` - 뷰 계층, 애니메이션 루프, 상호작용
- `Sources/MiyeonSlap/GameState.swift` - 상태 전이
- `Sources/MiyeonSlap/PixelPetPreset.swift` - 내장 프리셋
- `Sources/MiyeonSlap/PhysicalSlapDetector.swift` - 하드웨어 감지

## 문서화 원칙

- 의미 있는 변경이 있으면 `README.md` 또는 `docs/changes/`를 반드시 갱신
- 구조적 변화가 있으면 `docs/architecture/`도 갱신
- 릴리스/운영 절차가 바뀌면 `docs/runbooks/` 갱신

## 테스트 원칙

- 기본 자동 검증은 `swift run MiyeonSlap --self-check`
- 상태 로직, 프리셋 카탈로그, 대사 흐름처럼 UI 없이 검증 가능한 것은 self-check에 추가
- 수동 UI 검증은 실제 실행 후 화면 확인으로 보완

## 브랜치 / 커밋 / PR 규칙

- 기본 브랜치에서 직접 작업하지 않음
- 브랜치명 예시: `feat/lovaslap-pet-productionize`
- 커밋은 목적별로 분리
- PR에는 배경, 변경 요약, 테스트 결과, 수동 검증 결과, 남은 리스크 포함

## 민감한 경로 / 수정 주의 경로

- `Sources/MiyeonSlap/PhysicalSlapDetector.swift` - 비공개 센서 접근, 임계값 튜닝 주의
- `scripts/build_app_bundle.sh` - 앱 번들명 / bundle id / 아이콘 경로 일관성 주의
- `Casks/lovaslap.rb` - 릴리스 URL 및 artifact 이름과 반드시 일치해야 함

## 작업 전 체크리스트

- 현재 브랜치 확인
- `git status` 확인
- README / AGENTS / docs 확인
- 기존 slap 파이프라인과 창 동작 확인

## 작업 후 체크리스트

- `swift build`
- `swift run MiyeonSlap --self-check`
- 필요 시 `zsh scripts/build_app_bundle.sh`
- 필요 시 `zsh scripts/package_release_zip.sh`
- 필요 시 `zsh scripts/package_release_dmg.sh`
- 문서 갱신 여부 확인

## 절대 하면 안 되는 것

- 타입 에러 무시
- 테스트/검증 없이 완료 선언
- 물리 slap 경로를 임의로 삭제
- 문서와 실제 명령 불일치 상태로 방치
- 사용자가 요청하지 않은 대규모 구조 개편
