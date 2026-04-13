# AGENTS.md

## 프로젝트 목적

이 저장소는 두 개의 macOS 앱을 함께 유지합니다.

- `MiyeonSlap`: 기존 slap 중심 단일 오버레이 앱
- `LovaSlap-PET`: 별도 다운로드용 메뉴바 데스크톱 펫 앱

## 빠른 시작 명령

```bash
swift build --product MiyeonSlap
swift build --product LovaSlapPET
swift run MiyeonSlap
swift run LovaSlapPET
swift run MiyeonSlap --self-check
swift run LovaSlapPET --self-check
zsh scripts/build_app_bundle.sh
zsh scripts/build_lovaslap_pet_app_bundle.sh
```

## 설치 / 실행 / 테스트 명령

- 레거시 앱 실행: `swift run MiyeonSlap`
- 새 앱 실행: `swift run LovaSlapPET`
- 레거시 self-check: `swift run MiyeonSlap --self-check`
- 새 앱 self-check: `swift run LovaSlapPET --self-check`
- MiyeonSlap 번들 생성: `zsh scripts/build_app_bundle.sh`
- LovaSlap-PET 번들 생성: `zsh scripts/build_lovaslap_pet_app_bundle.sh`
- MiyeonSlap ZIP/DMG: `zsh scripts/package_miyeonslap_zip.sh`, `zsh scripts/package_miyeonslap_dmg.sh`
- LovaSlap-PET ZIP/DMG: `zsh scripts/package_lovaslap_pet_zip.sh`, `zsh scripts/package_lovaslap_pet_dmg.sh`

## 기본 작업 순서

1. `README.md`, `AGENTS.md`, `docs/` 확인
2. 어떤 앱을 수정하는지 먼저 명확히 결정
3. 대상 product의 self-check와 build로 현재 상태 확인
4. 최소 변경으로 기능 구현
5. 문서 갱신
6. 대상 앱의 번들/패키징 포함 전체 검증
7. 기능 브랜치에서 PR 준비

## 완료 조건

- 요청 기능이 정확한 앱 product에 반영됨
- `swift build --product MiyeonSlap` / `swift build --product LovaSlapPET` 중 영향받는 product가 통과
- 영향받는 product의 self-check 통과
- 필요 시 대상 앱의 번들/패키징 스크립트까지 통과
- README / docs / AGENTS가 실제 동작과 일치함

## 코드 스타일 원칙

- AppKit 기반 구조 유지
- `MiyeonSlap`와 `LovaSlap-PET`의 product identity를 섞지 않음
- slap 입력은 해당 앱 내부에서만 일관되게 연결
- 외부 의존성 추가는 마지막 수단

## 파일 구조 원칙

- `Sources/MiyeonSlap/` - 기존 MiyeonSlap 앱
- `Sources/LovaSlapPET/` - 새 LovaSlap-PET 앱
- `scripts/build_app_bundle.sh` - MiyeonSlap 번들 생성
- `scripts/build_lovaslap_pet_app_bundle.sh` - LovaSlap-PET 번들 생성

## 문서화 원칙

- 의미 있는 변경이 있으면 `README.md` 또는 `docs/changes/`를 반드시 갱신
- 구조적 변화가 있으면 `docs/architecture/`도 갱신
- 릴리스/운영 절차가 바뀌면 `docs/runbooks/` 갱신

## 테스트 원칙

- 기본 자동 검증은 각 product의 `--self-check`
- UI 없이 검증 가능한 로직은 self-check에 추가
- 수동 UI 검증은 실제 실행 후 화면 확인으로 보완

## 브랜치 / 커밋 / PR 규칙

- 기본 브랜치에서 직접 작업하지 않음
- 브랜치명 예시: `feat/lovaslap-pet-productionize`
- 커밋은 목적별로 분리
- PR에는 어느 앱을 바꿨는지, 테스트 결과, 수동 검증 결과, 남은 리스크 포함

## 민감한 경로 / 수정 주의 경로

- `Sources/MiyeonSlap/PhysicalSlapDetector.swift` - legacy 앱 센서 접근
- `Sources/LovaSlapPET/PhysicalSlapDetector.swift` - 새 앱 센서 접근
- `scripts/` - 두 앱 artifact 이름이 섞이지 않게 주의
- `Casks/lovaslap.rb` - 새 앱 릴리스 URL 및 artifact 이름과 반드시 일치해야 함

## 작업 전 체크리스트

- 현재 브랜치 확인
- `git status` 확인
- README / AGENTS / docs 확인
- 수정 대상이 `MiyeonSlap`인지 `LovaSlap-PET`인지 확인

## 작업 후 체크리스트

- `swift build --product <대상앱>`
- `swift run <대상앱> --self-check`
- 필요 시 대상 앱 번들/패키징 스크립트 확인
- 문서 갱신 여부 확인

## 절대 하면 안 되는 것

- 타입 에러 무시
- 테스트/검증 없이 완료 선언
- 기존 `MiyeonSlap`를 새 앱으로 덮어쓰기
- 문서와 실제 명령 불일치 상태로 방치
- 사용자가 요청하지 않은 대규모 구조 개편
