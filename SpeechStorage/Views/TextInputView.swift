import SwiftUI
import SwiftData
import DotLottie
import Speech

struct TextInputView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var themeManager: ThemeManager
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    @FocusState private var isFocused: Bool
    
    @StateObject private var speechRecognizer = SpeechRecognitionManager()
    @State private var inputText = ""
    @State private var isTextMode = true
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 15) {
                        // Animation with adaptive sizing
                        DotLottieAnimation(
                            fileName: "think",
                            config: AnimationConfig(
                                autoplay: true,
                                loop: true,
                                speed: 1.0
                            )
                        )
                        .view()
                        .frame(
                            width: min(geometry.size.width * 0.5, 180),
                            height: min(geometry.size.width * 0.5, 180)
                        )
                        .padding(.top)
                        
                        if isTextMode {
                            // テキスト入力モード
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $inputText)
                                    .focused($isFocused)
                                    .frame(height: min(geometry.size.height * 0.3, 200))
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                
                                if inputText.isEmpty {
                                    Text("考えていることを書こう")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                }
                            }
                        } else {
                            // 音声入力モード
                            VStack(spacing: 10) {
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $speechRecognizer.recognizedText)
                                        .frame(height: min(geometry.size.height * 0.25, 180))
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                        .disabled(true)
                                    
                                    if speechRecognizer.recognizedText.isEmpty {
                                        Text("マイクボタンを押して話してください")
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 16)
                                    }
                                }
                                
                                HStack {
                                    Spacer()
                                    Button(action: toggleRecording) {
                                        Image(systemName: speechRecognizer.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: min(geometry.size.width * 0.15, 60), height: min(geometry.size.width * 0.15, 60))
                                            .foregroundColor(speechRecognizer.isRecording ? .red : themeManager.currentTheme)
                                    }
                                    .disabled(!speechRecognizer.isPermissionGranted)
                                    Spacer()
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        
                        Button(action: saveContent) {
                            Text("保存")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isContentEmpty ? Color.gray : themeManager.currentTheme)
                                .cornerRadius(8)
                        }
                        .disabled(isContentEmpty)
                        .padding(.bottom, geometry.size.height * 0.05 + 40) // Add extra bottom padding to avoid TabView overlap
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $isTextMode) {
                        Image(systemName: isTextMode ? "keyboard" : "mic")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: themeManager.currentTheme))
                    .onChange(of: isTextMode) { _, newValue in
                        if !newValue && speechRecognizer.isRecording {
                            speechRecognizer.stopRecording()
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("閉じる") {
                        isFocused = false
                    }
                }
            }
        }
        .alert("マイクの権限が必要です", isPresented: .constant(!speechRecognizer.isPermissionGranted && !isTextMode)) {
            Button("設定を開く") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("キャンセル") {
                isTextMode = true
            }
        } message: {
            Text("音声認識を使用するにはマイクへのアクセスを許可してください。")
        }
    }
    
    private var isContentEmpty: Bool {
        if isTextMode {
            return inputText.isEmpty
        } else {
            return speechRecognizer.recognizedText.isEmpty
        }
    }
    
    private func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        } else {
            do {
                try speechRecognizer.startRecording()
            } catch {
                showToast = true
                toastMessage = "音声認識の開始に失敗しました"
            }
        }
    }
    
    private func saveContent() {
        let textToSave: String
        let speechType: SpeechType
        
        if isTextMode {
            guard !inputText.isEmpty else { return }
            textToSave = inputText
            speechType = .text(inputText)
        } else {
            guard !speechRecognizer.recognizedText.isEmpty else { return }
            textToSave = speechRecognizer.recognizedText
            speechType = .speech(speechRecognizer.recognizedText)
        }
        
        let memo = VoiceMemo(
            text: textToSave,
            themeColor: themeManager.currentTheme.toHex() ?? "#000000",
            isFromSpeech: !isTextMode
        )
        
        modelContext.insert(memo)
        do {
            try modelContext.save()
            // リセットと通知
            if isTextMode {
                inputText = ""
            } else {
                speechRecognizer.recognizedText = ""
            }
            showToast = true
            toastMessage = "保存しました"
            isFocused = false  // 保存時にキーボードを閉じる
        } catch {
            print("Error saving memo: \(error)")
            showToast = true
            toastMessage = "保存に失敗しました"
        }
    }
}
