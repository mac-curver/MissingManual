//
//  NSViewExtensions.h
//  Polygons
//
//  Created by jcr on Mon Apr 29 2002.
//  Copyright (c) 2002 Apple Computer, Inc. All rights reserved.
//

#import <AppKit/AppKit.h>

NSRect			NSMakeRectFromPoints(NSPoint point1, NSPoint point2);
NSRect          NSMakeZoomedRectFrom(double scale, NSRect rect1, NSRect rect2);
NSPoint         NSSubtractPoints(NSPoint point1, NSPoint point2);
NSPoint         NSAddPoints(NSPoint point1, NSPoint point2);
NSPoint         NSScalePoint(double value, NSPoint point);
NSSize          NSSubtractSizes(NSSize size1, NSSize size2);
NSSize          NSAddSizes(NSSize size1, NSSize size2);
NSSize          NSScaleSize(double value, NSSize size);


@interface NSView (SomeGeometryExtensions)

- (void) 	centerOriginInBounds;
- (void) 	centerOriginInFrame;
- (void) 	centerOriginInRect:(NSRect) aRect;

@end




