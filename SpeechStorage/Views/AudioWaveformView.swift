import SwiftUI

struct AudioWaveformView: View {
    @State private var isAnimating = true
    private let numberOfBars = 30
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<numberOfBars, id: \.self) { index in
                AudioBar(index: index, isAnimating: isAnimating)
            }
        }
        .frame(height: 40)
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

struct AudioBar: View {
    let index: Int
    let isAnimating: Bool
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white)
            .frame(width: 3, height: 20)
            .scaleEffect(x: 1, y: scale, anchor: .center)
            .onAppear {
                withAnimation(
                    Animation
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.05)
                ) {
                    self.scale = isAnimating ? 0.3 + CGFloat(Double(index) / 40) : 1.0
                }
            }
    }
}
