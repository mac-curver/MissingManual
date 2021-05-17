/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Utility class for rendering a textured quad.
 */

#import <OpenGL/OpenGL.h>

@interface GLQuad: NSObject

// Create a quad with view bounds.
- (nullable instancetype) initWithBounds:(const NSRect)bounds;

// Program object id
@property (nonatomic, readonly) GLuint pid;

// Vertex array object
@property (nonatomic, readonly) GLuint vao;

// Draw mode
@property (nonatomic, readonly) GLenum mode;

// Texture target
@property (nonatomic, readonly) GLenum target;

// Texture bounds
@property (nonatomic, readonly) NSRect bounds;

// Set the image size. For texture 2D the default coordinates are used.
// For texture rectangle you need to set the original image size.
@property (nonatomic) NSSize size;

// Render the textured quad
- (void) render:(const GLuint)texture;

@end
