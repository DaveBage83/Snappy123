@propertyWrapper
struct ThreadSafe<T> {
    private let writeSafe: WriteSafe
    var unsafeValue: T
    var wrappedValue: T {
        get { writeSafe.perform { unsafeValue } }
        set { writeSafe.perform { unsafeValue = newValue } }
    }
    init(wrappedValue: T, writeSafe: WriteSafe = WriteSafe()) {
        self.unsafeValue = wrappedValue
        self.writeSafe = writeSafe
    }
}
