import SwiftCrossUI 

struct DescriptionAndIndex: Equatable, CustomStringConvertible {
    var description: String
    var index: Int
}

struct KartSelectionPage : View {
    @State private var dataManager = GameDataManager.shared
    private var data: GameData? { dataManager.data }

    @State var character: DescriptionAndIndex?
    @State var kart: DescriptionAndIndex?
    @State var wheel: DescriptionAndIndex?
    @State var glider: DescriptionAndIndex?

    var body: some View {
        if let data {
            let karts = data.karts.enumerated().flatMap { (offset, element) in
                element.karts.map {
                    DescriptionAndIndex(description: $0, index: offset)
                }
            }
            let characters = data.characters.enumerated().flatMap { (offset, element) in
                element.characters.map {
                    DescriptionAndIndex(description: $0, index: offset)
                }
            }
            let wheels = data.wheels.enumerated().flatMap { (offset, element) in
                element.wheels.map {
                    DescriptionAndIndex(description: $0, index: offset)
                }
            }
            let gliders = data.gliders.enumerated().flatMap { (offset, element) in
                element.gliders.map {
                    DescriptionAndIndex(description: $0, index: offset)
                }
            }

            VStack {
                Group {
                    Spacer()

                    Text("Character")

                    HStack {
                        Picker(of: characters, selection: $character)

                        RemoteImage(src: "\(character?.description ?? "unknown").webp")
                    }

                    Text("Kart")

                    HStack {
                        Picker(of: karts, selection: $kart)

                        RemoteImage(src: "\(kart?.description ?? "unknown").webp")
                    }

                    Text("Wheels")

                    HStack {
                        Picker(of: wheels, selection: $wheel)

                        RemoteImage(src: "\(wheel?.description ?? "unknown").webp")
                    }

                    Text("Glider")

                    HStack {
                        Picker(of: gliders, selection: $glider)

                        RemoteImage(src: "\(glider?.description ?? "unknown").webp")
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
                        Text("Select a combination to see its stats here!")
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
