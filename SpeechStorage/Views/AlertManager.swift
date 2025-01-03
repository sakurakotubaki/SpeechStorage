import SwiftUI

class AlertManager: ObservableObject {
    static let shared = AlertManager()
    
    @Published var isShowingAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    private init() {}
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = message
            self.isShowingAlert = true
        }
    }
}
