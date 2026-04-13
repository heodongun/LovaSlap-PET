cask "lovaslap" do
  version "0.2.0"
  sha256 "3777ae7f895aa1c50de17e677157023183258e4fc5d2e4e24d6621cc4ab12587"

  depends_on macos: ">= :ventura"

  url "https://github.com/heodongun/LovaSlap-PET/releases/download/v#{version}/LovaSlap-PET.dmg"
  name "LovaSlap-PET"
  desc "Pixel-art desktop pet overlay for macOS"
  homepage "https://github.com/heodongun/LovaSlap-PET"

  app "LovaSlap-PET.app"
end
