import Foundation
import SwiftUI

/*
複数のデータ型のいずれかを使う[Union Type]を定義する。
case testは、Textで入力する場合
case speechは、音声をテキストに変換する
*/
enum SpeechType {
    case text(String) // Text input Only
    case speech(String) // Converted speech to text
    
    var text: String {
        switch self {
        case .text(let text):
            return text
        case .speech(let text):
            return text
        }
    }
    
    var isText: Bool {
        switch self {
        case .text:
            return true
        case .speech:
            return false
        }
    }
}
