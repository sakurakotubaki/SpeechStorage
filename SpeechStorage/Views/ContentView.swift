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
                ttsManager: ttsManager,
                themeManager: themeManager
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
