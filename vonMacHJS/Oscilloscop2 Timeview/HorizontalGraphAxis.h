//
//  HorizontalGraphAxis.h
//  BodeDiagram
//
//  Created by Heinz-J�rg on Sat Apr 19 2003.
//  Copyright (c) 2003 Heinz-J�rg SCHR�DER. All rights reserved.

#import 	<Cocoa/Cocoa.h>
#import 	"GraphAxis.h"
@class		GraphAxis;

@interface HorizontalGraphAxis : GraphAxis
{
//    IBOutlet id horizontalAxis;
}
//- (IBAction)drawAxis:(id)sender;

- (void)	lineAt:(float)position;
- (void)	ticMark:(float)mark position:(float)z ticlength:(float)ticlength;
- (void)	linTics:(float)x separation:(float)space ticPercent:(float)ticlength andMajorEvery:(short)major  lineWidth:(float)lineWidth;
- (void)	logGrid:(float)lineWidth;
- (void)	logAnnotation:(float)y separation:(float)space alignment:(int)alignment;
- (void)	linAnnotation:(float)y separation:(float)space alignment:(int)alignment;
- (void)	annotateMark:(double)mark with:(NSString *)markString at:(double)position alignment:(int)alignment;

@end
