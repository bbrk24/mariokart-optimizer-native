import SwiftCrossUI
import Foundation

enum OptimizeDirection: CaseIterable, Equatable, CustomStringConvertible {
    case dont, min, max

    var description: String {
        switch self {
        case .dont: "Don't optimize"
        case .min: "Minimize"
        case .max: "Maximize"
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

@MainActor
struct OptimizationPage: @preconcurrency View {
    @State private var optionsManager = OptionsManager.shared
    @State private var dataManager = GameDataManager.shared

    @Binding var character: NameAndIndex?
    @Binding var kart: NameAndIndex?
    @Binding var wheel: NameAndIndex?
    @Binding var glider: NameAndIndex?

    @State private var minLandSpeed: Float? = 0.75
    @State private var maxLandSpeed: Float? = 5.75
    @State private var minWaterSpeed: Float? = 0.75
    @State private var maxWaterSpeed: Float? = 5.75
    @State private var minAirSpeed: Float? = 0.75
    @State private var maxAirSpeed: Float? = 5.75
    @State private var minAntigravSpeed: Float? = 0.75
    @State private var maxAntigravSpeed: Float? = 5.75
    @State private var minAccel: Float? = 0.75
    @State private var maxAccel: Float? = 5.75
    @State private var minWeight: Float? = 0.75
    @State private var maxWeight: Float? = 5.75
    @State private var minLandHandling: Float? = 0.75
    @State private var maxLandHandling: Float? = 5.75
    @State private var minWaterHandling: Float? = 0.75
    @State private var maxWaterHandling: Float? = 5.75
    @State private var minAirHandling: Float? = 0.75
    @State private var maxAirHandling: Float? = 5.75
    @State private var minAntigravHandling: Float? = 0.75
    @State private var maxAntigravHandling: Float? = 5.75
    @State private var minTraction: Float? = 0.75
    @State private var maxTraction: Float? = 5.75
    @State private var minMiniTurbo: Float? = 0.75
    @State private var maxMiniTurbo: Float? = 5.75
    @State private var minInvuln: Float? = 0.75
    @State private var maxInvuln: Float? = 5.75

    @State private var landSpeedDirection: OptimizeDirection? = .dont
    @State private var waterSpeedDirection: OptimizeDirection? = .dont
    @State private var airSpeedDirection: OptimizeDirection? = .dont
    @State private var antigravSpeedDirection: OptimizeDirection? = .dont
    @State private var accelDirection: OptimizeDirection? = .dont
    @State private var weightDirection: OptimizeDirection? = .dont
    @State private var landHandlingDirection: OptimizeDirection? = .dont
    @State private var waterHandlingDirection: OptimizeDirection? = .dont
    @State private var airHandlingDirection: OptimizeDirection? = .dont
    @State private var antigravHandlingDirection: OptimizeDirection? = .dont
    @State private var tractionDirection: OptimizeDirection? = .dont
    @State private var miniTurboDirection: OptimizeDirection? = .dont
    @State private var invulnDirection: OptimizeDirection? = .dont

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
                            min: $minLandSpeed,
                            max: $maxLandSpeed,
                            direction: $landSpeedDirection
                        )
                        inputRow(
                            label: localization.stats.waterSpeed,
                            min: $minWaterSpeed,
                            max: $maxWaterSpeed,
                            direction: $waterSpeedDirection
                        )
                        inputRow(
                            label: localization.stats.airSpeed,
                            min: $minAirSpeed,
                            max: $maxAirSpeed,
                            direction: $airSpeedDirection
                        )
                        inputRow(
                            label: localization.stats.antigravSpeed,
                            min: $minAntigravSpeed,
                            max: $maxAntigravSpeed,
                            direction: $antigravSpeedDirection
                        )
                    }

                    inputRow(
                        label: localization.stats.accel,
                        min: $minAccel,
                        max: $maxAccel,
                        direction: $accelDirection
                    )
                    inputRow(
                        label: localization.stats.weight,
                        min: $minWeight,
                        max: $maxWeight,
                        direction: $weightDirection
                    )

                    Group {
                        inputRow(
                            label: localization.stats.landHandling,
                            min: $minLandHandling,
                            max: $maxLandHandling,
                            direction: $landHandlingDirection
                        )
                        inputRow(
                            label: localization.stats.waterHandling,
                            min: $minWaterHandling,
                            max: $maxWaterHandling,
                            direction: $waterHandlingDirection
                        )
                        inputRow(
                            label: localization.stats.airHandling,
                            min: $minAirHandling,
                            max: $maxAirHandling,
                            direction: $airHandlingDirection
                        )
                        inputRow(
                            label: localization.stats.antigravHandling,
                            min: $minAntigravHandling,
                            max: $maxAntigravHandling,
                            direction: $antigravSpeedDirection
                        )
                    }

                    inputRow(
                        label: localization.stats.traction,
                        min: $minTraction,
                        max: $maxTraction,
                        direction: $tractionDirection
                    )
                    inputRow(
                        label: localization.stats.miniTurbo,
                        min: $minMiniTurbo,
                        max: $maxMiniTurbo,
                        direction: $miniTurboDirection
                    )
                    inputRow(
                        label: localization.stats.invuln,
                        min: $minInvuln,
                        max: $maxInvuln,
                        direction: $invulnDirection
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
                        return (minLandSpeed!...maxLandSpeed!).contains(statTotal.speed.land)
                            && (minWaterSpeed!...maxWaterSpeed!).contains(statTotal.speed.water)
                            && (minAirSpeed!...maxAirSpeed!).contains(statTotal.speed.air)
                            && (minAntigravSpeed!...maxAntigravSpeed!)
                                .contains(statTotal.speed.antigrav)
                            && (minAccel!...maxAccel!).contains(statTotal.accel)
                            && (minWeight!...maxWeight!).contains(statTotal.weight)
                            && (minLandHandling!...maxLandHandling!)
                                .contains(statTotal.handling.land)
                            && (minWaterHandling!...maxWaterHandling!)
                                .contains(statTotal.handling.water)
                            && (minAirHandling!...maxAirHandling!).contains(statTotal.handling.air)
                            && (minAntigravHandling!...maxAntigravHandling!)
                                .contains(statTotal.handling.antigrav)
                            && (minTraction!...maxTraction!).contains(statTotal.traction)
                            && (minMiniTurbo!...maxMiniTurbo!).contains(statTotal.miniTurbo)
                            && (minInvuln!...maxInvuln!).contains(statTotal.invuln)
                    }
                    .maxAll { character, kart, wheel, glider in
                        let statTotal =
                            character.element + kart.element + wheel.element + glider.element
                        return
                            (landSpeedDirection!.multiplier * statTotal.speed.land
                            + waterSpeedDirection!.multiplier * statTotal.speed.water
                            + airSpeedDirection!.multiplier * statTotal.speed.air
                            + antigravSpeedDirection!.multiplier * statTotal.speed.antigrav) / 4.0
                            + accelDirection!.multiplier * statTotal.accel
                            + weightDirection!.multiplier * statTotal.weight
                            + (landHandlingDirection!.multiplier * statTotal.handling.land
                                + waterHandlingDirection!.multiplier * statTotal.handling.water
                                + airHandlingDirection!.multiplier * statTotal.handling.air
                                + antigravHandlingDirection!.multiplier
                                * statTotal.handling.antigrav) / 4.0
                            + tractionDirection!.multiplier * statTotal.traction
                            + miniTurboDirection!.multiplier * statTotal.miniTurbo
                            + invulnDirection!.multiplier * statTotal.invuln
                    }
                    .map { ($0.offset, $1.offset, $2.offset, $3.offset) }
                }
                .disabled(
                    [
                        minLandSpeed, maxLandSpeed, minWaterSpeed, maxWaterSpeed, minAirSpeed,
                        maxAirSpeed, minAntigravSpeed, maxAntigravSpeed, minAccel, maxAccel,
                        minWeight, maxWeight, minLandHandling, maxLandHandling, minWaterHandling,
                        maxWaterHandling, minAirHandling, maxAirHandling, minAntigravHandling,
                        maxAntigravHandling, minTraction, maxTraction, minMiniTurbo, maxMiniTurbo,
                        minInvuln, maxInvuln,
                    ]
                    .contains(nil)
                        || [
                            landSpeedDirection, waterSpeedDirection, airSpeedDirection,
                            antigravSpeedDirection, accelDirection, weightDirection,
                            landHandlingDirection, waterHandlingDirection, airHandlingDirection,
                            antigravHandlingDirection, tractionDirection, miniTurboDirection,
                            invulnDirection,
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
