//
//  ContentView.swift
//  SpeechStorage
//
//  Created by 橋本純一 on 2025/01/03.
//

import SwiftUI
import SwiftData
import AVFoundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var textMemos: [VoiceMemo]
    @Query private var audioMemos: [AudioMemo]
    
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var ttsManager = TTSManager.shared
    @StateObject private var audioPlayer = AudioPlayerManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 音声録音タブ
            AudioRecordingView(
                speechManager: speechManager,
                themeManager: themeManager,
                modelContext: modelContext,
                showToast: $showToast,
                toastMessage: $toastMessage
            )
            .tabItem {
                Label("録音", systemImage: "mic.fill")
            }
            .tag(0)
            
            // 音声メモ一覧タブ
            AudioMemoListView(
                audioMemos: audioMemos,
                audioPlayer: audioPlayer,
                themeManager: themeManager,
                modelContext: modelContext
            )
            .tabItem {
                Label("音声メモ", systemImage: "waveform")
            }
            .tag(1)
            
            // テキスト入力タブ
            TextInputView(
                themeManager: themeManager,
                ttsManager: ttsManager,
                modelContext: modelContext,
                showToast: $showToast,
                toastMessage: $toastMessage
            )
            .tabItem {
                Label("テキスト", systemImage: "text.bubble")
            }
            .tag(2)
            
            // テキストメモ一覧タブ
            TextMemoListView(
                textMemos: textMemos,
                ttsManager: ttsManager,
                themeManager: themeManager,
                modelContext: modelContext
            )
            .tabItem {
                Label("テキストメモ", systemImage: "doc.text")
            }
            .tag(3)
        }
        .tint(themeManager.currentTheme)
        .toast(isShowing: $showToast,
               message: toastMessage,
               icon: "checkmark.circle.fill",
               backgroundColor: themeManager.currentTheme.opacity(0.9))
    }
}

// AudioRecordingView.swift
struct AudioRecordingView: View {
    @ObservedObject var speechManager: SpeechManager
    @ObservedObject var themeManager: ThemeManager
    let modelContext: ModelContext
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    var body: some View {
        NavigationStack {
            VStack {
                if speechManager.isRecording {
                    WaveformView()
                        .frame(height: 60)
                }
                
                Spacer()
                
                Button {
                    if speechManager.isRecording {
                        if let url = speechManager.stopRecording() {
                            saveAudioMemo(url: url)
                            showSaveToast()
                        }
                    } else {
                        speechManager.startRecording()
                    }
                } label: {
                    Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(themeManager.currentTheme)
                }
                .padding()
            }
            .navigationTitle("録音")
        }
    }
    
    private func saveAudioMemo(url: URL) {
        let memo = AudioMemo(audioURL: url, themeColor: themeManager.currentTheme.toHex() ?? "#000000")
        modelContext.insert(memo)
    }
    
    private func showSaveToast() {
        toastMessage = "音声メモを保存しました"
        showToast = true
    }
}

// AudioMemoListView.swift
struct AudioMemoListView: View {
    let audioMemos: [AudioMemo]
    @ObservedObject var audioPlayer: AudioPlayerManager
    @ObservedObject var themeManager: ThemeManager
    let modelContext: ModelContext
    
    var body: some View {
        NavigationStack {
            List(audioMemos) { memo in
                AudioMemoRow(
                    memo: memo,
                    audioPlayer: audioPlayer,
                    themeManager: themeManager,
                    modelContext: modelContext
                )
            }
            .navigationTitle("音声メモ一覧")
        }
    }
}

struct AudioMemoRow: View {
    let memo: AudioMemo
    @ObservedObject var audioPlayer: AudioPlayerManager
    @ObservedObject var themeManager: ThemeManager
    let modelContext: ModelContext
    
    var body: some View {
        HStack {
            Image(systemName: "waveform")
                .foregroundColor(Color(hex: memo.themeColor))
            
            Text(memo.createdAt.formatted())
            
            Spacer()
            
            Button {
                if audioPlayer.isPlaying && audioPlayer.currentMemoId == memo.id {
                    audioPlayer.stopPlaying()
                } else {
                    audioPlayer.playAudio(url: memo.audioURL, memoId: memo.id)
                }
            } label: {
                Image(systemName: audioPlayer.isPlaying && audioPlayer.currentMemoId == memo.id ? "stop.circle.fill" : "play.circle.fill")
                    .foregroundColor(themeManager.currentTheme)
                    .font(.title2)
            }
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

// TextInputView.swift
struct TextInputView: View {
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var ttsManager: TTSManager
    let modelContext: ModelContext
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    @FocusState private var isFocused: Bool
    
    @State private var text = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .frame(height: 200)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding()
                        .focused($isFocused)
                    
                    if text.isEmpty {
                        Text("テキストを入力")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
                
                if isFocused {
                    HStack {
                        Spacer()
                        Button("閉じる") {
                            isFocused = false
                        }
                        .foregroundColor(themeManager.currentTheme)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemBackground))
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.2)),
                        alignment: .top
                    )
                }
                
                Button(action: {
                    if !text.isEmpty {
                        saveTextMemo()
                        showSaveToast()
                        isFocused = false
                    }
                }) {
                    Text("保存")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(themeManager.currentTheme)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(text.isEmpty)
                
                Spacer()
            }
            .navigationTitle("テキスト入力")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func saveTextMemo() {
        let memo = VoiceMemo(text: text, themeColor: themeManager.currentTheme.toHex() ?? "#000000")
        modelContext.insert(memo)
        text = ""
    }
    
    private func showSaveToast() {
        toastMessage = "テキストメモを保存しました"
        showToast = true
    }
}

// TextMemoListView.swift
struct TextMemoListView: View {
    let textMemos: [VoiceMemo]
    @ObservedObject var ttsManager: TTSManager
    @ObservedObject var themeManager: ThemeManager
    let modelContext: ModelContext
    
    var body: some View {
        NavigationStack {
            List(textMemos) { memo in
                TextMemoRow(
                    memo: memo,
                    ttsManager: ttsManager,
                    themeManager: themeManager,
                    modelContext: modelContext
                )
            }
            .navigationTitle("テキストメモ一覧")
        }
    }
}

struct TextMemoRow: View {
    let memo: VoiceMemo
    @ObservedObject var ttsManager: TTSManager
    @ObservedObject var themeManager: ThemeManager
    let modelContext: ModelContext
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(memo.text)
                    .foregroundColor(Color(hex: memo.themeColor))
                
                Spacer()
                
                Button {
                    if ttsManager.isPlaying && ttsManager.currentText == memo.text {
                        ttsManager.stopSpeaking()
                    } else {
                        ttsManager.speak(memo.text)
                    }
                } label: {
                    Image(systemName: ttsManager.isPlaying && ttsManager.currentText == memo.text ? "stop.circle.fill" : "play.circle.fill")
                        .foregroundColor(themeManager.currentTheme)
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

#Preview {
    ContentView()
}
