//
//  NSViewExtensions.m
//  Polygons
//
//  Created by jcr on Thu May 02 2002.
//  Copyright (c) 2002  Apple Computer, Inc. All rights reserved.
//

#import "NSViewExtensions.h"

//-------------------------------------------------------------------------------------
//	suplementary graphics routines
//-------------------------------------------------------------------------------------


NSRect	NSMakeRectFromPoints(NSPoint point1, NSPoint point2) {
    return NSMakeRect(
        ((point1.x <= point2.x) ? point1.x : point2.x),
        ((point1.y <= point2.y) ? point1.y : point2.y),
        ((point1.x <= point2.x) ? point2.x - point1.x : point1.x - point2.x),
        ((point1.y <= point2.y) ? point2.y - point1.y : point1.y - point2.y)
    );
}

NSRect  NSMakeZoomedRectFrom(double scale, NSRect rect1, NSRect rect2) {
    return NSMakeRect(
          rect2.origin.x    + scale*(rect1.origin.x    - rect2.origin.x   )
        , rect2.origin.y    + scale*(rect1.origin.y    - rect2.origin.y   )
        , rect2.size.width  + scale*(rect1.size.width  - rect2.size.width )
        , rect2.size.height + scale*(rect1.size.height - rect2.size.height)
    );
}

NSPoint  NSSubtractPoints(NSPoint point1, NSPoint point2) {
    return NSMakePoint(point1.x-point2.x, point1.y-point2.y);
}


NSPoint  NSAddPoints(NSPoint point1, NSPoint point2) {
    return NSMakePoint(point1.x+point2.x, point1.y+point2.y);
}

NSPoint  NSScalePoint(double value, NSPoint point) {
    return NSMakePoint(value*point.x, value*point.y);
}



NSSize   NSSubtractSizes(NSSize size1, NSSize size2) {
    return NSMakeSize(size1.width-size2.width, size1.height-size2.height);
}

NSSize   NSAddSizes(NSSize size1, NSSize size2) {
    return NSMakeSize(size1.width+size2.width, size1.height+size2.height);
}

NSSize  NSScaleSize(double value, NSSize size) {
    return NSMakeSize(value*size.width, value*size.height);
}


@implementation NSView (SomeGeometryExtensions)

- (void) centerOriginInBounds { [self centerOriginInRect:[self bounds]];  }
- (void) centerOriginInFrame  { [self centerOriginInRect:
                                 [self convertRect:[self frame]
                                          fromView:[self superview]]];
                              }
- (void) centerOriginInRect:(NSRect) aRect {
    [self translateOriginToPoint:NSMakePoint(NSMidX(aRect), NSMidY(aRect))];
}
  
@end

