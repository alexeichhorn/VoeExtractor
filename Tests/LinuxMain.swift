import XCTest

import VoeExtractorTests

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(VoeExtractorTests.allTests),
    ]
}
#endif
