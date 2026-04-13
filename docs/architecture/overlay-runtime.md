# Dual App Architecture

## 배경

이 저장소는 더 이상 단일 앱 저장소가 아니라, 기존 `MiyeonSlap` 앱과 별도 다운로드용 `LovaSlap-PET` 앱을 함께 유지합니다.

## 핵심 구조

### MiyeonSlap (레거시)

- `Sources/MiyeonSlap/main.swift`
  - 기존 regular app 실행 경로
  - `--self-check` 자동 검증 경로
- `Sources/MiyeonSlap/AppDelegate.swift`
  - 단일 창 런타임
- `Sources/MiyeonSlap/MainWindowController.swift`
  - 단일 투명 오버레이 창
- `Sources/MiyeonSlap/SceneView.swift`
  - 단일 built-in pet 렌더링 및 slap 상호작용

### LovaSlap-PET (새 앱)

- `Sources/LovaSlapPET/main.swift`
  - 메뉴 바 유틸리티 실행 경로
  - `--self-check` 자동 검증 경로
- `Sources/LovaSlapPET/PetsCoordinator.swift`
  - 상태 아이템 / 메뉴 구성
  - 개별 펫 창 생성 / 제거
  - 물리 slap을 모든 가시 펫에 전달
- `Sources/LovaSlapPET/PetModels.swift`
  - 내장 프리셋 / PNG 시퀀스 자산 모델
  - 새 펫 배치 계산
  - 세션용 PNG 폴더 로더
- `Sources/LovaSlapPET/MainWindowController.swift`
  - 각 펫별 borderless + transparent + floating 오버레이 창 생성
- `Sources/LovaSlapPET/SceneView.swift`
  - 내장 프리셋 / PNG 시퀀스 캐릭터 뷰 배치
  - 주기적 refresh 루프
  - 클릭 slap과 물리 slap을 공통 reaction 파이프라인으로 연결

## 설계 이유

- 기존 MiyeonSlap을 그대로 보존하면서 새 앱을 별도 product로 분리하기 위해
- 새 앱 다운로드가 기존 executable rename이 아니라 독립 executable이 되게 하기 위해
- 메뉴바 데스크톱 펫 기능을 새 앱에만 집중시키기 위해

## 현재 한계

- `LovaSlap-PET`은 true wallpaper embedding 구조는 아님
- `LovaSlap-PET`의 PNG 시퀀스 폴더 선택은 세션 저장만 지원
- 두 앱 간 일부 코드 중복이 존재함
