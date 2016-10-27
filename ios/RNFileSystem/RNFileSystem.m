#import "RNFileSystem.h"

NSString *const STORAGE_BACKED_UP = @"BACKED_UP";
NSString *const STORAGE_IMPORTANT = @"IMPORTANT";
NSString *const STORAGE_AUXILIARY = @"AUXILIARY";
NSString *const STORAGE_TEMPORARY = @"TEMORARY";

@implementation RNFileSystem

+ (NSURL*)baseDirForStorage:(NSString*)storage {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([storage isEqual:STORAGE_BACKED_UP]) {
    return [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
  } else if ([storage isEqual:STORAGE_IMPORTANT] || [storage isEqual:STORAGE_AUXILIARY]) {
    return [fileManager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
  } else if ([storage isEqual:STORAGE_TEMPORARY]) {
    return [NSURL fileURLWithPath:NSTemporaryDirectory()];
  } else {
    [NSException raise:@"InvalidArgument" format:[NSString stringWithFormat:@"Storage type not recognized: %@", storage]];
    return nil;
  }
}

+ (void)createDirectoriesIfNeeded:(NSURL*)path {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *directory = [[path URLByDeletingLastPathComponent] path];
  [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
  
}

+ (void)writeToFile:(NSString*)relativePath content:(NSString*)content inStorage:(NSString*)storage {
  NSURL *baseDir = [RNFileSystem baseDirForStorage:storage];
  NSURL *fullPath = [baseDir URLByAppendingPathComponent:relativePath];
  [RNFileSystem createDirectoriesIfNeeded:fullPath];

  [content writeToFile:[fullPath path] atomically:YES encoding:NSUTF8StringEncoding error:nil];
  if ([storage isEqual:STORAGE_IMPORTANT]) {
    [RNFileSystem addSkipBackupAttributeToItemAtPath:[fullPath path]];
  }
}

+ (NSString*)readFile:(NSString*)relativePath inStorage:(NSString*)storage error:(NSError**)error {
  NSURL *baseDir = [RNFileSystem baseDirForStorage:storage];
  NSURL *fullPath = [baseDir URLByAppendingPathComponent:relativePath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL fileExists = [fileManager fileExistsAtPath:[fullPath path]];
  if (!fileExists) {
    NSDictionary *errorDetail = @{NSLocalizedDescriptionKey: @"File does not exist."};
    *error = [NSError errorWithDomain:@"FSComponent" code:1 userInfo:errorDetail];
    return nil;
  }
  return [NSString stringWithContentsOfFile:[fullPath path] encoding:NSUTF8StringEncoding error:nil];
}

+ (BOOL)fileExists:(NSString*)relativePath inStorage:(NSString*)storage {
  NSURL *baseDir = [RNFileSystem baseDirForStorage:storage];
  NSURL *fullPath = [baseDir URLByAppendingPathComponent:relativePath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL isDirectory;
  BOOL exists = [fileManager fileExistsAtPath:[fullPath path] isDirectory:&isDirectory];
  return exists & !isDirectory;
}

+ (BOOL)directoryExists:(NSString*)relativePath inStorage:(NSString*)storage {
  NSURL *baseDir = [RNFileSystem baseDirForStorage:storage];
  NSURL *fullPath = [baseDir URLByAppendingPathComponent:relativePath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL isDirectory;
  BOOL exists = [fileManager fileExistsAtPath:[fullPath path] isDirectory:&isDirectory];
  return exists & isDirectory;
}

+ (BOOL)deleteFileOrDirectory:(NSString*)relativePath inStorage:(NSString*)storage {
  NSURL *baseDir = [RNFileSystem baseDirForStorage:storage];
  NSURL *fullPath = [baseDir URLByAppendingPathComponent:relativePath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL fileExists = [fileManager fileExistsAtPath:[fullPath path]];
  if (!fileExists) {
    return NO;
  }
  [fileManager removeItemAtPath:[fullPath path] error:nil];
  return YES;
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *) filePathString
{
  NSURL* URL= [NSURL fileURLWithPath: filePathString];
  assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
  
  NSError *error = nil;
  BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                forKey: NSURLIsExcludedFromBackupKey error: &error];
  if(!success){
    NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
  }
  return success;
}

// Extra method for integration from other modules / native code
+ (NSString*)moveFileFromUrl:(NSURL*)location toRelativePath:(NSString*)relativePath inStorage:(NSString*)storage {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *baseDir = [RNFileSystem baseDirForStorage:storage];
  NSURL *fullPath = [baseDir URLByAppendingPathComponent:relativePath];
  [RNFileSystem createDirectoriesIfNeeded:fullPath];
  [fileManager moveItemAtURL:location toURL:fullPath error:nil];
  if ([storage isEqual:STORAGE_IMPORTANT]) {
    [RNFileSystem addSkipBackupAttributeToItemAtPath:[fullPath path]];
  }
  return [fullPath path];
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(writeToFile:(NSString*)relativePath content:(NSString*)content inStorage:(NSString*)storage resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  [RNFileSystem writeToFile:relativePath content:content inStorage:storage];
  resolve([NSNumber numberWithBool:YES]);
}


RCT_EXPORT_METHOD(readFile:(NSString*)relativePath inStorage:(NSString*)storage resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSError *error;
  NSString *content = [RNFileSystem readFile:relativePath inStorage:storage error:&error];
  if (error != nil) {
    reject(@"RNFileSystemError", [error localizedDescription], error);
  } else {
    resolve(content);
  }
}

RCT_EXPORT_METHOD(fileExists:(NSString*)relativePath inStorage:(NSString*)storage resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  BOOL fileExists = [RNFileSystem fileExists:relativePath inStorage:storage];
  resolve([NSNumber numberWithBool:fileExists]);
}

RCT_EXPORT_METHOD(directoryExists:(NSString*)relativePath inStorage:(NSString*)storage resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  BOOL folderExists = [RNFileSystem directoryExists:relativePath inStorage:storage];
  resolve([NSNumber numberWithBool:folderExists]);
}

RCT_EXPORT_METHOD(delete:(NSString*)relativePath inStorage:(NSString*)storage resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  BOOL deleted = [RNFileSystem deleteFileOrDirectory:relativePath inStorage:storage];
  resolve([NSNumber numberWithBool:deleted]);
}

@end
