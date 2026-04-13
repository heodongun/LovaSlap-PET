cask "lovaslap" do
  version "0.3.0"
  sha256 "15096142ee6921b585b8e2673ba0fe0b2e6e7da2c7b58ff018a8209afd1cc48d"

  depends_on macos: ">= :ventura"

  url "https://github.com/heodongun/LovaSlap-PET/releases/download/v#{version}/LovaSlap-PET.dmg"
  name "LovaSlap-PET"
  desc "Pixel-art desktop pet overlay for macOS"
  homepage "https://github.com/heodongun/LovaSlap-PET"

  app "LovaSlap-PET.app"
end
