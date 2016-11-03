#import <XCTest/XCTest.h>
#import "RNFileSystem.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testWriteAndReadAndDelete {
  NSString *fileName = @"my-file.txt";
  BOOL fileExists = [RNFileSystem fileExists:fileName inStorage:STORAGE_BACKED_UP];
  XCTAssertFalse(fileExists);
  
  NSString *myContent = @"This is my content.";
  [RNFileSystem writeToFile:fileName content:myContent inStorage:STORAGE_BACKED_UP];
  fileExists = [RNFileSystem fileExists:fileName inStorage:STORAGE_BACKED_UP];
  XCTAssertTrue(fileExists);
  BOOL fileExistsInDifferentStorage = [RNFileSystem fileExists:fileName inStorage:STORAGE_IMPORTANT];
  XCTAssertFalse(fileExistsInDifferentStorage);
  
  NSString *readBackContent = [RNFileSystem readFile:fileName inStorage:STORAGE_BACKED_UP error:nil];
  XCTAssertEqualObjects(readBackContent, myContent);
  
  [RNFileSystem deleteFileOrDirectory:fileName inStorage:STORAGE_BACKED_UP];
  fileExists = [RNFileSystem fileExists:fileName inStorage:STORAGE_BACKED_UP];
  XCTAssertFalse(fileExists);
}

- (void)testFileAndFolderExistence {
  NSString *folderName = @"my-folder";
  NSString *fileName = @"my-file.txt";
  NSString *filePath = [[folderName stringByAppendingString:@"/"] stringByAppendingString:fileName];
  
  BOOL directoryExists = [RNFileSystem directoryExists:folderName inStorage:STORAGE_AUXILIARY];
  BOOL fileExists = [RNFileSystem fileExists:filePath inStorage:STORAGE_AUXILIARY];
  XCTAssertFalse(directoryExists);
  XCTAssertFalse(fileExists);
  
  [RNFileSystem writeToFile:filePath content:@"My content." inStorage:STORAGE_AUXILIARY];
  directoryExists = [RNFileSystem directoryExists:folderName inStorage:STORAGE_AUXILIARY];
  fileExists = [RNFileSystem fileExists:filePath inStorage:STORAGE_AUXILIARY];
  XCTAssertTrue(directoryExists);
  XCTAssertTrue(fileExists);
  directoryExists = [RNFileSystem directoryExists:filePath inStorage:STORAGE_AUXILIARY];
  fileExists = [RNFileSystem fileExists:folderName inStorage:STORAGE_AUXILIARY];
  XCTAssertFalse(directoryExists);
  XCTAssertFalse(fileExists);

  [RNFileSystem deleteFileOrDirectory:folderName inStorage:STORAGE_AUXILIARY];
  directoryExists = [RNFileSystem directoryExists:folderName inStorage:STORAGE_AUXILIARY];
  fileExists = [RNFileSystem fileExists:filePath inStorage:STORAGE_AUXILIARY];
  XCTAssertFalse(directoryExists);
  XCTAssertFalse(fileExists);
}

- (void)testAbsolutePathConstants {
  RNFileSystem *fileSystem = [[RNFileSystem alloc] init];
  NSString *backedUp = [[fileSystem constantsToExport] valueForKey:STORAGE_BACKED_UP];
  XCTAssertFalse([backedUp hasSuffix:@"/"]);
}

@end
