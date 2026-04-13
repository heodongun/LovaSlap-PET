cask "lovaslap" do
  version "0.1.1"
  sha256 "4f280d5abfb2750c9c819ab78df5011986cb2476f3bd6237909aad00c7c12e8c"

  depends_on macos: ">= :ventura"

  url "https://github.com/heodongun/LovaSlap-PET/releases/download/v#{version}/LovaSlap-PET.dmg"
  name "LovaSlap-PET"
  desc "Pixel-art desktop pet overlay for macOS"
  homepage "https://github.com/heodongun/LovaSlap-PET"

  app "LovaSlap-PET.app"
end
