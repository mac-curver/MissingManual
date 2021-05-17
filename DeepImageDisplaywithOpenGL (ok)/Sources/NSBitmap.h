/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Utility class for creating a bitmap from an image.
 */

#import <Cocoa/Cocoa.h>

@interface NSBitmap : NSObject

- (nullable instancetype) initWithImage:(nullable NSImage *)image;

+ (nullable instancetype) bitmapWithImage:(nullable NSImage *)image;

@property (nonatomic, readonly, nullable) NSBitmapImageRep* bitmap;

@end
