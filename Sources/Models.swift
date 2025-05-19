struct TerrainDependentStat: Decodable {
    var land: Float
    var air: Float
    var water: Float
    var antigrav: Float

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

class BaseStatBlock: Decodable, @unchecked Sendable {
    let speed: TerrainDependentStat
    let accel: Float
    let weight: Float
    let handling: TerrainDependentStat
    let traction: Float
    let miniTurbo: Float
    let invuln: Float

    private init(
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

    var labelledStats: [(String, Float)] {
        [
            ("Speed", speed.land),
            ("Water speed", speed.water),
            ("Glider speed", speed.air),
            ("Antigravity speed", speed.antigrav),
            ("Acceleration", accel),
            ("Weight", weight),
            ("Handling", handling.land),
            ("Water handling", handling.water),
            ("Glider handling", handling.air),
            ("Antigravity handling", handling.antigrav),
            ("Traction", traction),
            ("Mini-Turbo", miniTurbo),
            ("Invincibility", invuln)
        ]
    }
}

final class CharacterStatBlock: BaseStatBlock, @unchecked Sendable {
    let characters: [String]

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.characters = try container.decode([String].self, forKey: .characters)

        try super.init(from: decoder)
    }

    enum CodingKeys: String, CodingKey {
        case characters
    }
}

final class WheelStatBlock: BaseStatBlock, @unchecked Sendable {
    let wheels: [String]

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.wheels = try container.decode([String].self, forKey: .wheels)

        try super.init(from: decoder)
    }

    enum CodingKeys: String, CodingKey {
        case wheels
    }
}

final class GliderStatBlock: BaseStatBlock, @unchecked Sendable {
    let gliders: [String]

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.gliders = try container.decode([String].self, forKey: .gliders)

        try super.init(from: decoder)
    }

    enum CodingKeys: String, CodingKey {
        case gliders
    }
}

final class KartStatBlock: BaseStatBlock, @unchecked Sendable {
    let karts: [String]
    let inwardDrift: Bool

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.karts = try container.decode([String].self, forKey: .karts)
        self.inwardDrift = try container.decode(Bool.self, forKey: .inwardDrift)

        try super.init(from: decoder)
    }

    enum CodingKeys: String, CodingKey {
        case karts, inwardDrift
    }
}

struct GameData: Decodable {
    var characters: [CharacterStatBlock]
    var karts: [KartStatBlock]
    var wheels: [WheelStatBlock]
    var gliders: [GliderStatBlock]
    var rivals: [String: [String]]
}
