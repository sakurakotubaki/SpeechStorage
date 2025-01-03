import SwiftUI
import SwiftData

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
    TextMemoListView(
        textMemos: [],
        ttsManager: TTSManager.shared,
        themeManager: ThemeManager.shared,
        modelContext: ModelContext(try! ModelContainer(for: VoiceMemo.self))
    )
}
