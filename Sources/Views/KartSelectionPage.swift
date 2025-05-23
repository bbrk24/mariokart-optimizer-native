import SwiftCrossUI

struct NameAndIndex: Equatable, CustomStringConvertible {
    var name: String
    var index: Int

    var description: String {
        localizations[OptionsManager.shared.locale]!.kartParts[name] ?? name
    }
}

@MainActor
struct KartSelectionPage: @preconcurrency View {
    @State private var optionsManager = OptionsManager.shared
    @State private var dataManager = GameDataManager.shared

    @Binding var character: NameAndIndex?
    @Binding var kart: NameAndIndex?
    @Binding var wheel: NameAndIndex?
    @Binding var glider: NameAndIndex?

    private var localization: Localization { localizations[optionsManager.locale]! }
    private var data: GameData? { dataManager.data }

    var body: some View {
        if let data {
            let karts = data.karts.enumerated()
                .flatMap { (offset, element) in
                    element.karts.map { NameAndIndex(name: $0, index: offset) }
                }
            let characters = data.characters.enumerated()
                .flatMap { (offset, element) in
                    element.characters.map { NameAndIndex(name: $0, index: offset) }
                }
            let wheels = data.wheels.enumerated()
                .flatMap { (offset, element) in
                    element.wheels.map { NameAndIndex(name: $0, index: offset) }
                }
            let gliders = data.gliders.enumerated()
                .flatMap { (offset, element) in
                    element.gliders.map { NameAndIndex(name: $0, index: offset) }
                }

            VStack {
                Group {
                    Spacer()

                    Text(localization.uiElements.character)

                    HStack {
                        Picker(of: characters, selection: _character)

                        RemoteImage(src: "\(character?.name ?? "unknown").webp")
                    }

                    Text(localization.uiElements.kart)

                    HStack {
                        Picker(of: karts, selection: _kart)

                        RemoteImage(src: "\(kart?.name ?? "unknown").webp")
                    }

                    Text(localization.uiElements.wheel)

                    HStack {
                        Picker(of: wheels, selection: _wheel)

                        RemoteImage(src: "\(wheel?.name ?? "unknown").webp")
                    }

                    Text(localization.uiElements.glider)

                    HStack {
                        Picker(of: gliders, selection: _glider)

                        RemoteImage(src: "\(glider?.name ?? "unknown").webp")
                    }

                    Spacer()
                }

                Divider()

                Group {
                    if let character, let kart, let wheel, let glider {
                        let characterStats = data.characters[character.index]
                        let kartStats = data.karts[kart.index]
                        let wheelStats = data.wheels[wheel.index]
                        let gliderStats = data.gliders[glider.index]

                        let totalStats = characterStats + kartStats + wheelStats + gliderStats

                        ForEach(totalStats.labelledStats) {
                            Meter(statName: $0, width: $1)
                                .frame(maxWidth: 320)
                        }
                    } else {
                        Text(localization.uiElements.statsPlaceholder)
                    }
                }
                .frame(height: 800)
                .padding()
            }
        } else {
            ProgressView()
        }
    }
}
