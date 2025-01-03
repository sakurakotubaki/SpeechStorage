import Speech
import AVFoundation

class SpeechManager: NSObject, ObservableObject {
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()
    
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var errorMessage: String?
    @Published var recordingURL: URL?
    
    override init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
        super.init()
        requestPermissions()
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("音声認識が許可されました")
                case .denied:
                    self?.errorMessage = "音声認識の権限が拒否されています"
                case .restricted:
                    self?.errorMessage = "この端末では音声認識を利用できません"
                case .notDetermined:
                    self?.errorMessage = "音声認識の権限が設定されていません"
                @unknown default:
                    self?.errorMessage = "音声認識の権限状態が不明です"
                }
            }
        }
        
        // マイクの権限も要求
        audioSession.requestRecordPermission { [weak self] allowed in
            DispatchQueue.main.async {
                if !allowed {
                    self?.errorMessage = "マイクの使用が許可されていません"
                }
            }
        }
    }
    
    func startRecording() {
        resetAudio()
        
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "オーディオセッションの設定に失敗しました"
            return
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // 音声ファイルの保存準備
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        recordingURL = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
        
        guard let recordingURL = recordingURL else {
            errorMessage = "録音ファイルの準備に失敗しました"
            return
        }
        
        let audioFile = try? AVAudioFile(forWriting: recordingURL, settings: recordingFormat.settings)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            try? audioFile?.write(from: buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "音声録音の開始に失敗しました"
            resetAudio()
        }
    }
    
    func stopRecording() -> URL? {
        defer {
            resetAudio()
        }
        
        if audioEngine.isRunning {
            audioEngine.stop()
            try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
        
        return recordingURL
    }
    
    private func resetAudio() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        let inputNode = audioEngine.inputNode
        if inputNode.numberOfInputs > 0 {
            inputNode.removeTap(onBus: 0)
        }
        
        isRecording = false
        recordingURL = nil
    }
}

extension AVAudioFormat {
    func toCanonical() -> AVAudioFormat? {
        return AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channelCount)
    }
}
