/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Utility class for loading a text file.
 */

#import <Cocoa/Cocoa.h>

@interface NSTextFile : NSObject

// Load a text file located at a URL
- (nullable instancetype) initWithURL:(nullable NSURL *)url;

+ (nullable instancetype) textWithURL:(nullable NSURL *)url;

// Load a text file located at an absolute path
- (nullable instancetype) initWithFile:(nullable NSString *)path;

+ (nullable instancetype) textWithFile:(nullable NSString *)path;

// Load a text file in application's bundle
- (nullable instancetype) initWithResource:(nullable NSString *)name
                                       ext:(nullable NSString *)ext;

+ (nullable instancetype) textWithResource:(nullable NSString *)name
                                       ext:(nullable NSString *)ext;

// Text file content
@property (nonatomic, readonly, nullable) const char* source;

@end
