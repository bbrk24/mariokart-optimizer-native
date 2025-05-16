struct TerrainDependentStat: Decodable {
    var land: Float
    var air: Float
    var water: Float
    var antigrav: Float
}

class BaseStatBlock: Decodable, @unchecked Sendable {
    var speed: TerrainDependentStat
    var accel: Float
    var weight: Float
    var handling: TerrainDependentStat
    var traction: Float
    var miniTurbo: Float
    var invuln: Float
}

final class CharacterStatBlock: BaseStatBlock, @unchecked Sendable {
    var characters: [String]

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
    var wheels: [String]

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
    var gliders: [String]

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
    var karts: [String]
    var inwardDrift: Bool

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
