//
//  ContentView.swift
//  SpeechStorage
//
//  Created by 橋本純一 on 2025/01/03.
//

import SwiftUI
import SwiftData
import AVFoundation

class AudioManager: ObservableObject {
    let synthesizer = AVSpeechSynthesizer()
    
    init() {
        setupAudio()
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func speak(_ text: String) {
        // 再生中の音声があれば停止
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // 新しい音声を再生
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.5 // 読み上げ速度を調整
        utterance.pitchMultiplier = 1.0 // ピッチを調整
        utterance.volume = 1.0 // 音量を最大に
        synthesizer.speak(utterance)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var memos: [VoiceMemo]
    
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var audioPlayer = AudioPlayerManager.shared
    @State private var selectedColor = Color.blue
    @State private var showingTextField = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            recordingView
                .tabItem {
                    Label("録音", systemImage: "mic.fill")
                }
                .tag(0)
            
            memoListView
                .tabItem {
                    Label("メモ", systemImage: "list.bullet")
                }
                .tag(1)
            
            InfoView()
                .tabItem {
                    Label("情報", systemImage: "info.circle")
                }
                .tag(2)
        }
    }
    
    private var recordingView: some View {
        NavigationView {
            VStack {
                ColorPickerView(selectedColor: $selectedColor)
                
                if speechManager.isRecording {
                    WaveformView()
                        .frame(height: 60)
                }
                
                if showingTextField {
                    TextField("テキストを入力", text: $speechManager.transcribedText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        if !speechManager.transcribedText.isEmpty {
                            saveCurrentMemo()
                        }
                    }) {
                        Text("保存")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                HStack {
                    Button {
                        showingTextField.toggle()
                    } label: {
                        Image(systemName: "keyboard")
                            .font(.title)
                    }
                    
                    Spacer()
                    
                    Button {
                        if speechManager.isRecording {
                            speechManager.stopRecording()
                            if !speechManager.transcribedText.isEmpty {
                                saveCurrentMemo()
                            }
                        } else {
                            try? speechManager.startRecording()
                        }
                    } label: {
                        Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(selectedColor)
                    }
                }
                .padding()
            }
            .navigationTitle("録音")
        }
    }
    
    private var memoListView: some View {
        NavigationView {
            List {
                ForEach(memos) { memo in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(memo.text)
                                .foregroundColor(Color(hex: memo.themeColor))
                            
                            Spacer()
                            
                            Button {
                                audioPlayer.playText(memo.text, memoId: memo.id)
                            } label: {
                                Image(systemName: audioPlayer.playingMemoId == memo.id ? "stop.circle.fill" : "play.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                        }
                        
                        Text(memo.createdAt, style: .date)
                            .font(.caption)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            modelContext.delete(memo)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("メモ一覧")
        }
    }
    
    private func saveCurrentMemo() {
        let memo = VoiceMemo(
            text: speechManager.transcribedText,
            themeColor: selectedColor.toHex() ?? "#000000"
        )
        modelContext.insert(memo)
        speechManager.transcribedText = ""
        showingTextField = false
    }
}

#Preview {
    ContentView()
}
