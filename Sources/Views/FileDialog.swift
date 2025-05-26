import Foundation
import SwiftCrossUI

struct FileDialog: View {
    @State private var optionsManager = OptionsManager.shared
    private var localization: Localization { localizations[optionsManager.locale]! }

    private let saveDataManager = SaveDataManager()
    @State private var files: [SaveDataInfo] = []

    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedFileIndex = -1
    @State private var textFieldInput = ""

    @Binding var show: Bool
    var isSaveDialog: Bool
    var onSelect: (String) -> Void

    private var dateFormatter: DateFormatter

    init(
        show: Binding<Bool>,
        isSaveDialog: Bool,
        onSelect: @escaping (String) -> Void
    ) {
        self._show = show
        self.isSaveDialog = isSaveDialog
        self.onSelect = onSelect

        dateFormatter = DateFormatter()

        dateFormatter.locale = optionsManager.locale

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()

                Button(localization.uiElements.close) {
                    show = false
                }
                .padding()
            }

            Divider()

            ScrollView {
                ForEach(Array(files.enumerated())) { (i, fileData) in
                    if i != 0 {
                        Divider()
                    }

                    HStack {
                        Text(fileData.name)

                        Spacer()

                        if let date = fileData.lastModified {
                            Text(dateFormatter.string(from: date))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .padding()
                    .background(i == selectedFileIndex ? Color.blue.opacity(0.85) : Color.clear)
                    .if(isSaveDialog && !fileData.isWritable) {
                        $0.foregroundColor(.gray)
                    } else: {
                        $0.onTapGesture {
                            if selectedFileIndex == i {
                                selectedFileIndex = -1
                            } else {
                                selectedFileIndex = i
                                textFieldInput = files[i].name
                            }
                        }
                    }
                }
            }
            .aspectRatio(contentMode: .fit)

            Divider()

            HStack {
                if isSaveDialog {
                    TextField(text: $textFieldInput)
                        .onChange(of: textFieldInput, initial: false) {
                            selectedFileIndex = files.firstIndex { $0.name == textFieldInput } ?? -1
                        }

                    Button(localization.uiElements.saveGeneric) {
                        onSelect(textFieldInput)
                    }
                    .disabled(
                        selectedFileIndex < 0
                            ? textFieldInput.isEmpty : !files[selectedFileIndex].isWritable
                    )
                } else {
                    Text(selectedFileIndex < 0 ? "" : files[selectedFileIndex].name)

                    Spacer()

                    Button(localization.uiElements.open) {
                        onSelect(files[selectedFileIndex].name)
                    }
                    .disabled(selectedFileIndex < 0)
                }
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(8)
        .onAppear {
            do {
                files = try saveDataManager.loadFileList()
            } catch {
                ErrorManager.shared.addError(error)
            }
        }
        .frame(maxWidth: 600)
    }
}
