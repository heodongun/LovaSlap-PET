# Release Runbook

## 목적

이 저장소는 `MiyeonSlap`와 `LovaSlap-PET` 두 앱을 함께 유지하므로, 어떤 앱을 배포하는지 명확히 구분해서 검증해야 합니다.

## LovaSlap-PET 배포 검증

```bash
swift build --product LovaSlapPET
swift run LovaSlapPET --self-check
zsh scripts/build_lovaslap_pet_app_bundle.sh
zsh scripts/package_lovaslap_pet_zip.sh
zsh scripts/package_lovaslap_pet_dmg.sh
```

## MiyeonSlap 레거시 검증

```bash
swift build --product MiyeonSlap
swift run MiyeonSlap --self-check
zsh scripts/build_app_bundle.sh
zsh scripts/package_miyeonslap_zip.sh
zsh scripts/package_miyeonslap_dmg.sh
```

## 확인 항목

- LovaSlap-PET artifact:
  - `LovaSlap-PET.app`
  - `dist/LovaSlap-PET.zip`
  - `dist/LovaSlap-PET.dmg`
- MiyeonSlap artifact:
  - `MiyeonSlap.app`
  - `dist/MiyeonSlap.zip`
  - `dist/MiyeonSlap.dmg`
- README가 새 앱 다운로드와 레거시 앱 보존을 명확히 구분하는지
- `Casks/lovaslap.rb`가 새 앱 artifact와 일치하는지

## 수동 확인

- `MiyeonSlap` 실행 시 기존 단일 slap 앱 동작이 유지되는지
- `LovaSlap-PET` 실행 시 메뉴바 상태 아이템과 멀티 펫 동작이 나오는지
- Gatekeeper 우회 안내가 새 앱 다운로드 이름과 맞는지
