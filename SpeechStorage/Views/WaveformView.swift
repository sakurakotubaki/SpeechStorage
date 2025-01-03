import SwiftUI

struct WaveformView: View {
    @State private var phase = 0.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let midHeight = height / 2
                
                context.translateBy(x: 0, y: midHeight)
                
                let path = Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    
                    for x in stride(from: 0, through: width, by: 1) {
                        let relativeX = x / width
                        let sine = sin(relativeX * 20 + phase)
                        let y = sine * midHeight * 0.8
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                
                context.stroke(path, with: .color(.blue), lineWidth: 2)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}
