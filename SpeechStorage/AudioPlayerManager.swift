import AVFoundation

class AudioPlayerManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = AudioPlayerManager()
    
    private let synthesizer: AVSpeechSynthesizer
    @Published var playingMemoId: String?
    
    override init() {
        synthesizer = AVSpeechSynthesizer()
        super.init()
        synthesizer.delegate = self
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    func playText(_ text: String, memoId: String) {
        // 同じメモを再生中なら停止
        if playingMemoId == memoId {
            stopPlaying()
            return
        }
        
        // 他のメモを再生中なら停止
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // 再生用のオーディオセッションを設定
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup playback session: \(error)")
            return
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        playingMemoId = memoId
        synthesizer.speak(utterance)
    }
    
    func stopPlaying() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        playingMemoId = nil
    }
    
    // AVSpeechSynthesizerDelegate methods
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.playingMemoId = nil
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.playingMemoId = nil
        }
    }
}
