#import <XCTest/XCTest.h>
#import "RCTTestRunner.h"

#define RCT_TEST(name)                  \
- (void)test##name                      \
{                                       \
[_runner runTest:_cmd module:@#name]; \
}

@interface RNFileSystemIntegrationTests : XCTestCase

@end

@implementation RNFileSystemIntegrationTests
{
  RCTTestRunner *_runner;
}

- (void)setUp {
  setenv("CI_USE_PACKAGER", "TRUE", true);
  _runner = RCTInitRunnerForApp(@"integration-test/IntegrationTestsApp", nil);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

RCT_TEST(FileSystemTest)

@end
