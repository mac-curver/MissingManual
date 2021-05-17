/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A quad fragment shader for texture rectangle.
 */

#version 410 core

in  vec2 fragTexCoord;
out vec4 fragColor;

uniform sampler2DRect tex;

void main()
{
    fragColor = texture(tex, fragTexCoord);
}
