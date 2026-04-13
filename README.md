# LovaSlap-PET Repository

이 저장소는 이제 **두 개의 macOS 앱**을 함께 관리합니다.

- **MiyeonSlap**: 기존 slap 중심 오버레이 앱을 그대로 보존한 레거시 앱
- **LovaSlap-PET**: 별도로 다운로드해서 쓰는 새로운 메뉴바 데스크톱 펫 앱

중요: 기존 `MiyeonSlap`을 덮어쓰는 방식이 아니라, **새 앱은 `LovaSlap-PET.app`으로 별도 다운로드/설치**되도록 구조를 분리했습니다.

## 어떤 앱을 내려받아야 하나요?

새로 쓰려는 앱은 **LovaSlap-PET** 입니다.

- 새 앱 다운로드: `LovaSlap-PET.dmg` 또는 `LovaSlap-PET.zip`
- 기존 앱 유지: `MiyeonSlap` 코드는 그대로 남아 있으며, 로컬에서 따로 빌드할 수 있습니다.

## 앱 구분

### 1) LovaSlap-PET — 새 앱

macOS 메뉴바에서 동작하면서 바탕화면 위에 여러 마리 펫을 띄워둘 수 있는 AppKit 기반 데스크톱 펫 앱입니다.

핵심 특징:

- 상태 아이템 기반 메뉴바 실행
- 여러 개의 투명 데스크톱 펫 창 동시 표시
- 내장 프리셋 기반 반복 idle 애니메이션
- PNG 시퀀스 폴더를 골라 커스텀 펫 추가 가능
- 클릭 반응과 실제 노트북 충격 반응의 공통 slap 파이프라인

### 2) MiyeonSlap — 기존 앱

기존 single-pet slap 오버레이 앱입니다. 기존 동작을 깨지 않기 위해 별도 product로 유지합니다.

핵심 특징:

- 단일 오버레이 펫 창
- 내장 프리셋 기반 idle animation
- 클릭 / 물리 slap 반응

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

## 새 앱 설치 방법 (LovaSlap-PET)

### 1) 릴리스 DMG로 설치

최신 릴리스에서 `LovaSlap-PET.dmg`를 내려받아 열고 `LovaSlap-PET.app`을 `Applications`로 드래그하세요.

- 릴리스 페이지: https://github.com/heodongun/LovaSlap-PET/releases

### 2) 릴리스 ZIP으로 설치

최신 릴리스에서 `LovaSlap-PET.zip`을 내려받아 압축을 풀고 실행하세요.

```bash
unzip LovaSlap-PET.zip
open LovaSlap-PET.app
```

### 3) Homebrew로 설치

```bash
brew tap heodongun/LovaSlap-PET https://github.com/heodongun/LovaSlap-PET
brew install --cask heodongun/lovaslap-pet/lovaslap
```

## 로컬 개발/빌드 명령

### LovaSlap-PET (새 앱)

```bash
swift run LovaSlapPET
swift run LovaSlapPET --self-check
zsh scripts/build_lovaslap_pet_app_bundle.sh
zsh scripts/package_lovaslap_pet_zip.sh
zsh scripts/package_lovaslap_pet_dmg.sh
```

생성 결과:

- `LovaSlap-PET.app`
- `dist/LovaSlap-PET.zip`
- `dist/LovaSlap-PET.dmg`

### MiyeonSlap (기존 앱)

```bash
swift run MiyeonSlap
swift run MiyeonSlap --self-check
zsh scripts/build_app_bundle.sh
zsh scripts/package_miyeonslap_zip.sh
zsh scripts/package_miyeonslap_dmg.sh
```

생성 결과:

- `MiyeonSlap.app`
- `dist/MiyeonSlap.zip`
- `dist/MiyeonSlap.dmg`

## 테스트 / 검증 방법

기본 자동 검증은 각 product의 `--self-check` 입니다.

```bash
swift run MiyeonSlap --self-check
swift run LovaSlapPET --self-check
```

추가 검증 명령:

```bash
swift build --product MiyeonSlap
swift build --product LovaSlapPET
zsh scripts/build_app_bundle.sh
zsh scripts/build_lovaslap_pet_app_bundle.sh
```

## 폴더 구조

- `Sources/MiyeonSlap/` - 기존 MiyeonSlap 앱 소스
- `Sources/LovaSlapPET/` - 새 LovaSlap-PET 앱 소스
- `Assets/AppIcon/` - 앱 아이콘 에셋
- `Casks/lovaslap.rb` - 새 앱 Homebrew cask
- `scripts/` - 두 앱의 번들/패키징/아이콘 생성 스크립트
- `docs/architecture/` - 아키텍처 설명
- `docs/changes/` - 변경 기록
- `docs/runbooks/` - 운영/릴리스 절차

## 아키텍처 개요

### MiyeonSlap

- `Sources/MiyeonSlap/main.swift` - 기존 앱 시작점 + self-check
- `Sources/MiyeonSlap/AppDelegate.swift` - 단일 창 런타임
- `Sources/MiyeonSlap/MainWindowController.swift` - 단일 오버레이 창
- `Sources/MiyeonSlap/SceneView.swift` - 단일 built-in pet 렌더링/상호작용

### LovaSlap-PET

- `Sources/LovaSlapPET/main.swift` - 새 앱 시작점 + self-check
- `Sources/LovaSlapPET/AppDelegate.swift` - 새 앱 메뉴바 런타임
- `Sources/LovaSlapPET/PetsCoordinator.swift` - 상태 아이템 메뉴와 멀티 펫 조정
- `Sources/LovaSlapPET/PetModels.swift` - 펫 자산, 배치, PNG 시퀀스 로딩
- `Sources/LovaSlapPET/MainWindowController.swift` - 각 펫별 투명 오버레이 창
- `Sources/LovaSlapPET/SceneView.swift` - 내장 프리셋/PNG 시퀀스 렌더링

## 알려진 제한 사항

- `LovaSlap-PET`은 true wallpaper embedding이 아니라 **투명 오버레이 창 기반**입니다.
- PNG 시퀀스 폴더 선택은 현재 세션 동안만 유지됩니다.
- 물리 충격 감지는 Apple의 비공개/비안정 API 성격을 띱니다.

## Gatekeeper / 실행 문제 해결

```bash
xattr -dr com.apple.quarantine LovaSlap-PET.app
open LovaSlap-PET.app
```
