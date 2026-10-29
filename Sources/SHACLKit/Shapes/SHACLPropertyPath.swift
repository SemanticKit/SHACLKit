import Foundation

public indirect enum SHACLPropertyPath: Sendable, Hashable {
    case predicate(String)
    case inverse(SHACLPropertyPath)
    case sequence([SHACLPropertyPath])
    case alternative([SHACLPropertyPath])
    case zeroOrMore(SHACLPropertyPath)
    case oneOrMore(SHACLPropertyPath)
    case zeroOrOne(SHACLPropertyPath)
}
