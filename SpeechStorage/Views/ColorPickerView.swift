import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    
    let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        Color(uiColor: UIColor(red: 0x21/255, green: 0x96/255, blue: 0xF3/255, alpha: 1)),
        Color(uiColor: UIColor(red: 0x4C/255, green: 0xAF/255, blue: 0x50/255, alpha: 1)),
        Color(uiColor: UIColor(red: 0x9C/255, green: 0x27/255, blue: 0xB0/255, alpha: 1))
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
