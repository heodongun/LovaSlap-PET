# Overlay Runtime Architecture

## 배경

이 프로젝트는 고정된 VN 스타일 장면에서, macOS 바탕화면 위에 머무는 데스크톱 펫 오버레이 구조로 전환되었습니다.

## 핵심 구조

- `main.swift`
  - 일반 앱 실행 경로
  - `--self-check` 자동 검증 경로
- `MainWindowController.swift`
  - borderless + transparent + floating 오버레이 창 생성
  - 화면 오른쪽 아래 위치 결정
- `SceneView.swift`
  - 캐릭터 뷰 배치
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

- 외부 GIF/비디오 파이프라인을 넣지 않고도, 코드 기반 픽셀 렌더링으로 유지보수성을 확보하기 위해
- slap 반응을 입력 장치 종류와 무관한 하나의 상태 전이로 유지하기 위해
- 사용자가 에셋을 고르지 않아도 되도록 내장 프리셋 구조를 만들기 위해

## 현재 한계

- 진짜 wallpaper embedding 구조는 아님
- 프리셋 선택 UI 없음
- 물리 slap 경로는 macOS / 기기 특성에 따라 민감도 차이가 있음
