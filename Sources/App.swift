import SwiftCrossUI
import DefaultBackend

@main
public struct MKOApp: App {
    @State var character: NameAndIndex?
    @State var kart: NameAndIndex?
    @State var wheel: NameAndIndex?
    @State var glider: NameAndIndex?
    @State var showOptions = false

    @Environment(\.colorScheme) var colorScheme

    public init() {
        Task {
            do {
                try await GameDataManager.shared.loadData()
            } catch {
                print(error)
            }
        }
    }

    public var body: some Scene {
        WindowGroup {
            VStack(alignment: .leading, spacing: 0) {
                Button("Options") {
                    showOptions.toggle()
                }
                .padding()

                Divider()

                ZStack {
                    SplitView {
                        ScrollView {
                            OptimizationPage(
                                character: $character,
                                kart: $kart,
                                wheel: $wheel,
                                glider: $glider
                            )
                            .frame(width: 300)
                            .padding(.horizontal)
                        }
                    } detail: {
                        ScrollView {
                            KartSelectionPage(
                                character: $character,
                                kart: $kart,
                                wheel: $wheel,
                                glider: $glider
                            )
                        }
                    }
                    .frame(minHeight: 375)

                    if showOptions {
                        ZStack {
                            Color(0.5, 0.5, 0.5, 0.5)

                            OptionsPage(show: $showOptions)
                                .frame(maxWidth: 700)
                                .background(colorScheme == .dark ? Color.black : Color.white)
                                .cornerRadius(8)
                                .padding()
                        }
                    }
                }
            }
            .font(.system(size: 16))
        }
    }
}
