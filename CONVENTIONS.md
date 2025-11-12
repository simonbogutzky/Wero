# File Header Template

All new Swift files must start with this exact header:

//
//  [filename]
//  Wero
//
//  Copyright © [current year] Bogutzky. All rights reserved.
//

Replace [filename] with the actual file name.
Use the current year (2025).

# File Organization

Each class, struct, or enum must be defined in its own separate file.
The file name should match the type name (e.g., `UserProfile.swift` for a `UserProfile` struct).

# Code Organization with MARK Comments

Use MARK comments to organize code sections within every class, struct, or enum.
**Only include MARK comments for sections that contain actual code.**

These sections must appear in this exact order when present:

1. `// MARK: - Properties` - for all properties (including computed properties like `body`)
2. `// MARK: - Initializers` - for all init methods
3. `// MARK: - Methods` - for all functions/methods

Example:

```swift
struct MainView: View {
    // MARK: - Properties

    var body: some View {
        Text("Title")
            .font(.largeTitle)
            .onAppear {
                onAppear()
            }
    }

    // MARK: - Initializers

    init() {}

    // MARK: - Methods

    func onAppear() {
        print("onAppear")
    }
}
```

# Observable Macro

Use the Observable macro for data model types instead of `ObservableObject`.

To adopt **Observation** in an existing app, begin by replacing `ObservableObject` in your data model type with the `@Observable` macro. The `@Observable` macro generates source code at compile time that adds observation support to the type.

```swift
// BEFORE
import SwiftUI

class Library: ObservableObject {
    // ...
}
```

```swift
// AFTER
import SwiftUI

@Observable class Library {
    // ...
}
```

Then remove the `@Published` property wrapper from observable properties. Observation doesn't require a property wrapper to make a property observable. Instead, the accessibility of the property in relationship to an observer, such as a view, determines whether a property is observable.

```swift
// BEFORE
@Observable class Library {
    @Published var books: [Book] = [Book(), Book(), Book()]
}
```

```swift
// AFTER
@Observable class Library {
    var books: [Book] = [Book(), Book(), Book()]
}
```

If you have properties that are accessible to an observer that you don't want to track, apply the `@ObservationIgnored` macro to the property.