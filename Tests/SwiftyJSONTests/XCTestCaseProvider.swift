import Foundation
import XCTest

// XCTestCaseProvider should be adopted by all XCTestCase subclasses. It provides a
// mechanism for us to fail tests in Xcode which haven't been included in the `allTests`
// list for swift-corelibs-xctest which is unable to dynamically discover tests. Note
// that only `static var allTests` needs to be explicitly implemented, as `allTestNames`
// has a default implementation provided by a protocol extension.

// Implementation note: This is broken down into two separate protocols because we need a
// protocol with no Self references to which we can cast XCTestCase instances in a non-generic context.

public protocol XCTestCaseProviderStatic {
    // This should be explicitly implemented by XCTestCase subclasses
    static var allTests: [(String, (Self) -> () throws -> Void)] { get }
}

public protocol XCTestCaseNameProvider {
    // This does not need to be explicitly implemented because of the protocol extension below
    var allTestNames: [String] { get }
}

public protocol XCTestCaseProvider: XCTestCaseProviderStatic, XCTestCaseNameProvider {}

extension XCTestCaseProvider where Self: XCTestCaseProviderStatic {
    var allTestNames: [String] {
        return type(of: self).allTests.map({ name, test in
            return name
        })
    }
}

#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)

extension XCTestCase {
    override open func tearDown() {
        if let provider = self as? XCTestCaseNameProvider {
            provider.assertContainsTest(invocation!.selector.description)
        }

        super.tearDown()
    }
}

extension XCTestCaseNameProvider {
    fileprivate func assertContainsTest(_ name: String) {
        let contains = self.allTestNames.contains(name)
        XCTAssert(contains, "Test '\(name)' is missing from the allTests array")
    }
}

#endif
