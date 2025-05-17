import SwiftCrossUI 

struct DescriptionAndIndex: Equatable, CustomStringConvertible {
    var description: String
    var index: Int
}

struct KartSelectionPage : View {
    @State var dataManager = GameDataManager.shared
    var data: GameData? { dataManager.data }

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

            ScrollView {
                Group {
                    Spacer()

                    Text("Character")

                    HStack {
                        Picker(of: characters, selection: $character)

                        RemoteImage(src: "\(character?.description ?? "unknown").webp")
                            .frame(maxWidth: 50, maxHeight: 50)
                    }

                    Text("Kart")

                    HStack {
                        Picker(of: karts, selection: $kart)

                        RemoteImage(src: "\(kart?.description ?? "unknown").webp")
                            .frame(maxWidth: 50, maxHeight: 50)
                    }

                    Text("Wheels")

                    HStack {
                        Picker(of: wheels, selection: $wheel)

                        RemoteImage(src: "\(wheel?.description ?? "unknown").webp")
                            .frame(maxWidth: 50, maxHeight: 50)
                    }

                    Text("Glider")

                    HStack {
                        Picker(of: gliders, selection: $glider)

                        RemoteImage(src: "\(glider?.description ?? "unknown").webp")
                            .frame(maxWidth: 50, maxHeight: 50)
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

                        Text("\(characterStats + kartStats + wheelStats + gliderStats)")
                    } else {
                        Text("Select a combination to see its stats here!")
                            .padding()
                    }
                }
                .frame(height: 150)
            }
        } else {
            ProgressView()
        }
    }
}