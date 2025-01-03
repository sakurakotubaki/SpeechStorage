import SwiftUI
import SwiftData

struct TextInputView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var themeManager: ThemeManager
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    @FocusState private var isFocused: Bool
    
    @State private var inputText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $inputText)
                    .focused($isFocused)
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Button(action: saveText) {
                    Text("保存")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme)
                        .cornerRadius(8)
                }
                .disabled(inputText.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("テキスト入力")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("閉じる") {
                        isFocused = false
                    }
                }
            }
        }
    }
    
    private func saveText() {
        guard !inputText.isEmpty else { return }
        
        let memo = VoiceMemo(
            text: inputText,
            themeColor: themeManager.currentTheme.toHex() ?? "#000000"
        )
        
        modelContext.insert(memo)
        
        // リセットと通知
        inputText = ""
        showToast = true
        toastMessage = "保存しました"
        isFocused = false  // 保存時にキーボードを閉じる
    }
}
