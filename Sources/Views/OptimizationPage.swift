import SwiftCrossUI
import Foundation

public enum OptimizeDirection: CaseIterable, Equatable, CustomStringConvertible, Codable {
    case dont, min, max

    public init(from decoder: any Decoder) throws {
        let value = try Int8(from: decoder)
        switch value {
        case 0: self = .dont
        case -1: self = .min
        case 1: self = .max
        default:
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid value \(value) (expected -1, 0, or 1)"
                )
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        let value =
            switch self {
            case .dont: 0 as Int8
            case .min: -1 as Int8
            case .max: 1 as Int8
            }
        try value.encode(to: encoder)
    }

    public var description: String {
        let localization = localizations[OptionsManager.shared.locale]!

        return switch self {
        case .dont: localization.uiElements.dontOptimize
        case .min: localization.uiElements.minimize
        case .max: localization.uiElements.maximize
        }
    }

    var multiplier: Float {
        switch self {
        case .dont: 0.0
        case .min: -1.0
        case .max: 1.0
        }
    }
}

struct OptimizerState {
    var minLandSpeed: Float? = 0.75
    var maxLandSpeed: Float? = 5.75
    var minWaterSpeed: Float? = 0.75
    var maxWaterSpeed: Float? = 5.75
    var minAirSpeed: Float? = 0.75
    var maxAirSpeed: Float? = 5.75
    var minAntigravSpeed: Float? = 0.75
    var maxAntigravSpeed: Float? = 5.75
    var minAccel: Float? = 0.75
    var maxAccel: Float? = 5.75
    var minWeight: Float? = 0.75
    var maxWeight: Float? = 5.75
    var minLandHandling: Float? = 0.75
    var maxLandHandling: Float? = 5.75
    var minWaterHandling: Float? = 0.75
    var maxWaterHandling: Float? = 5.75
    var minAirHandling: Float? = 0.75
    var maxAirHandling: Float? = 5.75
    var minAntigravHandling: Float? = 0.75
    var maxAntigravHandling: Float? = 5.75
    var minTraction: Float? = 0.75
    var maxTraction: Float? = 5.75
    var minMiniTurbo: Float? = 0.75
    var maxMiniTurbo: Float? = 5.75
    var minInvuln: Float? = 0.75
    var maxInvuln: Float? = 5.75

    var landSpeedDirection: OptimizeDirection? = .dont
    var waterSpeedDirection: OptimizeDirection? = .dont
    var airSpeedDirection: OptimizeDirection? = .dont
    var antigravSpeedDirection: OptimizeDirection? = .dont
    var accelDirection: OptimizeDirection? = .dont
    var weightDirection: OptimizeDirection? = .dont
    var landHandlingDirection: OptimizeDirection? = .dont
    var waterHandlingDirection: OptimizeDirection? = .dont
    var airHandlingDirection: OptimizeDirection? = .dont
    var antigravHandlingDirection: OptimizeDirection? = .dont
    var tractionDirection: OptimizeDirection? = .dont
    var miniTurboDirection: OptimizeDirection? = .dont
    var invulnDirection: OptimizeDirection? = .dont

    var allowedCharacters: [[(String, Bool)]] = []
    var allowedKarts: [[(String, Bool)]] = []
    var allowedWheels: [[(String, Bool)]] = []
    var allowedGliders: [[(String, Bool)]] = []

