import SwiftUI
import SwiftData

struct TextMemoListView: View {
    let textMemos: [VoiceMemo]
    @ObservedObject var ttsManager: TTSManager
    @ObservedObject var themeManager: ThemeManager
    let modelContext: ModelContext
    
    @State private var currentIndex: Int = 0
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    
    private let cardHeight: CGFloat = 180
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 上部スクロールリスト
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(textMemos) { memo in
                            HStack {
                                Text(memo.text)
                                    .lineLimit(2)
                                    .font(.system(size: 14))
                                
                                Spacer()
                                
                                Button(action: {
                                    ttsManager.speak(memo.text)
                                }) {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(themeManager.currentTheme)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                // 下部スワイプカード
                ZStack {
                    ForEach(Array(textMemos.enumerated().reversed()), id: \.element.id) { index, memo in
                        let isCurrentCard = index == currentIndex
                        
                        cardView(for: memo)
                            .frame(width: screenWidth - 32, height: cardHeight)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .offset(x: isCurrentCard ? offset : 0)
                            .rotationEffect(.degrees(isCurrentCard ? Double(offset / 20) : 0))
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        if isCurrentCard {
                                            offset = gesture.translation.width
                                            isDragging = true
                                        }
                                    }
                                    .onEnded { gesture in
                                        if isCurrentCard {
                                            withAnimation(.spring()) {
                                                let width = gesture.translation.width
                                                if abs(width) > screenWidth * 0.3 {
                                                    offset = (width > 0 ? screenWidth : -screenWidth) * 2
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                        if width > 0 && currentIndex > 0 {
                                                            currentIndex -= 1
                                                        } else if width < 0 && currentIndex < textMemos.count - 1 {
                                                            currentIndex += 1
                                                        }
                                                        offset = 0
                                                    }
                                                } else {
                                                    offset = 0
                                                }
                                            }
                                            isDragging = false
                                        }
                                    }
                            )
                            .zIndex(isCurrentCard ? 1 : 0)
                            .opacity(isCurrentCard ? 1 : 0.5)
                    }
                }
                .frame(height: cardHeight + 32)
                .padding(.vertical)
            }
            .navigationTitle("メモ一覧")
        }
    }
    
    private func cardView(for memo: VoiceMemo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(memo.text)
                .font(.system(size: 16, weight: .regular))
                .lineLimit(4)
                .padding(.horizontal)
            
            Spacer()
            
            HStack {
                Text(memo.createdAt.formatted())
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    ttsManager.speak(memo.text)
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(themeManager.currentTheme)
                }
                
                Button(action: {
                    withAnimation {
                        modelContext.delete(memo)
                        if currentIndex >= textMemos.count - 1 {
                            currentIndex = max(0, textMemos.count - 2)
                        }
                    }
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
        )
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
