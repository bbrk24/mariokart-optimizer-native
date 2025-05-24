import SwiftCrossUI
import Foundation

enum OptimizeDirection: CaseIterable, Equatable, CustomStringConvertible {
    case dont, min, max

    var description: String {
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
}

@MainActor
struct OptimizationPage: @preconcurrency View {
    @State private var optionsManager = OptionsManager.shared
    @State private var dataManager = GameDataManager.shared

    @Binding var character: NameAndIndex?
    @Binding var kart: NameAndIndex?
    @Binding var wheel: NameAndIndex?
    @Binding var glider: NameAndIndex?

    @State private var inputs = OptimizerState()

    private var localization: Localization { localizations[optionsManager.locale]! }
    private var data: GameData? { dataManager.data }

    @State private var combos: [(Int, Int, Int, Int)] = []

    private let formatter = FloatingPointFormatStyle<Float>()
        .precision(.integerAndFractionLength(integerLimits: 1..<2, fractionLimits: 0...2))

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
                            direction: $inputs.antigravSpeedDirection
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

                Button(localization.uiElements.go) {
                    combos = fourWayProduct(
                        Array(data.characters.enumerated()),
                        Array(data.karts.enumerated()),
                        Array(data.wheels.enumerated()),
                        Array(data.gliders.enumerated())
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
                            && (inputs.minWeight!...inputs.maxWeight!).contains(statTotal.weight)
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
                            && (inputs.minInvuln!...inputs.maxInvuln!).contains(statTotal.invuln)
                    }
                    .maxAll { character, kart, wheel, glider in
                        let statTotal =
                            character.element + kart.element + wheel.element + glider.element
                        return
                            (inputs.landSpeedDirection!.multiplier * statTotal.speed.land
                            + inputs.waterSpeedDirection!.multiplier * statTotal.speed.water
                            + inputs.airSpeedDirection!.multiplier * statTotal.speed.air
                            + inputs.antigravSpeedDirection!.multiplier * statTotal.speed.antigrav)
                            / 4.0
                            + inputs.accelDirection!.multiplier * statTotal.accel
                            + inputs.weightDirection!.multiplier * statTotal.weight
                            + (inputs.landHandlingDirection!.multiplier * statTotal.handling.land
                                + inputs.waterHandlingDirection!.multiplier
                                * statTotal.handling.water
                                + inputs.airHandlingDirection!.multiplier * statTotal.handling.air
                                + inputs.antigravHandlingDirection!.multiplier
                                * statTotal.handling.antigrav) / 4.0
                            + inputs.tractionDirection!.multiplier * statTotal.traction
                            + inputs.miniTurboDirection!.multiplier * statTotal.miniTurbo
                            + inputs.invulnDirection!.multiplier * statTotal.invuln
                    }
                    .map { ($0.offset, $1.offset, $2.offset, $3.offset) }
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
                )

                if combos.count > 75 {
                    Text(localization.uiElements.resultsTruncatedWarning)
                }

                ForEach(combos.prefix(75)) { characterIndex, kartIndex, wheelIndex, gliderIndex in
                    Divider()

                    HStack {
                        VStack {
                            ForEach(data.characters[characterIndex].characters) {
                                RemoteImage(src: "\($0).webp")
                            }
                        }

                        VStack {
                            ForEach(data.karts[kartIndex].karts) {
                                RemoteImage(src: "\($0).webp")
                            }
                        }

                        VStack {
                            ForEach(data.wheels[wheelIndex].wheels) {
                                RemoteImage(src: "\($0).webp")
                            }
                        }

                        VStack {
                            ForEach(data.gliders[gliderIndex].gliders) {
                                RemoteImage(src: "\($0).webp")
                            }
                        }

                        Button(">") {
                            self.character = .init(
                                name: data.characters[characterIndex].characters[0],
                                index: characterIndex
                            )
                            self.kart = .init(
                                name: data.karts[kartIndex].karts[0],
                                index: kartIndex
                            )
                            self.wheel = .init(
                                name: data.wheels[wheelIndex].wheels[0],
                                index: wheelIndex
                            )
                            self.glider = .init(
                                name: data.gliders[gliderIndex].gliders[0],
                                index: gliderIndex
                            )
                        }
                    }
                    .fixedSize()
                }
            }
        } else {
            ProgressView()
        }
    }
}
