# CLAUDE.md

ObservableObjectは使用しなくも@Observableを使用すればマクロを使用してソースコードを
短くできます。こちらを使用するのを推奨。

```swift
// BEFORE
// これは使用しないでください
import SwiftUI


class Library: ObservableObject {
    // ...
}

// AFTER
// こちらを推奨
import SwiftUI


@Observable class Library {
    // ...
}
```

画面遷移するときのコードは、`NavigationStack`の仕様が推奨されている。`NavigationLink`を使用しないようにすること。