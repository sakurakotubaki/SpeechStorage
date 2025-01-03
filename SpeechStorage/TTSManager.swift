import AVFoundation
import SwiftUI

class TTSManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = TTSManager()
    
    @Published var isPlaying = false
    @Published var currentText: String?
    
    private let synthesizer = AVSpeechSynthesizer()
    private let audioSession = AVAudioSession.sharedInstance()
    
    private override init() {
        super.init()
        synthesizer.delegate = self
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            // アプリ起動時は非アクティブにしておく
            try audioSession.setCategory(.playback, mode: .spokenAudio)
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("オーディオセッションの初期設定エラー: \(error.localizedDescription)")
        }
    }
    
    func speak(_ text: String) {
        do {
            // 既に再生中なら停止
            if isPlaying {
                stopSpeaking()
            }
            
            // セッションをアクティブ化
            if !audioSession.isOtherAudioPlaying {
                try audioSession.setActive(true, options: [])
            }
            
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0
            
            synthesizer.speak(utterance)
            isPlaying = true
            currentText = text
        } catch {
            print("音声再生の開始エラー: \(error.localizedDescription)")
            isPlaying = false
            currentText = nil
        }
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        currentText = nil
        
        do {
            if !audioSession.isOtherAudioPlaying {
                try audioSession.setActive(false, options: [])
            }
        } catch {
            print("オーディオセッションの終了エラー: \(error.localizedDescription)")
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isPlaying = false
            self.currentText = nil
            
            do {
                if !self.audioSession.isOtherAudioPlaying {
                    try self.audioSession.setActive(false, options: [])
                }
            } catch {
                print("オーディオセッションの終了エラー: \(error.localizedDescription)")
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.currentText = nil
        }
    }
}
