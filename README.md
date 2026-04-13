# LovaSlap-PET

LovaSlap-PET은 macOS 메뉴 바에서 동작하면서 바탕화면 위에 여러 마리 펫을 띄워둘 수 있는 AppKit 기반 데스크톱 펫 프로젝트입니다. 현재는 **LSUIElement 스타일 메뉴 바 유틸리티**, **내장 프리셋 애니메이션**, **사용자 선택 PNG 시퀀스 폴더 펫**, **클릭/물리 충격 slap 공통 반응 파이프라인**을 갖춘 형태로 정리했습니다.

## 프로젝트 개요

- 목적: macOS에서 바로 실행 가능한 도트 스타일 데스크톱 펫 제공
- 문제: 사용자가 직접 GIF나 에셋을 고르지 않아도 바로 볼 수 있는 기본 프리셋과 상호작용이 필요했음
- 핵심 특징:
  - 상태 아이템 기반 메뉴 바 실행
  - 여러 개의 투명 데스크톱 펫 창 동시 표시
  - 내장 프리셋 기반 반복 idle 애니메이션
  - PNG 시퀀스 폴더를 골라 커스텀 펫 추가 가능
  - 클릭 반응과 실제 노트북 충격 반응의 공통 slap 파이프라인
  - hit 직후 포즈/오프셋 변경 후 자동 복귀

## 기술 스택

- Swift 6
- Swift Package Manager
- AppKit
- IOKit HID (`AppleSPUHIDDevice`) 기반 물리 충격 감지
- zsh 기반 번들/릴리스 스크립트

## 요구 환경

- macOS 13 이상
- Xcode Command Line Tools 또는 Swift toolchain
- 실제 노트북 충격 감지는 Apple Silicon MacBook 권장

## 가장 쉬운 설치 방법

### 1) 릴리스 DMG로 설치

최신 릴리스에서 `LovaSlap-PET.dmg`를 내려받아 열고 `LovaSlap-PET.app`을 `Applications`로 드래그하세요.

- 릴리스 페이지: https://github.com/heodongun/LovaSlap-PET/releases

### 2) 릴리스 ZIP으로 설치

최신 릴리스에서 `LovaSlap-PET.zip`을 내려받아 압축을 풀고 실행하세요.

- 릴리스 페이지: https://github.com/heodongun/LovaSlap-PET/releases

```bash
unzip LovaSlap-PET.zip
open LovaSlap-PET.app
```

### 3) Homebrew로 설치

```bash
brew tap heodongun/LovaSlap-PET https://github.com/heodongun/LovaSlap-PET
brew install --cask heodongun/lovaslap-pet/lovaslap
```

## 실행 방법

### 소스에서 바로 실행

```bash
swift run
```

실행하면 Dock 대신 메뉴 바에 상태 아이템이 나타나고, 기본 펫 한 마리가 바탕화면 위에 표시됩니다.
상태 아이템 메뉴에서 내장 프리셋 펫을 더 추가하거나 PNG 시퀀스 폴더를 선택해 커스텀 펫을 띄울 수 있습니다.

### 앱 번들 생성

```bash
zsh scripts/build_app_bundle.sh
```

생성 결과:

- `LovaSlap-PET.app`

### 릴리스 ZIP 생성

```bash
zsh scripts/package_release_zip.sh
```

생성 결과:

- `LovaSlap-PET.app`
- `dist/LovaSlap-PET.zip`

### 릴리스 DMG 생성

```bash
zsh scripts/package_release_dmg.sh
```

생성 결과:

- `dist/LovaSlap-PET.dmg`

## 테스트 / 검증 방법

이 저장소는 현재 SwiftPM 테스트 프레임워크 모듈(`XCTest`, `Testing`)을 이 환경에서 사용할 수 없어, 대신 실행 파일에 내장된 자동 self-check를 제공합니다.

```bash
swift run MiyeonSlap --self-check
```

추가 검증 명령:

```bash
swift build
zsh scripts/build_app_bundle.sh
zsh scripts/package_release_zip.sh
zsh scripts/package_release_dmg.sh
```

