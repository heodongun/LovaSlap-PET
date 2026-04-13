# 2026-04-13 - MiyeonSlap / LovaSlap-PET split

## 배경

기존 저장소는 `MiyeonSlap` 단일 app identity 위에 `LovaSlap-PET` public 이름을 덧씌우는 방식이라, 기존 앱을 유지하면서 새 앱을 따로 배포하기 어려웠습니다.

## 문제 또는 목표

- 기존 `MiyeonSlap` 앱은 그대로 둔다
- 새로운 앱은 별도 product / 별도 bundle / 별도 artifact로 다운로드되게 한다
- executable rename 기반 배포를 실제 2-app 구조로 분리한다

## 변경 내용

- `Package.swift`에 `MiyeonSlap`와 `LovaSlapPET` 두 executable product를 정의
- `Sources/MiyeonSlap/`는 기존 앱으로 복원
- `Sources/LovaSlapPET/`에 새 앱 런타임 분리
- MiyeonSlap / LovaSlap-PET 각각의 bundle/zip/dmg 스크립트 분리
- 문서/런북/에이전트 규칙을 dual-app 기준으로 갱신

## 설계 이유

- 기존 앱을 덮어쓰지 않고 유지하기 위해
- 새 앱을 별도 다운로드 표면으로 만들기 위해
- product identity와 public bundle identity가 섞이지 않도록 하기 위해

## 영향 범위

- Swift package 구조
- source layout
- bundle / zip / dmg packaging
- 문서 / 배포 표면

## 검증 방법

- `swift build --product MiyeonSlap`
- `swift build --product LovaSlapPET`
- `swift run MiyeonSlap --self-check`
- `swift run LovaSlapPET --self-check`
- `zsh scripts/build_app_bundle.sh`
- `zsh scripts/build_lovaslap_pet_app_bundle.sh`

## 남아 있는 한계

- 새 앱과 기존 앱 사이에 일부 코드 중복이 존재함
- `LovaSlap-PET`은 여전히 true wallpaper embedding은 아님

## 후속 과제

- 두 앱 공통 런타임 추출 여부 재검토
- legacy/new app의 개별 release automation 강화
