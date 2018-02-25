import XCTest

@testable import SwiftyJSONTests

let tests: [XCTestCaseEntry] = [
    testCase(ArrayTests.allTests),
    testCase(BaseTests.allTests),
    testCase(ComparableTests.allTests),
    testCase(DictionaryTests.allTests),
    testCase(LiteralConvertibleTests.allTests),
    testCase(MergeTests.allTests),
    testCase(MutabilityTests.allTests),
    testCase(NestedJSONTests.allTests),
    testCase(NumberTests.allTests),
    testCase(PerformanceTests.allTests),
    testCase(PrintableTests.allTests),
    testCase(RawRepresentableTests.allTests),
    testCase(RawTests.allTests),
    testCase(SequenceTypeTests.allTests),
    testCase(StringTests.allTests),
    testCase(SubscriptTests.allTests)
]

XCTMain(tests)
