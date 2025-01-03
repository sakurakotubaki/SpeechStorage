import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    
    let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        Color(hex: "#2196F3"), Color(hex: "#4CAF50"), Color(hex: "#9C27B0")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .shadow(radius: 3)
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding()
        }
    }
}
