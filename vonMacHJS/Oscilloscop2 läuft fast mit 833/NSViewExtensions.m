//
//  NSViewExtensions.m
//  Polygons
//
//  Created by jcr on Thu May 02 2002.
//  Copyright (c) 2002  Apple Computer, Inc. All rights reserved.
//

#import "NSViewExtensions.h"

//------------------------------------------------------------------------------
//	suplementary graphics routines
//------------------------------------------------------------------------------


NSRect	NSMakeRectFromPoints(NSPoint point1, NSPoint point2) 
{
    return NSMakeRect(
         ((point1.x <= point2.x) ? point1.x : point2.x),
         ((point1.y <= point2.y) ? point1.y : point2.y),
         ((point1.x <= point2.x) ? point2.x - point1.x : point1.x - point2.x),
         ((point1.y <= point2.y) ? point2.y - point1.y : point1.y - point2.y)
    );
}


@implementation NSView (SomeGeometryExtensions)

- (void) centerOriginInBounds { [self centerOriginInRect:[self bounds]];  }
- (void) centerOriginInFrame  { [self centerOriginInRect:
                                    [self convertRect:[self frame]
                                             fromView:[self superview]]];
                              }
- (void) centerOriginInRect:(NSRect) aRect {
                                [self translateOriginToPoint:
                                    NSMakePoint(NSMidX(aRect), NSMidY(aRect))
                                 ];
                              }
  
@end

