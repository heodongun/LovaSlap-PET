# Desktop Pet Runtime Architecture

## 배경

이 프로젝트는 단일 오버레이 펫에서, 메뉴 바 상태 아이템을 중심으로 여러 펫을 동시에 관리하는 데스크톱 펫 구조로 전환되었습니다.

## 핵심 구조

- `main.swift`
  - 메뉴 바 유틸리티 실행 경로
  - `--self-check` 자동 검증 경로
- `PetsCoordinator.swift`
  - 상태 아이템 / 메뉴 구성
  - 개별 펫 창 생성 / 제거
  - 물리 slap을 모든 가시 펫에 전달
- `PetModels.swift`
  - 내장 프리셋 / PNG 시퀀스 자산 모델
  - 새 펫 배치 계산
  - 세션용 PNG 폴더 로더
- `MainWindowController.swift`
  - 각 펫별 borderless + transparent + floating 오버레이 창 생성
- `SceneView.swift`
  - 내장 프리셋 / PNG 시퀀스 캐릭터 뷰 배치
  - 주기적 refresh 루프
  - 클릭 slap과 물리 slap을 공통 reaction 파이프라인으로 연결
- `GameState.swift`
  - `idle` / `hit` 상태 관리
  - hit 종료 시점 계산
  - 현재 시간 기준으로 표시할 pose 산출
- `PixelPetPreset.swift`
  - 내장 프리셋 팔레트
  - 프리셋별 idle animation frame 정의

## 설계 이유

- 기존 slap 상태 전이를 유지한 채 단일 창만 멀티 펫 코디네이터로 확장하기 위해
- 내장 프리셋과 사용자 PNG 시퀀스를 같은 런타임에서 다룰 수 있게 하기 위해
- Dock 중심 앱 대신 상태 아이템 중심 유틸리티로 전환하기 위해

## 현재 한계

- 진짜 wallpaper embedding 구조는 아님
- PNG 시퀀스 폴더 선택은 세션 저장만 지원
- 물리 slap 경로는 macOS / 기기 특성에 따라 민감도 차이가 있음
