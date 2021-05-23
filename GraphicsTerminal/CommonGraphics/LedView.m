//
//  LedView.m
//  GraphicsTerminal
//
//  Created by Heinz-Jörg on 22.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import "LedView.h"

@implementation LedView


- (instancetype)initWithCoder:(NSCoder *)coder {
    // initWithFrame not being called!?
    if (self = [super initWithCoder:coder]) {
        _ledColor = NSColor.grayColor;
    }
    return self;
}

- (void)setColor:(NSColor *)color {
    _ledColor = color;
    [self setNeedsDisplay:YES];
}


- (void) drawRect:(NSRect) dirtyRect {
    [super drawRect:dirtyRect];
    
    NSPoint myStartPoint = NSMakePoint(0.10, 0.90),
            myEndPoint   = NSMakePoint(0.90, 0.10);
    //double myStartRadius = 0.05, myEndRadius = 0.25;
    
    double locations[] = {0.0, 0.1, 1.0};

    
    CGFloat components[12] = { 0.0, 1.0, 1.0, 1.0 // Start color
                             , 0.0, 1.0, 0.0, 1.0
                             , 1.0, 0.0, 0.0, 1.0 // End color
    };
    
    /*
     kCGColorSpaceGenericGray
     kCGColorSpaceGenericRGB
     kCGColorSpaceGenericCMYK
     kCGColorSpaceDisplayP3
     kCGColorSpaceGenericRGBLinear
     kCGColorSpaceAdobeRGB1998
     kCGColorSpaceSRGB
     kCGColorSpaceGenericGrayGamma2_2
     kCGColorSpaceGenericXYZ
     kCGColorSpaceGenericLab
     kCGColorSpaceACESCGLinear
     kCGColorSpaceITUR_709
     kCGColorSpaceITUR_2020
     kCGColorSpaceROMMRGB
     kCGColorSpaceDCIP3
     kCGColorSpaceExtendedSRGB
     kCGColorSpaceLinearSRGB
     kCGColorSpaceExtendedLinearSRGB
     kCGColorSpaceExtendedGray
     kCGColorSpaceLinearGray
     kCGColorSpaceExtendedLinearGray

    */
    
    CGColorSpaceRef myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear);

    CGGradientRef myGradient = CGGradientCreateWithColorComponents(
                            myColorspace, components
                          , locations, 3
                 );
    
    //NSBezierPath *oval = [NSBezierPath bezierPathWithOvalInRect:self.bounds];
    //[oval addClip];


    //CGContextDrawRadialGradient(
    //      [[NSGraphicsContext currentContext] graphicsPort]
    //    , myGradient
    //    , myStartPoint, myStartRadius
    //    , myEndPoint,   myEndRadius
    //    , kCGGradientDrawsAfterEndLocation
    //);
    
    CGContextDrawLinearGradient(
          NSGraphicsContext.currentContext.graphicsPort
        , myGradient, myStartPoint, myEndPoint
        , 3
    );


}

@end
