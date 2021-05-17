/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Utility class for creating a program object.
 */

#import <OpenGL/OpenGL.h>

@interface GLProgram : NSObject

// Attach shaders, in an ascending order, starting at index 0
@property (nonatomic, setter=attach:) GLuint shader;

// Bind attributes, in an ascending order, starting at index 0
@property (nonatomic, nullable, setter=bind:) const GLchar* attribute;

// Bind/unbind the program
@property (nonatomic, setter=program:) BOOL use;

// Program id
@property (nonatomic, readonly) GLuint pid;

// Link shaders and create the program object
- (BOOL) link;

@end
