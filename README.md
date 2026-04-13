# LovaSlap-PET

LovaSlap-PET은 macOS 바탕화면 위에 작은 도트 캐릭터를 띄워두고, 클릭하거나 실제 노트북 충격을 감지했을 때 반응하는 AppKit 기반 데스크톱 펫 프로젝트입니다. 프로토타입용 고정 장면 앱에서 벗어나, **투명 오버레이 창**, **내장 프리셋 애니메이션**, **때렸을 때 잠깐 표정/포즈가 바뀌었다가 다시 기본 모션으로 돌아오는 상호작용**을 갖춘 형태로 정리했습니다.

## 프로젝트 개요

- 목적: macOS에서 바로 실행 가능한 도트 스타일 데스크톱 펫 제공
- 문제: 사용자가 직접 GIF나 에셋을 고르지 않아도 바로 볼 수 있는 기본 프리셋과 상호작용이 필요했음
- 핵심 특징:
  - 투명한 데스크톱 오버레이 펫 창
  - 내장 프리셋 기반의 반복 idle 애니메이션
  - 클릭 반응과 실제 노트북 충격 반응의 공통 slap 파이프라인
  - hit 직후 표정/포즈 변경 후 자동 복귀

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

최신 릴리스에서 `MiyeonSlap.dmg`를 내려받아 열고 `MiyeonSlap.app`을 `Applications`로 드래그하세요.

- 릴리스 페이지: https://github.com/heodongun/LovaSlap-PET/releases

### 2) 릴리스 ZIP으로 설치

최신 릴리스에서 `MiyeonSlap.zip`을 내려받아 압축을 풀고 실행하세요.

- 릴리스 페이지: https://github.com/heodongun/LovaSlap-PET/releases

```bash
unzip MiyeonSlap.zip
open MiyeonSlap.app
```

### 3) Homebrew로 설치

```bash
brew install --cask https://raw.githubusercontent.com/heodongun/LovaSlap-PET/main/Casks/lovaslap.rb
```

## 실행 방법

### 소스에서 바로 실행

```bash
swift run
```

실행하면 화면 오른쪽 아래 근처에 작은 투명 오버레이 펫이 나타납니다.

### 앱 번들 생성

```bash
zsh scripts/build_app_bundle.sh
```

생성 결과:

- `MiyeonSlap.app`

### 릴리스 ZIP 생성

```bash
zsh scripts/package_release_zip.sh
```

생성 결과:

- `MiyeonSlap.app`
- `dist/MiyeonSlap.zip`

### 릴리스 DMG 생성

```bash
zsh scripts/package_release_dmg.sh
```

생성 결과:

- `dist/MiyeonSlap.dmg`

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
2. 화면 오른쪽 아래에 펫 표시
3. 펫을 클릭하거나 노트북에 충격을 주면 slap 반응 발생
4. 잠깐 표정/포즈가 바뀌고 impact 효과가 나온 뒤 idle 애니메이션으로 복귀

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
- `MainWindowController.swift` - 투명 오버레이 창 구성 및 위치 결정
- `SceneView.swift` - 실제 펫 뷰 구성, 애니메이션 루프, 클릭 slap 연결
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
- 진짜 wallpaper 엔진처럼 바탕화면 아이콘 뒤에 붙는 구조는 아닙니다. 현재는 **투명 오버레이 창**입니다.
- 프리셋은 내장형이며, 아직 사용자 설정 UI는 없습니다.

## Gatekeeper / 실행 문제 해결

다운로드한 앱이 macOS에서 차단되면 다음을 실행하세요.

```bash
xattr -dr com.apple.quarantine MiyeonSlap.app
open MiyeonSlap.app
```

## 향후 계획

- 프리셋 확장
- 반응 모션 다양화
- 장치별 물리 충격 임계값 튜닝
- 릴리스 자동화 보강
