cask "lovaslap" do
  version "0.1.0"
  sha256 "6183c8f63613e0498a1cc1d983a73c13da5cbb658458cd4b63906889a3f8938a"

  url "https://github.com/heodongun/LovaSlap-PET/releases/download/v#{version}/MiyeonSlap.zip"
  name "MiyeonSlap"
  desc "Cute AppKit pixel slap-reactive mini visual novel"
  homepage "https://github.com/heodongun/LovaSlap-PET"

  app "MiyeonSlap.app"
end