    func toSaveData() -> SaveData {
        SaveData(
            minStats: BaseStatBlock(
                speed: .init(
                    land: minLandSpeed!,
                    air: minAirSpeed!,
                    water: minWaterSpeed!,
                    antigrav: minAntigravSpeed!
                ),
                accel: minAccel!,
                weight: minWeight!,
                handling: .init(
                    land: minLandHandling!,
                    air: minAirHandling!,
                    water: minWaterHandling!,
                    antigrav: minAntigravHandling!
                ),
                traction: minTraction!,
                miniTurbo: minMiniTurbo!,
                invuln: minInvuln!
            ),
            maxStats: BaseStatBlock(
                speed: .init(
                    land: maxLandSpeed!,
                    air: maxAirSpeed!,
                    water: maxWaterSpeed!,
                    antigrav: maxAntigravSpeed!
                ),
                accel: maxAccel!,
                weight: maxWeight!,
                handling: .init(
                    land: maxLandHandling!,
                    air: maxAirHandling!,
                    water: maxWaterHandling!,
                    antigrav: maxAntigravHandling!
                ),
                traction: maxTraction!,
                miniTurbo: maxMiniTurbo!,
                invuln: maxInvuln!
            ),
            directions: Directions(
                landSpeedDirection: landSpeedDirection!,
                waterSpeedDirection: waterSpeedDirection!,
                airSpeedDirection: airSpeedDirection!,
                antigravSpeedDirection: antigravSpeedDirection!,
                accelDirection: accelDirection!,
                weightDirection: weightDirection!,
                landHandlingDirection: landHandlingDirection!,
                waterHandlingDirection: waterHandlingDirection!,
                airHandlingDirection: airHandlingDirection!,
                antigravHandlingDirection: antigravHandlingDirection!,
                tractionDirection: tractionDirection!,
                miniTurboDirection: miniTurboDirection!,
                invulnDirection: invulnDirection!
            ),
            disallowedKartPieces: Set(
                [allowedCharacters, allowedKarts, allowedWheels, allowedGliders]
                    .flatMap {
                        $0.flatMap {
                            $0.filter { !$1 }.map(\.0)
                        }
                    }
            )
        )
    }

    static func fromSaveData(
        _ saveData: SaveData,
        gameData: GameData
    ) -> OptimizerState {
        .init(
            minLandSpeed: saveData.minStats.speed.land,
            maxLandSpeed: saveData.maxStats.speed.land,
            minWaterSpeed: saveData.minStats.speed.water,
            maxWaterSpeed: saveData.maxStats.speed.water,
            minAirSpeed: saveData.minStats.speed.air,
            maxAirSpeed: saveData.maxStats.speed.air,
            minAntigravSpeed: saveData.minStats.speed.antigrav,
            maxAntigravSpeed: saveData.maxStats.speed.antigrav,
            minAccel: saveData.minStats.accel,
            maxAccel: saveData.maxStats.accel,
            minWeight: saveData.minStats.weight,
            maxWeight: saveData.maxStats.weight,
            minLandHandling: saveData.minStats.handling.land,
            maxLandHandling: saveData.maxStats.handling.land,
            minWaterHandling: saveData.minStats.handling.water,
            maxWaterHandling: saveData.maxStats.handling.water,
            minAirHandling: saveData.minStats.handling.air,
            maxAirHandling: saveData.maxStats.handling.air,
            minAntigravHandling: saveData.minStats.handling.antigrav,
            maxAntigravHandling: saveData.maxStats.handling.antigrav,
            minTraction: saveData.minStats.traction,
            maxTraction: saveData.maxStats.traction,
            minMiniTurbo: saveData.minStats.miniTurbo,
            maxMiniTurbo: saveData.maxStats.miniTurbo,
            minInvuln: saveData.minStats.invuln,
            maxInvuln: saveData.maxStats.invuln,
            landSpeedDirection: saveData.directions.landSpeedDirection,
            waterSpeedDirection: saveData.directions.waterSpeedDirection,
            airSpeedDirection: saveData.directions.airSpeedDirection,
            antigravSpeedDirection: saveData.directions.antigravSpeedDirection,
            accelDirection: saveData.directions.accelDirection,
            weightDirection: saveData.directions.weightDirection,
            landHandlingDirection: saveData.directions.landHandlingDirection,
            waterHandlingDirection: saveData.directions.waterHandlingDirection,
            airHandlingDirection: saveData.directions.airHandlingDirection,
            antigravHandlingDirection: saveData.directions.antigravHandlingDirection,
            tractionDirection: saveData.directions.tractionDirection,
            miniTurboDirection: saveData.directions.miniTurboDirection,
            invulnDirection: saveData.directions.invulnDirection,
            allowedCharacters: gameData.characters.map {
                $0.characters.map { ($0, !saveData.disallowedKartPieces.contains($0)) }
            },
            allowedKarts: gameData.karts.map {
                $0.karts.map { ($0, !saveData.disallowedKartPieces.contains($0)) }
            },
            allowedWheels: gameData.wheels.map {
                $0.wheels.map { ($0, !saveData.disallowedKartPieces.contains($0)) }
            },
            allowedGliders: gameData.gliders.map {
                $0.gliders.map { ($0, !saveData.disallowedKartPieces.contains($0)) }
            }
        )
    }
}

