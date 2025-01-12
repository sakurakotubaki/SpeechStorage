import SwiftUI

struct InfoView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedColor: Color = ThemeManager.shared.currentTheme
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("このアプリについて")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("音声メモアプリ")
                            .font(.headline)
                        Text("テキストを音声で読み上げることができます。")
                            .font(.subheadline)
                    }
                }
                
                Section(header: Text("テーマカラー")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("アプリのテーマカラーを変更できます")
                            .font(.subheadline)
                        ColorPickerView(selectedColor: $selectedColor)
                            .onChange(of: selectedColor) { newColor in
                                themeManager.updateTheme(newColor)
                            }
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("使い方")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. テキスト入力")
                            .font(.headline)
                        Text("キーボードボタンでテキストを入力できます。")
                        
                        Text("2. メモの管理")
                            .font(.headline)
                        Text("保存したメモは一覧で確認でき、再生や削除ができます。")
                        
                        Text("3. カラー設定")
                            .font(.headline)
                        Text("メモごとに好きな色を設定できます。")
                        
                        Text("4. 表示切り替え")
                            .font(.headline)
                        Text("メモ帳の右上のアイコンを押すとカードとリストのUIを切り替えることができます。")
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("法的情報")) {
                    Link(destination: URL(string: "https://pacific-sandalwood-6de.notion.site/170a1df91a0780c59d69d487508f123f")!) {
                        HStack {
                            Text("利用規約")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                    Link(destination: URL(string: "https://pacific-sandalwood-6de.notion.site/171a1df91a0780f48832ca5fd55356d7")!) {
                        HStack {
                            Text("プライバシーポリシー")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                }
            }
            .navigationTitle("情報")
        }
    }
}
