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
    @State private var selectedColor = Color.blue
    @State private var showingTextField = false
    
    let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
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
                }
                
                List {
                    ForEach(memos) { memo in
                        VStack(alignment: .leading) {
                            Text(memo.text)
                                .foregroundColor(Color(hex: memo.themeColor))
                            Text(memo.createdAt, style: .date)
                                .font(.caption)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                modelContext.delete(memo)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                            
                            Button {
                                let utterance = AVSpeechUtterance(string: memo.text)
                                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                                synthesizer.speak(utterance)
                            } label: {
                                Label("再生", systemImage: "play.fill")
                            }
                            .tint(.blue)
                        }
                    }
                }
                
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
                                let memo = VoiceMemo(
                                    text: speechManager.transcribedText,
                                    themeColor: selectedColor.toHex() ?? "#000000"
                                )
                                modelContext.insert(memo)
                                speechManager.transcribedText = ""
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
            .navigationTitle("ボイスメモ")
        }
    }
}

#Preview {
    ContentView()
}