## 환경변수

현재 필수 환경변수는 없습니다.

## 주요 스크립트

- `swift run` - 개발용 앱 실행
- `swift run MiyeonSlap --self-check` - 핵심 상태/프리셋/대사 회귀 점검
- `swift build` - 패키지 빌드
- `zsh scripts/build_app_bundle.sh` - Finder에서 열 수 있는 앱 번들 생성
- `zsh scripts/package_release_zip.sh` - 배포용 ZIP 생성
- `zsh scripts/package_release_dmg.sh` - 배포용 DMG 생성
- `swift scripts/generate_app_icon.swift` - 아이콘 에셋 생성

## 핵심 사용자 흐름

1. 앱 실행
2. 메뉴 바 상태 아이템에서 펫 추가/정리
3. 화면 위에 여러 펫 동시 표시
4. 펫을 클릭하거나 노트북에 충격을 주면 slap 반응 발생
5. 잠깐 포즈가 바뀌고 impact 효과가 나온 뒤 idle 애니메이션으로 복귀

## 폴더 구조

- `Sources/MiyeonSlap/` - 앱 소스 전체
- `Assets/AppIcon/` - 앱 아이콘 에셋
- `Casks/lovaslap.rb` - Homebrew cask
- `scripts/` - 번들/패키징/아이콘 생성 스크립트
- `docs/architecture/` - 아키텍처 설명
- `docs/changes/` - 변경 기록
- `docs/runbooks/` - 운영/릴리스 절차

## 아키텍처 개요

- `main.swift` - 앱 시작점과 self-check 실행 경로
- `MainWindowController.swift` - 개별 펫용 투명 오버레이 창 구성
- `SceneView.swift` - 내장 프리셋/PNG 시퀀스 렌더링, 애니메이션 루프, 클릭 slap 연결
- `PetModels.swift` - 펫 자산, 배치, 스토어, PNG 시퀀스 로딩
- `PetsCoordinator.swift` - 상태 아이템 메뉴와 멀티 펫 런타임 조정
- `GameState.swift` - idle / hit 상태 계산과 반응 시점 관리
- `PixelPetPreset.swift` - 내장 프리셋 팔레트와 idle 프레임 정의
- `PhysicalSlapDetector.swift` - 실제 장치 충격 감지

자세한 내용은 `docs/architecture/overlay-runtime.md`를 참고하세요.

## 개발 원칙

- 기능보다 검증 가능성을 우선
- UI/렌더링은 코드 중심으로 단순 유지
- 모든 slap 입력은 공통 파이프라인으로 수렴
- 외부 에셋 의존 대신 내장 프리셋 우선

## CI 개요

GitHub Actions에서 macOS 환경 기준으로 아래를 실행합니다.

- `swift build`
- `swift run MiyeonSlap --self-check`
- `zsh scripts/build_app_bundle.sh`

## 기여 방법

1. 기능 브랜치 생성 (`feat/...`, `fix/...`, `docs/...` 등)
2. 로컬에서 `swift build`와 `swift run MiyeonSlap --self-check` 실행
3. 필요 시 번들/패키징 스크립트 확인
4. 문서까지 함께 갱신 후 PR 생성

## 알려진 제한 사항

- 물리 충격 감지는 Apple의 비공개/비안정 API 성격을 띱니다.
- macOS 버전에 따라 실제 센서 반응성이 달라질 수 있습니다.
- 진짜 wallpaper embedding 구조는 아닙니다. 현재는 **여러 개의 투명 오버레이 창**입니다.
- PNG 시퀀스 폴더 선택은 현재 세션 동안만 유지되며 별도 영구 저장은 없습니다.

## Gatekeeper / 실행 문제 해결

다운로드한 앱이 macOS에서 차단되면 다음을 실행하세요.

```bash
xattr -dr com.apple.quarantine LovaSlap-PET.app
open LovaSlap-PET.app
```

## 향후 계획

- 프리셋 확장
- 반응 모션 다양화
- 장치별 물리 충격 임계값 튜닝
- 릴리스 자동화 보강
