import SwiftUI
import SwiftData

struct TextMemoListView: View {
    @Query private var textMemos: [VoiceMemo]
    @ObservedObject var ttsManager: TTSManager
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentIndex: Int = 0
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    @State private var isListView = true  // 追加：表示モードの状態
    
    private let cardHeight: CGFloat = 180
    private let screenWidth = UIScreen.main.bounds.width
    
    init(ttsManager: TTSManager, themeManager: ThemeManager) {
        self.ttsManager = ttsManager
        self.themeManager = themeManager
        let sortDescriptor = SortDescriptor<VoiceMemo>(\.createdAt, order: .reverse)
        _textMemos = Query(sort: [sortDescriptor])
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isListView {
                    // リスト表示
                    List {
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
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        modelContext.delete(memo)
                                        do {
                                            try modelContext.save()
                                        } catch {
                                            print("Error deleting memo: \(error)")
                                        }
                                    }
                                } label: {
                                    Image(systemName: "trash.fill")
                                }
                                .tint(themeManager.currentTheme)
                            }
                        }
                    }
                } else {
                    // カード表示
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
            }
            .navigationTitle("メモ一覧")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        withAnimation {
                            isListView.toggle()
                        }
                    }) {
                        Image(systemName: isListView ? "square.grid.2x2" : "list.bullet")
                    }
                }
            }
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
                
                Button(action: deleteCard) {
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
    
    private func deleteCard() {
        guard currentIndex < textMemos.count else { return }
        let memo = textMemos[currentIndex]
        
        withAnimation {
            modelContext.delete(memo)
            do {
                try modelContext.save()
                // インデックスの更新
                if !textMemos.isEmpty {
                    currentIndex = min(currentIndex, textMemos.count - 1)
                }
            } catch {
                print("Error deleting card: \(error)")
            }
        }
    }
}

#Preview {
    TextMemoListView(
        ttsManager: TTSManager.shared,
        themeManager: ThemeManager.shared
    )
}
