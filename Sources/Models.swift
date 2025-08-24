public struct TerrainDependentStat: Sendable, Codable, Equatable {
    public var land: Float
    public var air: Float
    public var water: Float
    public var antigrav: Float

    static let zero = TerrainDependentStat(land: 0.0, air: 0.0, water: 0.0, antigrav: 0.0)

    static func + (lhs: TerrainDependentStat, rhs: TerrainDependentStat) -> TerrainDependentStat {
        .init(
            land: lhs.land + rhs.land,
            air: lhs.air + rhs.air,
            water: lhs.water + rhs.water,
            antigrav: lhs.antigrav + rhs.antigrav
        )
    }
}

public class BaseStatBlock: Codable, Equatable, @unchecked Sendable {
    public let speed: TerrainDependentStat
    public let accel: Float
    public let weight: Float
    public let handling: TerrainDependentStat
    public let traction: Float
    public let miniTurbo: Float
    public let invuln: Float

    init(
        speed: TerrainDependentStat,
        accel: Float,
        weight: Float,
        handling: TerrainDependentStat,
        traction: Float,
        miniTurbo: Float,
        invuln: Float
    ) {
        self.speed = speed
        self.accel = accel
        self.weight = weight
        self.handling = handling
        self.traction = traction
        self.miniTurbo = miniTurbo
        self.invuln = invuln
    }

    static func + (lhs: BaseStatBlock, rhs: BaseStatBlock) -> BaseStatBlock {
        .init(
            speed: lhs.speed + rhs.speed,
            accel: lhs.accel + rhs.accel,
            weight: lhs.weight + rhs.weight,
            handling: lhs.handling + rhs.handling,
            traction: lhs.traction + rhs.traction,
            miniTurbo: lhs.miniTurbo + rhs.miniTurbo,
            invuln: lhs.invuln + rhs.invuln
        )
    }

    public static func == (lhs: BaseStatBlock, rhs: BaseStatBlock) -> Bool {
        return lhs.speed == rhs.speed
            && lhs.accel == rhs.accel
            && lhs.weight == rhs.weight
            && lhs.handling == rhs.handling
            && lhs.traction == rhs.traction
            && lhs.miniTurbo == rhs.miniTurbo
            && lhs.invuln == rhs.invuln
    }

    var labelledStats: [(String, Float)] {
        let localization = localizations[OptionsManager.shared.locale]!

        return [
            (localization.stats.landSpeed, speed.land),
            (localization.stats.waterSpeed, speed.water), (localization.stats.airSpeed, speed.air),
            (localization.stats.antigravSpeed, speed.antigrav), (localization.stats.accel, accel),
            (localization.stats.weight, weight), (localization.stats.landHandling, handling.land),
            (localization.stats.waterHandling, handling.water),
            (localization.stats.airHandling, handling.air),
            (localization.stats.antigravHandling, handling.antigrav),
            (localization.stats.traction, traction), (localization.stats.miniTurbo, miniTurbo),
            (localization.stats.invuln, invuln),
        ]
    }
}

public final class CharacterStatBlock: BaseStatBlock, @unchecked Sendable {
    public let characters: [String]

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.characters = try container.decode([String].self, forKey: .characters)

        try super.init(from: decoder)
    }

    public override func encode(to encoder: any Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(characters, forKey: .characters)
    }

    enum CodingKeys: String, CodingKey {
        case characters
    }
}

public final class WheelStatBlock: BaseStatBlock, @unchecked Sendable {
    public let wheels: [String]

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.wheels = try container.decode([String].self, forKey: .wheels)

        try super.init(from: decoder)
    }

    public override func encode(to encoder: any Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(wheels, forKey: .wheels)
    }

    enum CodingKeys: String, CodingKey {
        case wheels
    }
}

public final class GliderStatBlock: BaseStatBlock, @unchecked Sendable {
    public let gliders: [String]

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.gliders = try container.decode([String].self, forKey: .gliders)

        try super.init(from: decoder)
    }

    public override func encode(to encoder: any Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gliders, forKey: .gliders)
    }

    enum CodingKeys: String, CodingKey {
        case gliders
    }
}

public final class KartStatBlock: BaseStatBlock, @unchecked Sendable {
    public let karts: [String]
    public let inwardDrift: Bool

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.karts = try container.decode([String].self, forKey: .karts)
        self.inwardDrift = try container.decode(Bool.self, forKey: .inwardDrift)

        try super.init(from: decoder)
    }

    public override func encode(to encoder: any Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inwardDrift, forKey: .inwardDrift)
        try container.encode(karts, forKey: .karts)
    }

    enum CodingKeys: String, CodingKey {
        case karts
        case inwardDrift
    }
}

public struct GameData: Decodable {
    public var characters: [CharacterStatBlock]
    public var karts: [KartStatBlock]
    public var wheels: [WheelStatBlock]
    public var gliders: [GliderStatBlock]
    public var rivals: [String: [String]]
}
