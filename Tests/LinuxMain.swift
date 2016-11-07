import XCTest
@testable import SwiftyJSONTests

// This is the entry point for SwiftyJSONTests on Linux

XCTMain([
	testCase(PerformanceTests.allTests),
	testCase(BaseTests.allTests),
	testCase(NestedJSONTests.allTests),
	testCase(SequenceTypeTests.allTests),
	testCase(PrintableTests.allTests),
	testCase(SubscriptTests.allTests),
	testCase(LiteralConvertibleTests.allTests),
	testCase(RawRepresentableTests.allTests),
	testCase(ComparableTests.allTests),
	testCase(StringTests.allTests),
	testCase(NumberTests.allTests),
	testCase(RawTests.allTests),
	testCase(DictionaryTests.allTests),
	testCase(ArrayTests.allTests)
])
