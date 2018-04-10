import Foundation

// MARK: - Error
// swiftlint:disable line_length
/// Error domain
@available(*, deprecated, message: "ErrorDomain is deprecated. Use `SwiftyJSONError.errorDomain` instead.", renamed: "SwiftyJSONError.errorDomain")
public let ErrorDomain: String = "SwiftyJSONErrorDomain"

/// Error code
@available(*, deprecated, message: "ErrorUnsupportedType is deprecated. Use `SwiftyJSONError.unsupportedType` instead.", renamed: "SwiftyJSONError.unsupportedType")
public let ErrorUnsupportedType: Int = 999
@available(*, deprecated, message: "ErrorIndexOutOfBounds is deprecated. Use `SwiftyJSONError.indexOutOfBounds` instead.", renamed: "SwiftyJSONError.indexOutOfBounds")
public let ErrorIndexOutOfBounds: Int = 900
@available(*, deprecated, message: "ErrorWrongType is deprecated. Use `SwiftyJSONError.wrongType` instead.", renamed: "SwiftyJSONError.wrongType")
public let ErrorWrongType: Int = 901
@available(*, deprecated, message: "ErrorNotExist is deprecated. Use `SwiftyJSONError.notExist` instead.", renamed: "SwiftyJSONError.notExist")
public let ErrorNotExist: Int = 500
@available(*, deprecated, message: "ErrorInvalidJSON is deprecated. Use `SwiftyJSONError.invalidJSON` instead.", renamed: "SwiftyJSONError.invalidJSON")
public let ErrorInvalidJSON: Int = 490

public enum SwiftyJSONError: Int, Swift.Error {
    case unsupportedType = 999
    case indexOutOfBounds = 900
    case elementTooDeep = 902
    case wrongType = 901
    case notExist = 500
    case invalidJSON = 490
}

extension SwiftyJSONError: CustomNSError {
    
    /// return the error domain of SwiftyJSONError
    public static var errorDomain: String { return "com.swiftyjson.SwiftyJSON" }
    
    /// return the error code of SwiftyJSONError
    public var errorCode: Int { return self.rawValue }
    
    /// return the userInfo of SwiftyJSONError
    public var errorUserInfo: [String: Any] {
        switch self {
        case .unsupportedType:
            return [NSLocalizedDescriptionKey: "It is an unsupported type."]
        case .indexOutOfBounds:
            return [NSLocalizedDescriptionKey: "Array Index is out of bounds."]
        case .wrongType:
            return [NSLocalizedDescriptionKey: "Couldn't merge, because the JSONs differ in type on top level."]
        case .notExist:
            return [NSLocalizedDescriptionKey: "Dictionary key does not exist."]
        case .invalidJSON:
            return [NSLocalizedDescriptionKey: "JSON is invalid."]
        case .elementTooDeep:
            return [NSLocalizedDescriptionKey: "Element too deep. Increase maxObjectDepth and make sure there is no reference loop."]
        }
    }
}
