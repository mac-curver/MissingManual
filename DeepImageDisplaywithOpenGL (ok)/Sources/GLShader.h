/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Utility class for compiling a GL shader from a source string.
 */

#import <OpenGL/OpenGL.h>

@interface GLShader : NSObject

// Create a shader from a source file
- (nullable instancetype) initWithSource:(nullable const GLchar *)source
                                    type:(const GLenum)type;

+ (nullable instancetype) shaderWithSource:(nullable const GLchar *)source
                                      type:(const GLenum)type;

// Create a shader from a source file located at a URL
- (nullable instancetype) initWithURL:(nullable NSURL *)url
                                 type:(const GLenum)type;

+ (nullable instancetype) shaderWithURL:(nullable NSURL *)url
                                   type:(const GLenum)type;

// Create a shader from a source file located at an absolute path
- (nullable instancetype) initWithFile:(nullable NSString *)path
                                  type:(const GLenum)type;

+ (nullable instancetype) shaderWithFile:(nullable NSString *)path
                                    type:(const GLenum)type;

// Create a shader from a source file in application's bundle
- (nullable instancetype) initWithResource:(nullable NSString *)name
                                      type:(const GLenum)type;

+ (nullable instancetype) shaderWithResource:(nullable NSString *)name
                                        type:(const GLenum)type;

// Shader id
@property (nonatomic, readonly) GLuint shader;

@end
