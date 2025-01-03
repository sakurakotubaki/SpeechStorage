import AVFoundation
import SwiftUI

class TTSManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = TTSManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    @Published var isPlaying = false
    @Published var currentText = ""
    
    private override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(_ text: String) {
        stopSpeaking()
        
        // オーディオセッションの設定
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("オーディオセッションの設定エラー: \(error)")
            return
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        currentText = text
        isPlaying = true
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            
            // オーディオセッションを非アクティブに
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("オーディオセッションの終了エラー: \(error)")
            }
        }
        isPlaying = false
    }
    
    // AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPlaying = false
            // 再生終了時にオーディオセッションを非アクティブに
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("オーディオセッションの終了エラー: \(error)")
            }
        }
    }
}
