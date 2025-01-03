import SwiftUI
import SwiftData
import AVFoundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VoiceMemo.createdAt, order: .reverse) private var textMemos: [VoiceMemo]
    
    @StateObject private var ttsManager = TTSManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var alertManager = AlertManager.shared
    
    @State private var selectedTab = 0
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // テキスト入力タブ
            TextInputView(
                themeManager: themeManager,
                showToast: $showToast,
                toastMessage: $toastMessage
            )
            .tabItem {
                Label("入力", systemImage: "square.and.pencil")
            }
            .tag(0)
            
            // テキストメモ一覧タブ
            TextMemoListView(
                textMemos: textMemos,
                ttsManager: ttsManager,
                themeManager: themeManager,
                modelContext: modelContext
            )
            .tabItem {
                Label("メモ一覧", systemImage: "doc.text")
            }
            .tag(1)
            
            // 設定タブ
            InfoView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
                .tag(2)
        }
        .tint(themeManager.currentTheme)
        .toast(isShowing: $showToast,
               message: toastMessage,
               icon: "checkmark.circle.fill",
               backgroundColor: themeManager.currentTheme.opacity(0.9))
        .alert(alertManager.alertTitle,
               isPresented: $alertManager.isShowingAlert) {
            Button("OK") {}
        } message: {
            Text(alertManager.alertMessage)
        }
    }
}

// TextMemoListView
struct TextMemoListView: View {
    let textMemos: [VoiceMemo]
    @ObservedObject var ttsManager: TTSManager
    @ObservedObject var themeManager: ThemeManager
    let modelContext: ModelContext
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(textMemos) { memo in
                    VStack(alignment: .leading) {
                        Text(memo.text)
                            .padding(.vertical, 4)
                        
                        HStack {
                            Text(memo.createdAt.formatted())
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Button(action: {
                                ttsManager.speak(memo.text)
                            }) {
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(themeManager.currentTheme)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing) {
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
}

#Preview {
    ContentView()
}
