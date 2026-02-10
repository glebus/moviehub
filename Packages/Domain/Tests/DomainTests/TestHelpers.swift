import Testing

@MainActor
@inline(__always)
func fail(_ message: String) {
    #expect(Bool(false), Comment(rawValue: message))
}
