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
            ScrollView {
                KartSelectionPage()
            }
                .frame(minWidth: 375, minHeight: 375)
                .font(.system(size: 16))
        }
    }
}
