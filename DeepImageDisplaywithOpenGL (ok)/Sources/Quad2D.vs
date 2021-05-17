/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A quad vertex shader for texture 2D.
 */

#version 410 core

layout(location = 0) in vec2 vertex;
layout(location = 1) in vec2 texCoord;

out vec2 fragTexCoord;

void main()
{
    gl_Position  = vec4(vertex, 0.0, 1.0);
    fragTexCoord = texCoord;
}
