cask "lovaslap" do
  version "0.3.0"
  sha256 "46a2a8152682cc7188de571b72c1931b30ba4c1e42c881cea367345bf406dc55"

  depends_on macos: ">= :ventura"

  url "https://github.com/heodongun/LovaSlap-PET/releases/download/v#{version}/LovaSlap-PET.dmg"
  name "LovaSlap-PET"
  desc "Pixel-art desktop pet overlay for macOS"
  homepage "https://github.com/heodongun/LovaSlap-PET"

  app "LovaSlap-PET.app"
end
