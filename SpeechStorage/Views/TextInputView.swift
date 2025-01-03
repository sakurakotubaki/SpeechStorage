import SwiftUI
import SwiftData
import DotLottie

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
                DotLottieAnimation(
                            fileName: "think",
                            config: AnimationConfig(
                                autoplay: true,
                                loop: true,
                                speed: 1.0
                            )
                        )
                        .view()
                        .frame(width: 200, height: 200)
                
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
            .navigationTitle("考えていることを書こう")
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
