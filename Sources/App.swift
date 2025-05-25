import SwiftCrossUI
import DefaultBackend

@MainActor
@main
public struct MKOApp: @preconcurrency App {
    @State var character: NameAndIndex?
    @State var kart: NameAndIndex?
    @State var wheel: NameAndIndex?
    @State var glider: NameAndIndex?
    @State var showOptions = false
    @State var errorManager = ErrorManager.shared

    @Environment(\.colorScheme) var colorScheme

    public init() {
        Task { [self] in
            do {
                try await GameDataManager.shared.loadData()
            } catch {
                errorManager.addError(
                    (GameDataManager.shared.data == nil ? "Cannot load game data: " : "")
                        + error.localizedDescription
                )
            }
        }
    }

    public var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    Button("Options") {
                        showOptions.toggle()
                    }
                    .padding()

                    Divider()

                    ZStack {
                        NavigationSplitView {
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

                VStack {
                    ForEach(errorManager.enumeratedErrors) { i, error in
                        ErrorToast(text: error)
                            .onTapGesture {
                                errorManager.removeError(at: i)
                            }
                            .padding()
                    }
                }
            }
            .font(.system(size: 16))
        }
    }
}
