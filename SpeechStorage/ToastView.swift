import SwiftUI

struct ToastView: View {
    let message: String
    let icon: String
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .cornerRadius(25)
        .shadow(radius: 5)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let icon: String
    let backgroundColor: Color
    let duration: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    Spacer()
                    ToastView(
                        message: message,
                        icon: icon,
                        backgroundColor: backgroundColor
                    )
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: isShowing)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>,
               message: String,
               icon: String = "checkmark.circle.fill",
               backgroundColor: Color = .black.opacity(0.8),
               duration: Double = 2.0) -> some View {
        modifier(ToastModifier(
            isShowing: isShowing,
            message: message,
            icon: icon,
            backgroundColor: backgroundColor,
            duration: duration
        ))
    }
}