struct OptimizationPage: View {
    @State
    private var optionsManager = OptionsManager.shared

    @State
    private var dataManager = GameDataManager.shared

    @Binding
    var character: NameAndIndex?

    @Binding
    var kart: NameAndIndex?

    @Binding
    var wheel: NameAndIndex?

    @Binding
    var glider: NameAndIndex?

    @Binding
    var fileDialogType: FileDialogType

    @Binding
    var onFileSelect: (String) -> Void

    @State
    private var inputs = OptimizerState()

    @State
    private var showLimitCharacters = false

    @State
    private var showLimitKarts = false

    @State
    private var showLimitWheels = false

    @State
    private var showLimitGliders = false

    private var localization: Localization { localizations[optionsManager.locale]! }
    private var data: GameData? { dataManager.data }

    @State
    private var combos: [((Int, [String]), (Int, [String]), (Int, [String]), (Int, [String]))] = []

    @State
    private var formatter = FloatingPointFormatStyle<Float>()
        .precision(.integerAndFractionLength(integerLimits: 1..<2, fractionLimits: 0...2))

    private let saveDataManager = SaveDataManager()

    @ViewBuilder
    private func inputRow(
        label: String,
        min: Binding<Float?>,
        max: Binding<Float?>,
        direction: Binding<OptimizeDirection?>
    ) -> some View {
        Text(label)

        HStack {
            FloatInput(min: 0.75, max: max.wrappedValue ?? 5.75, value: min, formatter: formatter)

            FloatInput(min: min.wrappedValue ?? 0.75, max: 5.75, value: max, formatter: formatter)

            Picker(of: OptimizeDirection.allCases, selection: direction)
        }
    }

