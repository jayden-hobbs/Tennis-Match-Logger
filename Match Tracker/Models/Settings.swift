import Foundation

struct Settings: Codable {
    var playerProfile: Player
    
    static let `default` = Settings(
        playerProfile: Player(
            name: "Me",
            handedness: "Right"
        )
    )
} 