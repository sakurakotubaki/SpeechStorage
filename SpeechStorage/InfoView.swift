import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("アプリについて")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("音声メモアプリ")
                            .font(.headline)
                        Text("音声を録音して文字起こしができるアプリです。")
                            .font(.subheadline)
                    }
                }
                
                Section(header: Text("使い方")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. 音声録音")
                            .font(.headline)
                        Text("マイクボタンをタップして録音を開始/停止します。")
                        
                        Text("2. テキスト入力")
                            .font(.headline)
                        Text("キーボードボタンをタップしてテキストを入力できます。")
                        
                        Text("3. メモの管理")
                            .font(.headline)
                        Text("保存したメモは一覧で確認でき、再生や削除ができます。")
                        
                        Text("4. カラー設定")
                            .font(.headline)
                        Text("メモごとに好きな色を設定できます。")
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("情報")
        }
    }
}
