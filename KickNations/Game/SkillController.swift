import Foundation

struct SkillController {
    let skillID: SkillID

    var displayName: String {
        skillID.displayName
    }

    var summary: String {
        skillID.shortEffect
    }
}

