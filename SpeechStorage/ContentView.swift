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
    @Query private var memos: [VoiceMemo]
    
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var ttsManager = TTSManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingTextField = false
    @State private var selectedTab = 0
    @State private var showingThemePicker = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
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
        .tint(themeManager.currentTheme)
        .alert("エラー", isPresented: .constant(speechManager.errorMessage != nil)) {
            Button("OK") {
                speechManager.errorMessage = nil
            }
        } message: {
            Text(speechManager.errorMessage ?? "")
        }
        .toast(isShowing: $showToast,
               message: toastMessage,
               icon: "checkmark.circle.fill",
               backgroundColor: themeManager.currentTheme.opacity(0.9))
    }
    
    private var recordingView: some View {
        NavigationView {
            VStack {
                if showingThemePicker {
                    ColorPickerView(selectedColor: .init(
                        get: { themeManager.currentTheme },
                        set: { themeManager.updateTheme($0) }
                    ))
                }
                
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
                            showSaveToast()
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
                        showingThemePicker.toggle()
                    } label: {
                        Image(systemName: "paintpalette")
                            .font(.title)
                    }
                    
                    Spacer()
                    
                    Button {
                        if speechManager.isRecording {
                            speechManager.stopRecording()
                            if !speechManager.transcribedText.isEmpty {
                                saveCurrentMemo()
                                showSaveToast()
                            }
                        } else {
                            do {
                                try speechManager.startRecording()
                            } catch {
                                print("録音開始エラー: \(error.localizedDescription)")
                                toastMessage = "録音開始エラー: \(error.localizedDescription)"
                                showToast = true
                            }
                        }
                    } label: {
                        Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(themeManager.currentTheme)
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
            .navigationTitle("メモ一覧")
        }
    }
    
    private func saveCurrentMemo() {
        let memo = VoiceMemo(
            text: speechManager.transcribedText,
            themeColor: themeManager.currentTheme.toHex() ?? "#000000"
        )
        modelContext.insert(memo)
        speechManager.transcribedText = ""
        showingTextField = false
    }
    
    private func showSaveToast() {
        toastMessage = "音声メモを保存しました"
        showToast = true
    }
}

#Preview {
    ContentView()
}
