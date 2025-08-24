import SwiftCrossUI

final class ErrorManager: SwiftCrossUI.ObservableObject {
    @SwiftCrossUI.Published
    private var errors = Array<String>()

    private init() {}

    @MainActor
    static let shared = ErrorManager()

    var enumeratedErrors: Array<(index: Int, error: String)> {
        errors.enumerated().map { ($0, $1) }
    }

    func removeError(at index: Int) {
        errors.remove(at: index)
    }

    func addError(_ message: String) { errors.append(message) }
    func addError(_ error: some Error) { errors.append(error.localizedDescription) }

    nonisolated static func addError(_ message: String) {
        Task { @MainActor in
            shared.addError(message)
        }
    }

    nonisolated static func addError(_ error: some Error) {
        Task { @MainActor in
            shared.addError(error)
        }
    }
}
