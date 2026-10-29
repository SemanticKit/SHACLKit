import Foundation

extension SHACLCoreValidator {
    enum SHACLRangeComparable {
        case number(Double, isInteger: Bool)
        case dateTime(Date, hasTimezone: Bool)
    }
}
