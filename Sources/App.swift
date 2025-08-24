import SwiftCrossUI
import DefaultBackend

enum FileDialogType {
    case load, save, none
}

@main
public struct MKOApp: App {
    @State var character: NameAndIndex?
    @State var kart: NameAndIndex?
    @State var wheel: NameAndIndex?
    @State var glider: NameAndIndex?
    @State var showOptions = false
    @State var errorManager = ErrorManager.shared
    @State var fileDialogType = FileDialogType.none
    @State var onFileSelect: (String) -> Void = { _ in }

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
                                    glider: $glider,
                                    fileDialogType: $fileDialogType,
                                    onFileSelect: $onFileSelect
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

                if fileDialogType != .none {
                    ZStack {
                        Color(0.5, 0.5, 0.5, 0.5)

                        FileDialog(
                            show: Binding(
                                get: { fileDialogType != .none },
                                set: { if !$0 { fileDialogType = .none } }
                            ),
                            isSaveDialog: fileDialogType == .save,
                            onSelect: onFileSelect
                        )
                        .padding()
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
        .windowResizability(.contentMinSize)
    }
}
