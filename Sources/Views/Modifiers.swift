import SwiftCrossUI

extension View {
    func apply<T: View>(@ViewBuilder body: (Self) -> T) -> T {
        body(self)
    }

    @ViewBuilder
    func `if`(
        _ condition: Bool,
        @ViewBuilder then ifTrue: (Self) -> some View,
        @ViewBuilder else ifFalse: (Self) -> some View
    ) -> some View {
        if condition {
            ifTrue(self)
        } else {
            ifFalse(self)
        }
    }
}
