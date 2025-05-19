import SwiftCrossUI
import DefaultBackend

@main
public struct MKOApp: App {
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
            SplitView {
                ScrollView {
                    OptimizationPage()
                        .frame(width: 306)
                        .padding(.horizontal)
                }
            } detail: {
                ScrollView {
                    KartSelectionPage()
                }
            }
            .frame(minHeight: 375)
            .font(.system(size: 16))
        }
    }
}
