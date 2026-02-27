import Testing
@testable import Data

@MainActor
struct ObservableValueTests {
    @Test
    func storesCurrentValueAndSharesUpdates() async {
        let value = ObservableValue(1)

        #expect(value.value == 1)

        nonisolated(unsafe) var firstIterator = value.updates.makeAsyncIterator()
        nonisolated(unsafe) var secondIterator = value.updates.makeAsyncIterator()

        value.send(2)

        let firstUpdate = try? await firstIterator.next()
        let secondUpdate = try? await secondIterator.next()

        #expect(value.value == 2)
        #expect(firstUpdate == 2)
        #expect(secondUpdate == 2)
    }
}
