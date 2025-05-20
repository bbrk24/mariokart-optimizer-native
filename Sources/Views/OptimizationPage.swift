import SwiftCrossUI
import Foundation

struct OptimizationPage: View {
    @State private var dataManager = GameDataManager.shared
    private var data: GameData? { dataManager.data }

    @Binding var character: DescriptionAndIndex?
    @Binding var kart: DescriptionAndIndex?
    @Binding var wheel: DescriptionAndIndex?
    @Binding var glider: DescriptionAndIndex?

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

    @State private var combos: [(Int, Int, Int, Int)] = []

    private let formatter = FloatingPointFormatStyle<Float>()
        .precision(.integerAndFractionLength(integerLimits: 1..<2, fractionLimits: 0...2))
    
    @ViewBuilder
    private func inputRow(
        label: String,
        min: Binding<Float?>,
        max: Binding<Float?>
    ) -> some View {
        Text(label)

        HStack {
            FloatInput(
                min: 0.75,
                max: max.wrappedValue ?? 5.75,
                value: min,
                formatter: formatter
            )
            
            FloatInput(
                min: min.wrappedValue ?? 0.75,
                max: 5.75,
                value: max,
                formatter: formatter
            )
        }
    }

    var body: some View {
        if let data {
            VStack {
                Group {
                    Group {
                        inputRow(label: "Speed", min: $minLandSpeed, max: $maxLandSpeed)
                        inputRow(label: "Water speed", min: $minWaterSpeed, max: $maxWaterSpeed)
                        inputRow(label: "Glider speed", min: $minAirSpeed, max: $maxAirSpeed)
                        inputRow(label: "Antigravity speed", min: $minAntigravSpeed, max: $maxAntigravSpeed)
                    }

                    inputRow(label: "Acceleration", min: $minAccel, max: $maxAccel)
                    inputRow(label: "Weight", min: $minWeight, max: $maxWeight)
                    
                    Group {
                        inputRow(label: "Handling", min: $minLandHandling, max: $maxLandHandling)
                        inputRow(label: "Water Handling", min: $minWaterHandling, max: $maxWaterHandling)
                        inputRow(label: "Glider Handling", min: $minAirHandling, max: $maxAirHandling)
                        inputRow(label: "Antigravity Handling", min: $minAntigravHandling, max: $maxAntigravHandling)
                    }

                    inputRow(label: "Traction", min: $minTraction, max: $maxTraction)
                    inputRow(label: "Mini-Turbo", min: $minMiniTurbo, max: $maxMiniTurbo)
                    inputRow(label: "Invincibility", min: $minInvuln, max: $maxInvuln)
                }

                Button("Go!") {
                    combos = fourWayProduct(
                        Array(data.characters.enumerated()),
                        Array(data.karts.enumerated()),
                        Array(data.wheels.enumerated()),
                        Array(data.gliders.enumerated())
                    ).filter { character, kart, wheel, glider in
                        let statTotal = character.element + kart.element + wheel.element + glider.element
                        return (minLandSpeed! ... maxLandSpeed!).contains(statTotal.speed.land)
                            && (minWaterSpeed! ... maxWaterSpeed!).contains(statTotal.speed.water)
                            && (minAirSpeed! ... maxAirSpeed!).contains(statTotal.speed.air)
                            && (minAntigravSpeed! ... maxAntigravSpeed!).contains(statTotal.speed.antigrav)
                            && (minAccel! ... maxAccel!).contains(statTotal.accel)
                            && (minWeight! ... maxWeight!).contains(statTotal.weight)
                            && (minLandHandling! ... maxLandHandling!).contains(statTotal.handling.land)
                            && (minWaterHandling! ... maxWaterHandling!).contains(statTotal.handling.water)
                            && (minAirHandling! ... maxAirHandling!).contains(statTotal.handling.air)
                            && (minAntigravHandling! ... maxAntigravHandling!).contains(statTotal.handling.antigrav)
                            && (minTraction! ... maxTraction!).contains(statTotal.traction)
                            && (minMiniTurbo! ... maxMiniTurbo!).contains(statTotal.miniTurbo)
                            && (minInvuln! ... maxInvuln!).contains(statTotal.invuln)
                    }.map {
                        ($0.offset, $1.offset, $2.offset, $3.offset)
                    }
                }
                .disabled(
                    [minLandSpeed, maxLandSpeed, minWaterSpeed, maxWaterSpeed, minAirSpeed, maxAirSpeed, minAntigravSpeed, maxAntigravSpeed, minAccel, maxAccel, minWeight, maxWeight, minLandHandling, maxLandHandling, minWaterHandling, maxWaterHandling, minAirHandling, maxAirHandling, minAntigravHandling, maxAntigravHandling, minTraction, maxTraction, minMiniTurbo, maxMiniTurbo, minInvuln, maxInvuln]
                        .contains(nil)
                )

                if combos.count > 50 {
                    Text("Results have been truncated for performance reasons.")
                }

                ForEach(combos.prefix(50)) { characterIndex, kartIndex, wheelIndex, gliderIndex in
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
                            self.character = .init(description: data.characters[characterIndex].characters[0], index: characterIndex)
                            self.kart = .init(description: data.karts[kartIndex].karts[0], index: kartIndex)
                            self.wheel = .init(description: data.wheels[wheelIndex].wheels[0], index: wheelIndex)
                            self.glider = .init(description: data.gliders[gliderIndex].gliders[0], index: gliderIndex)
                        }
                    }
                }
            }
        } else {
            ProgressView()
        }
    }
}