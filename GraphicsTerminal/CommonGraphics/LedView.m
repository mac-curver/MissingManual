//
//  LedView.m
//  GraphicsTerminal
//
//  Created by LegoEsprit on 22.05.21.
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
    //CGContextSetShouldAntialias(NSGraphicsContext.currentContext.graphicsPort, YES);
    CGFloat components[8];//[2*_ledColor.numberOfComponents];
    [_ledColor getComponents:&components[4]];
    for (int i = 0; i < 3; i++) {
        components[i] = fmin(1.0, components[4+i]/0.5);                         // brighter
    }
    components[7] = 1.0;

    CGGradientRef gradient = CGGradientCreateWithColorComponents(
                                   CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear)
                                 , components
                                 , (const CGFloat[]){0.0, 1.000000}, 2
                             );
    CGContextDrawRadialGradient(
          NSGraphicsContext.currentContext.graphicsPort
        , gradient
        , NSMakePoint(5*self.bounds.size.width/8, 6*self.bounds.size.height/8), 0.000000
        , NSMakePoint(self.bounds.size.width/2, self.bounds.size.height/2), self.bounds.size.height/2
        , 0
    );
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithOvalInRect: self.bounds];
    [path stroke];

    
    // add clip here
}

@end
