import SwiftUI

@Observable
class AlertManager {
    static let shared = AlertManager()

    var isShowingAlert = false
    var alertTitle = ""
    var alertMessage = ""

    private init() {}
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = message
            self.isShowingAlert = true
        }
    }
}
