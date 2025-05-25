import Foundation

public struct Directions: Codable, Equatable {
    public var landSpeedDirection: OptimizeDirection
    public var waterSpeedDirection: OptimizeDirection
    public var airSpeedDirection: OptimizeDirection
    public var antigravSpeedDirection: OptimizeDirection
    public var accelDirection: OptimizeDirection
    public var weightDirection: OptimizeDirection
    public var landHandlingDirection: OptimizeDirection
    public var waterHandlingDirection: OptimizeDirection
    public var airHandlingDirection: OptimizeDirection
    public var antigravHandlingDirection: OptimizeDirection
    public var tractionDirection: OptimizeDirection
    public var miniTurboDirection: OptimizeDirection
    public var invulnDirection: OptimizeDirection
}

public struct SaveData: Codable, Equatable {
    public var minStats: BaseStatBlock
    public var maxStats: BaseStatBlock
    public var directions: Directions
    public var disallowedKartPieces: Set<String>
}
