# Release Runbook

## 목적

릴리스 전에 실제 배포 산출물과 문서가 맞는지 빠르게 검증하기 위한 절차입니다.

## 실행 순서

```bash
swift build
swift run MiyeonSlap --self-check
zsh scripts/build_app_bundle.sh
zsh scripts/package_release_zip.sh
zsh scripts/package_release_dmg.sh
```

## 확인 항목

- `LovaSlap-PET.app` 생성 여부
- `dist/LovaSlap-PET.zip` 생성 여부
- `dist/LovaSlap-PET.dmg` 생성 여부
- README의 설치/실행 명령과 실제 산출물이 일치하는지
- `Casks/lovaslap.rb`의 URL과 홈페이지만 새 GitHub 저장소를 가리키는지

## 수동 확인

- 앱 실행 시 화면 오른쪽 아래에 펫이 표시되는지
- 클릭 시 반응 후 idle로 복귀하는지
- Gatekeeper 우회 안내가 README에 있는지
