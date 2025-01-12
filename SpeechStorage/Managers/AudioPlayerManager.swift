import Foundation
import AVFoundation

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerManager()
    
    @Published var isPlaying = false
    @Published var currentMemoId: UUID?
    
    private var audioPlayer: AVAudioPlayer?
    private let audioSession = AVAudioSession.sharedInstance()
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
        } catch {
            print("オーディオセッションの設定エラー: \(error.localizedDescription)")
        }
    }
    
    func playAudio(url: URL, memoId: UUID) {
        do {
            // 既に再生中なら停止
            if isPlaying {
                stopPlaying()
            }
            
            // セッションをアクティブ化
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            isPlaying = true
            currentMemoId = memoId
        } catch {
            print("音声再生エラー: \(error.localizedDescription)")
            isPlaying = false
            currentMemoId = nil
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentMemoId = nil
        
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("オーディオセッションの終了エラー: \(error.localizedDescription)")
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.currentMemoId = nil
            self?.audioPlayer = nil
            
            do {
                try self?.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("オーディオセッションの終了エラー: \(error.localizedDescription)")
            }
        }
    }
}
