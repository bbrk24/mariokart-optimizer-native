import SwiftCrossUI

#if canImport(UIKit)
    import UIKit
#endif

@MainActor
struct SplitView<TSidebar: View, TDetail: View>: @preconcurrency View {
    var sidebar: () -> TSidebar
    var detail: () -> TDetail

    init(
        @ViewBuilder sidebar: @escaping () -> TSidebar,
        @ViewBuilder detail: @escaping () -> TDetail
    ) {
        self.sidebar = sidebar
        self.detail = detail
    }

    var body: some View {
        #if canImport(UIKit)
            if UITraitCollection.current.userInterfaceIdiom == .pad {
                NavigationSplitView(sidebar: sidebar, detail: detail)
            } else {
                let window = UIApplication.shared.delegate?.window ?? nil
                Group {
                    VStack(content: sidebar)
                    Divider()
                    VStack(content: detail)
                }
                .if(window == nil || window!.bounds.height > window!.bounds.width) { group in
                    VStack { group }
                } else: { group in
                    HStack { group }
                }
            }
        #else
            NavigationSplitView(sidebar: sidebar, detail: detail)
        #endif
    }
}
