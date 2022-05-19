import SwiftUI

extension View {
    func hidden(_ isHidden: Bool) -> some View{
        opacity(isHidden ? 0 : 1)
    }
}

extension String {
    func emptyToNil() -> String? {
        self.isBlank ? nil: self
    }

    var isBlank: Bool {
        trimmingCharacters(in: .whitespaces).isEmpty ? true : false
    }
}

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}
