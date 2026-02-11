import Testing
@testable import SHACLKit

@Test func coreValidatorReportsNotImplementedForNow() async throws {
    let validator = SHACLCoreValidator()

    do {
        _ = try validator.validate(dataGraph: Data(), shapesGraph: Data())
        Issue.record("Expected notImplemented until core engine lands")
    } catch let error as SHACLError {
        switch error {
        case .notImplemented(let detail):
            #expect(!detail.isEmpty)
        }
    }
}
