/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Utility class for creating a program object.
 */

#import <iostream>

#import <OpenGL/gl3.h>

#import "GLProgram.h"

@implementation GLProgram
{
@private
    GLuint _pid;
    GLuint index;
}

- (nullable instancetype) init
{
    self = [super init];
    
    if(self)
    {
        _pid = glCreateProgram();
        
        if(!_pid)
        {
            NSLog(@">> ERROR: GL create program failed!");
            
            assert(0);
        } // if
        
        index = 0;
    } // if
    
    return self;
} // init

// Destructor
- (void) dealloc
{
    if(_pid)
    {
        glDeleteProgram(_pid);
        
        glUseProgram(0);
    } // if
    
    [super dealloc];
} // dealloc

// Attach shaders, in an ascending order, starting at index 0
- (void) attach:(GLuint)shader
{
    if(shader)
    {
        glAttachShader(_pid, shader);
    } // if
} // attach

// Bind attributes, in an ascending order, starting at index 0
- (void) bind:(nullable const GLchar *)attribute
{
    if(attribute != nullptr)
    {
        glBindAttribLocation(_pid, index, attribute);
        
        index++;
    } // if
} // bind

// Bind/unbind the program
- (void) program:(BOOL)use
{
    if(use)
    {
        glUseProgram(_pid);
    } // if
    else
    {
        glUseProgram(0);
    } // else
} // use

// Link shaders and create the program object
- (BOOL) link
{
    glLinkProgram(_pid);
    
    GLint isLinked = 0;
    
    glGetProgramiv(_pid, GL_LINK_STATUS, &isLinked);
    
    if(!isLinked)
    {
        GLint maxLength = 0;
        
        glGetProgramiv(_pid, GL_INFO_LOG_LENGTH, &maxLength);
        
        GLchar* infoLog = new (std::nothrow) char[maxLength];
        
        if(infoLog != nullptr)
        {
            glGetProgramInfoLog(_pid, maxLength, &maxLength, infoLog);
            
            NSLog(@">> ERROR: {\n%s\n}\n", infoLog);

            delete [] infoLog;
        } // if
        
        _pid = 0;
        
        return NO;
    } // if
    
    return YES;
} // link

@end
