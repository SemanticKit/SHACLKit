import Foundation

extension SHACLCoreValidator {
    func isTrueOnlyExpressionOutput(_ outputNodes: Set<String>) -> Bool {
        guard outputNodes.count == 1, let only = outputNodes.first else {
            return false
        }
        return only == "true"
            || only == "1"
            || only == "\"true\""
            || only == "\"true\"^^\(SHACLIRIs.xsdBoolean)"
            || only == "\"1\"^^\(SHACLIRIs.xsdBoolean)"
    }
}
