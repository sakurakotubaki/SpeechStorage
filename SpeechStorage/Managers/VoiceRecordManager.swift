import Foundation
import Speech
import AVFoundation
import SwiftData

@MainActor
class VoiceRecordManager: ObservableObject {
    private let audioSession = AVAudioSession.sharedInstance()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var errorMessage: String?
    
    init() {
        // 初期化時は特別な設定は行わない
        print("VoiceRecordManager initialized")
    }
    
    private func configureSessionForRecording() throws {
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func configureSessionForPlayback() throws {
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    func requestPermissions() async -> Bool {
        var hasPermission = false
        
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        
        let audioStatus = await withCheckedContinuation { continuation in
            audioSession.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        
        hasPermission = speechStatus == .authorized && audioStatus
        return hasPermission
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        do {
            // 既存のタスクをリセット
            recognitionTask?.cancel()
            recognitionTask = nil
            recognitionRequest = nil
            recognizedText = ""
            
            // 録音用にセッションを設定
            try configureSessionForRecording()
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest else {
                throw NSError(domain: "VoiceRecordManager", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "認識リクエストの作成に失敗しました"])
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self else { return }
                
                if let result {
                    self.recognizedText = result.bestTranscription.formattedString
                }
                
                if error != nil {
                    self.stopRecording()
                    self.errorMessage = "音声認識エラーが発生しました"
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
            
        } catch {
            errorMessage = "録音の開始に失敗しました: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        do {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
            
            isRecording = false
            
            // クリーンアップ
            recognitionRequest = nil
            recognitionTask = nil
            
            // 停止時はセッションを非アクティブにする
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "録音の停止に失敗しました: \(error.localizedDescription)"
        }
    }
    
    func saveVoiceMemo(modelContext: ModelContext) {
        guard !recognizedText.isEmpty else { return }
        
        let memo = VoiceMemo(text: recognizedText)
        modelContext.insert(memo)
        
        recognizedText = ""
    }
}
