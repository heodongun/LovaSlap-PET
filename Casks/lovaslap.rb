cask "lovaslap" do
  version "0.1.0"
  sha256 "f7873fa4a10a72eadfe0b17bb194b2b2d8af983319a04bea23103a47fd9bc268"

  url "https://github.com/heodongun/LovaSlap-PET/releases/download/v#{version}/MiyeonSlap.dmg"
  name "MiyeonSlap"
  desc "Pixel-art desktop pet overlay for macOS"
  homepage "https://github.com/heodongun/LovaSlap-PET"

  app "MiyeonSlap.app"
end
