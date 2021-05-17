//
//  NSViewExtensions.h
//  Polygons
//
//  Created by jcr on Mon Apr 29 2002.
//  Copyright (c) 2002 Apple Computer, Inc. All rights reserved.
//

#import <AppKit/AppKit.h>

NSRect			NSMakeRectFromPoints(NSPoint point1, NSPoint point2);



@interface NSView (SomeGeometryExtensions)

- (void) 	centerOriginInBounds;
- (void) 	centerOriginInFrame;
- (void) 	centerOriginInRect:(NSRect) aRect;

@end


