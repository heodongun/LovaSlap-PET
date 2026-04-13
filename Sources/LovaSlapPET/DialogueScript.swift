import Foundation

enum CharacterMood {
    case calm
    case startled
    case pout
    case dizzy
}

struct DialogueLine: Equatable {
    let speaker: String
    let text: String
    let mood: CharacterMood
}

final class DialogueScript {
    private let lines: [DialogueLine] = [
        DialogueLine(
            speaker: "Miyeon",
            text: "H-hi... if you're going to tap me, at least be cute about it.",
            mood: .calm
        ),
        DialogueLine(
            speaker: "Miyeon",
            text: "Ack— rude! My ribbon almost flew off just now.",
            mood: .startled
        ),
        DialogueLine(
            speaker: "Miyeon",
            text: "You really are committing to the bit, huh? I am judging you softly.",
            mood: .pout
        ),
        DialogueLine(
            speaker: "Miyeon",
            text: "Wah... stars... okay, okay, I get it. That's enough slapping for one scene.",
            mood: .dizzy
        )
    ]

    private var index = 0

    var currentLine: DialogueLine {
        lines[index]
    }

    var count: Int {
        lines.count
    }

    func advance() -> DialogueLine {
        if index < lines.count - 1 {
            index += 1
        }

        return lines[index]
    }
}
