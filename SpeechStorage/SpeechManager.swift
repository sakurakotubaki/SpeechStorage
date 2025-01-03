import Speech
import AVFoundation

class SpeechManager: NSObject, ObservableObject {
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var errorMessage: String?
    
    override init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
        super.init()
        
        // 初期化時にオーディオセッションを設定
        setupAudioSession()
        requestPermissions()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setPreferredIOBufferDuration(0.005)
        } catch {
            print("オーディオセッションの初期設定エラー: \(error)")
        }
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
    }
    
    func startRecording() {
        // 既存のタスクをクリーンアップ
        resetAudio()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "オーディオセッションの設定に失敗しました"
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest,
              let recognitionFormat = inputNode.outputFormat(forBus: 0).toCanonical() else {
            errorMessage = "音声認識の準備に失敗しました"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.stopRecording()
            }
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recognitionFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
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
    
    func stopRecording() {
        defer {
            isRecording = false
        }
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            // オーディオセッションを適切に終了
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("オーディオセッションの終了に失敗: \(error)")
            }
        }
    }
    
    private func resetAudio() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // 既存のタップを安全に削除
        let inputNode = audioEngine.inputNode
        if inputNode.numberOfInputs > 0 {
            inputNode.removeTap(onBus: 0)
        }
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isRecording = false
    }
}

extension AVAudioFormat {
    func toCanonical() -> AVAudioFormat? {
        return AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channelCount)
    }
}
