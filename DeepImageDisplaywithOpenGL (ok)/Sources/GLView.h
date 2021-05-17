/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Custom OpenGL view for the application.
 */

#import "IOSurface2D.h"

@interface GLView : NSOpenGLView

@property (nonatomic, retain, nullable) NSString* resource;
@property (nonatomic, retain, nullable) NSString* path;

@property (nonatomic, retain, nullable) NSURL* URL;

@property (nonatomic, retain, nullable) IOSurface2D* surface;

@property (nonatomic, readonly)  GLsizei width;
@property (nonatomic, readonly)  GLsizei height;

@end