    var body: some View {
        if let data {
            VStack {
                Spacer()
                    .frame(height: 4)

                Button(localization.uiElements.loadFilters) {
                    onFileSelect = {
                        do {
                            guard let encodedData = saveDataManager.readSaveData(from: $0) else {
                                return
                            }

                            fileDialogType = .none

                            let saveData = try saveDataManager.decoder.decode(
                                SaveData.self,
                                from: encodedData
                            )
                            inputs = .fromSaveData(saveData, gameData: data)
                        } catch {
                            ErrorManager.shared.addError(error)
                        }
                    }
                    fileDialogType = .load
                }

                Group {
                    Group {
                        inputRow(
                            label: localization.stats.landSpeed,
                            min: $inputs.minLandSpeed,
                            max: $inputs.maxLandSpeed,
                            direction: $inputs.landSpeedDirection
                        )
                        inputRow(
                            label: localization.stats.waterSpeed,
                            min: $inputs.minWaterSpeed,
                            max: $inputs.maxWaterSpeed,
                            direction: $inputs.waterSpeedDirection
                        )
                        inputRow(
                            label: localization.stats.airSpeed,
                            min: $inputs.minAirSpeed,
                            max: $inputs.maxAirSpeed,
                            direction: $inputs.airSpeedDirection
                        )
                        inputRow(
                            label: localization.stats.antigravSpeed,
                            min: $inputs.minAntigravSpeed,
                            max: $inputs.maxAntigravSpeed,
                            direction: $inputs.antigravSpeedDirection
                        )
                    }

                    inputRow(
                        label: localization.stats.accel,
                        min: $inputs.minAccel,
                        max: $inputs.maxAccel,
                        direction: $inputs.accelDirection
                    )
                    inputRow(
                        label: localization.stats.weight,
                        min: $inputs.minWeight,
                        max: $inputs.maxWeight,
                        direction: $inputs.weightDirection
                    )

                    Group {
                        inputRow(
                            label: localization.stats.landHandling,
                            min: $inputs.minLandHandling,
                            max: $inputs.maxLandHandling,
                            direction: $inputs.landHandlingDirection
                        )
                        inputRow(
                            label: localization.stats.waterHandling,
                            min: $inputs.minWaterHandling,
                            max: $inputs.maxWaterHandling,
                            direction: $inputs.waterHandlingDirection
                        )
                        inputRow(
                            label: localization.stats.airHandling,
                            min: $inputs.minAirHandling,
                            max: $inputs.maxAirHandling,
                            direction: $inputs.airHandlingDirection
                        )
                        inputRow(
                            label: localization.stats.antigravHandling,
                            min: $inputs.minAntigravHandling,
                            max: $inputs.maxAntigravHandling,
                            direction: $inputs.antigravHandlingDirection
                        )
                    }

                    inputRow(
                        label: localization.stats.traction,
                        min: $inputs.minTraction,
                        max: $inputs.maxTraction,
                        direction: $inputs.tractionDirection
                    )
                    inputRow(
                        label: localization.stats.miniTurbo,
                        min: $inputs.minMiniTurbo,
                        max: $inputs.maxMiniTurbo,
                        direction: $inputs.miniTurboDirection
                    )
                    inputRow(
                        label: localization.stats.invuln,
                        min: $inputs.minInvuln,
                        max: $inputs.maxInvuln,
                        direction: $inputs.invulnDirection
                    )
                }

                Group {
                    Toggle(localization.uiElements.limitCharacters, active: $showLimitCharacters)
                        .toggleStyle(.button)
                        .frame(maxWidth: .infinity)

                    if showLimitCharacters {
                        ForEach(Array(inputs.allowedCharacters.enumerated())) { i, els in
                            ForEach(Array(els.enumerated())) { j, t in
                                Toggle(
                                    localization.kartParts[t.0] ?? t.0,
                                    active: $inputs.allowedCharacters[i][j].1
                                )
                                .toggleStyle(.switch)
                            }
                        }
                    }

                    Toggle(localization.uiElements.limitKarts, active: $showLimitKarts)
                        .toggleStyle(.button)
                        .frame(maxWidth: .infinity)

                    if showLimitKarts {
                        ForEach(Array(inputs.allowedKarts.enumerated())) { i, els in
                            ForEach(Array(els.enumerated())) { j, t in
                                Toggle(
                                    localization.kartParts[t.0] ?? t.0,
                                    active: $inputs.allowedKarts[i][j].1
                                )
                                .toggleStyle(.switch)
                            }
                        }
                    }

                    Toggle(localization.uiElements.limitWheels, active: $showLimitWheels)
                        .toggleStyle(.button)
                        .frame(maxWidth: .infinity)

                    if showLimitWheels {
                        ForEach(Array(inputs.allowedWheels.enumerated())) { i, els in
                            ForEach(Array(els.enumerated())) { j, t in
                                Toggle(
                                    localization.kartParts[t.0] ?? t.0,
                                    active: $inputs.allowedWheels[i][j].1
                                )
                                .toggleStyle(.switch)
                            }
                        }
                    }

                    Toggle(localization.uiElements.limitGliders, active: $showLimitGliders)
                        .toggleStyle(.button)
                        .frame(maxWidth: .infinity)

                    if showLimitGliders {
                        ForEach(Array(inputs.allowedGliders.enumerated())) { i, els in
                            ForEach(Array(els.enumerated())) { j, t in
                                Toggle(
                                    localization.kartParts[t.0] ?? t.0,
                                    active: $inputs.allowedGliders[i][j].1
                                )
                                .toggleStyle(.switch)
                            }
                        }
                    }
                }

                HStack {
                    Button(localization.uiElements.go) {
                        combos = fourWayProduct(
                            data.characters.enumerated()
                                .filter {
                                    inputs.allowedCharacters[$0.offset].contains(where: \.1)
                                },
                            data.karts.enumerated()
                                .filter {
                                    inputs.allowedKarts[$0.offset].contains(where: \.1)
                                },
                            data.wheels.enumerated()
                                .filter {
                                    inputs.allowedWheels[$0.offset].contains(where: \.1)
                                },
                            data.gliders.enumerated()
                                .filter {
                                    inputs.allowedGliders[$0.offset].contains(where: \.1)
                                }
                        )
                        .filter { character, kart, wheel, glider in
                            let statTotal =
                                character.element + kart.element + wheel.element + glider.element
                            return (inputs.minLandSpeed!...inputs.maxLandSpeed!)
                                .contains(statTotal.speed.land)
                                && (inputs.minWaterSpeed!...inputs.maxWaterSpeed!)
                                    .contains(statTotal.speed.water)
                                && (inputs.minAirSpeed!...inputs.maxAirSpeed!)
                                    .contains(statTotal.speed.air)
                                && (inputs.minAntigravSpeed!...inputs.maxAntigravSpeed!)
                                    .contains(statTotal.speed.antigrav)
                                && (inputs.minAccel!...inputs.maxAccel!).contains(statTotal.accel)
                                && (inputs.minWeight!...inputs.maxWeight!)
                                    .contains(statTotal.weight)
                                && (inputs.minLandHandling!...inputs.maxLandHandling!)
                                    .contains(statTotal.handling.land)
                                && (inputs.minWaterHandling!...inputs.maxWaterHandling!)
                                    .contains(statTotal.handling.water)
                                && (inputs.minAirHandling!...inputs.maxAirHandling!)
                                    .contains(statTotal.handling.air)
                                && (inputs.minAntigravHandling!...inputs.maxAntigravHandling!)
                                    .contains(statTotal.handling.antigrav)
                                && (inputs.minTraction!...inputs.maxTraction!)
                                    .contains(statTotal.traction)
                                && (inputs.minMiniTurbo!...inputs.maxMiniTurbo!)
                                    .contains(statTotal.miniTurbo)
                                && (inputs.minInvuln!...inputs.maxInvuln!)
                                    .contains(statTotal.invuln)
                        }
                        .maxAll { character, kart, wheel, glider in
                            let statTotal =
                                character.element + kart.element + wheel.element + glider.element
                            return
                                (inputs.landSpeedDirection!.multiplier * statTotal.speed.land
                                + inputs.waterSpeedDirection!.multiplier * statTotal.speed.water
                                + inputs.airSpeedDirection!.multiplier * statTotal.speed.air
                                + inputs.antigravSpeedDirection!.multiplier
                                * statTotal.speed.antigrav)
                                / max(
                                    1.0,
                                    abs(inputs.landSpeedDirection!.multiplier)
                                        + abs(inputs.waterSpeedDirection!.multiplier)
                                        + abs(inputs.airSpeedDirection!.multiplier)
                                        + abs(inputs.antigravSpeedDirection!.multiplier)
                                )
                                + inputs.accelDirection!.multiplier * statTotal.accel
                                + inputs.weightDirection!.multiplier * statTotal.weight
                                + (inputs.landHandlingDirection!.multiplier
                                    * statTotal.handling.land
                                    + inputs.waterHandlingDirection!.multiplier
                                    * statTotal.handling.water
                                    + inputs.airHandlingDirection!.multiplier
                                    * statTotal.handling.air
                                    + inputs.antigravHandlingDirection!.multiplier
                                    * statTotal.handling.antigrav)
                                / max(
                                    1.0,
                                    abs(inputs.landHandlingDirection!.multiplier)
                                        + abs(inputs.waterHandlingDirection!.multiplier)
                                        + abs(inputs.airHandlingDirection!.multiplier)
                                        + abs(inputs.antigravHandlingDirection!.multiplier)
                                )
                                + inputs.tractionDirection!.multiplier * statTotal.traction
                                + inputs.miniTurboDirection!.multiplier * statTotal.miniTurbo
                                + inputs.invulnDirection!.multiplier * statTotal.invuln
                        }
                        .map {
                            (
                                (
                                    $0.offset,
                                    inputs.allowedCharacters[$0.offset].filter(\.1).map(\.0)
                                ),
                                ($1.offset, inputs.allowedKarts[$1.offset].filter(\.1).map(\.0)),
                                ($2.offset, inputs.allowedWheels[$2.offset].filter(\.1).map(\.0)),
                                ($3.offset, inputs.allowedGliders[$3.offset].filter(\.1).map(\.0))
                            )
                        }
                    }

                    Button(localization.uiElements.saveFilters) {
                        let saveContents: Data
                        do {
                            saveContents = try saveDataManager.encoder.encode(inputs.toSaveData())
                        } catch {
                            ErrorManager.shared.addError(error)
                            return
                        }
                        onFileSelect = {
                            saveDataManager.writeSaveData(saveContents, to: $0)
                            fileDialogType = .none
                        }
                        fileDialogType = .save
                    }
                }
                .disabled(
                    [
                        inputs.minLandSpeed, inputs.maxLandSpeed, inputs.minWaterSpeed,
                        inputs.maxWaterSpeed, inputs.minAirSpeed, inputs.maxAirSpeed,
                        inputs.minAntigravSpeed, inputs.maxAntigravSpeed, inputs.minAccel,
                        inputs.maxAccel, inputs.minWeight, inputs.maxWeight, inputs.minLandHandling,
                        inputs.maxLandHandling, inputs.minWaterHandling, inputs.maxWaterHandling,
                        inputs.minAirHandling, inputs.maxAirHandling, inputs.minAntigravHandling,
                        inputs.maxAntigravHandling, inputs.minTraction, inputs.maxTraction,
                        inputs.minMiniTurbo, inputs.maxMiniTurbo, inputs.minInvuln,
                        inputs.maxInvuln,
                    ]
                    .contains(nil)
                        || [
                            inputs.landSpeedDirection, inputs.waterSpeedDirection,
                            inputs.airSpeedDirection, inputs.antigravSpeedDirection,
                            inputs.accelDirection, inputs.weightDirection,
                            inputs.landHandlingDirection, inputs.waterHandlingDirection,
                            inputs.airHandlingDirection, inputs.antigravHandlingDirection,
                            inputs.tractionDirection, inputs.miniTurboDirection,
                            inputs.invulnDirection,
                        ]
                        .contains(nil)
                        || !inputs.allowedCharacters.contains { $0.contains(where: \.1) }
                        || !inputs.allowedKarts.contains { $0.contains(where: \.1) }
                        || !inputs.allowedWheels.contains { $0.contains(where: \.1) }
                        || !inputs.allowedGliders.contains { $0.contains(where: \.1) }
                )

                if combos.count > 75 {
                    Text(localization.uiElements.resultsTruncatedWarning)
                }

                ForEach(combos.prefix(75)) { characters, karts, wheels, gliders in
                    Divider()

                    HStack {
                        VStack {
                            ForEach(characters.1) {
                                RemoteImage(src: "\($0).webp")
                            }
                        }

                        VStack {
                            ForEach(karts.1) {
                                RemoteImage(src: "\($0).webp")
                            }
                        }

                        VStack {
                            ForEach(wheels.1) {
                                RemoteImage(src: "\($0).webp")
                            }
                        }

                        VStack {
                            ForEach(gliders.1) {
                                RemoteImage(src: "\($0).webp")
                            }
                        }

                        Button(">") {
                            self.character = .init(name: characters.1[0], index: characters.0)
                            self.kart = .init(name: karts.1[0], index: karts.0)
                            self.wheel = .init(name: wheels.1[0], index: wheels.0)
                            self.glider = .init(name: gliders.1[0], index: gliders.0)
                        }
                    }
                    .fixedSize()
                }
            }
            .onAppear {
                inputs.allowedCharacters = data.characters.map { $0.characters.map { ($0, true) } }
                inputs.allowedKarts = data.karts.map { $0.karts.map { ($0, true) } }
                inputs.allowedWheels = data.wheels.map { $0.wheels.map { ($0, true) } }
                inputs.allowedGliders = data.gliders.map { $0.gliders.map { ($0, true) } }
            }
            .onChange(of: optionsManager.locale, initial: true) {
                formatter.locale = optionsManager.locale
            }
        } else {
            ProgressView()
        }
    }
}
