import Foundation

public enum SHACLTargetSelector: Sendable, Hashable {
    case targetClass(String)
    case targetNode(String)
    case targetNodeExpression(String)
    case targetSubjectsOf(String)
    case targetObjectsOf(String)
    case targetWhere(String)
}
