cask "lovaslap" do
  version "0.2.0"
  sha256 "a663846b4910f7bc8adc24064472490e422fc34b052b7b8057310df61f76a749"

  depends_on macos: ">= :ventura"

  url "https://github.com/heodongun/LovaSlap-PET/releases/download/v#{version}/LovaSlap-PET.dmg"
  name "LovaSlap-PET"
  desc "Pixel-art desktop pet overlay for macOS"
  homepage "https://github.com/heodongun/LovaSlap-PET"

  app "LovaSlap-PET.app"
end
