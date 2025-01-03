import SwiftUI
import SwiftData

struct VoiceRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var recordManager = VoiceRecordManager()
    @State private var showingPermissionAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 録音状態表示
            if recordManager.isRecording {
                Text("録音中...")
                    .foregroundColor(.red)
                    .bold()
            }
            
            // 認識テキスト表示エリア
            Text(recordManager.recognizedText)
                .frame(maxWidth: .infinity, minHeight: 100)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            // 録音コントロールボタン
            Button(action: {
                if recordManager.isRecording {
                    recordManager.stopRecording()
                } else {
                    recordManager.startRecording()
                }
            }) {
                Image(systemName: recordManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(recordManager.isRecording ? .red : .blue)
            }
            
            // 保存ボタン
            if !recordManager.recognizedText.isEmpty {
                Button("保存") {
                    recordManager.saveVoiceMemo(modelContext: modelContext)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .alert("エラー", isPresented: .constant(recordManager.errorMessage != nil)) {
            Button("OK") {
                recordManager.errorMessage = nil
            }
        } message: {
            Text(recordManager.errorMessage ?? "")
        }
        .task {
            let hasPermission = await recordManager.requestPermissions()
            showingPermissionAlert = !hasPermission
        }
        .alert("権限が必要です", isPresented: $showingPermissionAlert) {
            Button("OK") { }
        } message: {
            Text("音声認識とマイクの使用権限を許可してください。")
        }
    }
}

#Preview {
    VoiceRecordView()
        .modelContainer(for: VoiceMemo.self, inMemory: true)
}
