//
//  VerticalGraphAxis.m
//  BodeDiagram
//
//  Created by Heinz-Jšrg on Sat Apr 19 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.

#import 	"VerticalGraphAxis.h"
#import 	"ScientificView.h"

@implementation VerticalGraphAxis
/*
- (IBAction)drawAxis:(id)sender
{
}
*/
- (void)	lineAt:(float)position
{
	[scientificView moveto:gridRect->origin.x						:position];
	[scientificView drawto:gridRect->origin.x+gridRect->size.width	:position];
}

- (void)	ticMark:(float)mark position:(float)z ticlength:(float)ticlength
{
	[scientificView moveto:z-ticlength	:mark];						// plot mark
	[scientificView drawto:z+ticlength	:mark];
}

- (void)	linTics:(float)x separation:(float)space ticPercent:(float)ticlength andMajorEvery:(short)major  lineWidth:(float)lineWidth
{
	[self linTicsFrom:gridRect->origin.y cut:x length:gridRect->size.height separation:space tic:ticlength*gridRect->size.width/100.0 andMajorEvery:major lineWidth:(float)lineWidth];
}

- (void)	logGrid:(float)lineWidth
{
	[self logGridFrom:gridRect->origin.y to:gridRect->origin.y+gridRect->size.height lineWidth:lineWidth];
}

- (void)	logAnnotation:(float)x separation:(float)space alignment:(int)alignment
{
	[self logAnnotation:gridRect->origin.y cut:x length:gridRect->size.height separation:space alignment:alignment];
}

- (void)	linAnnotation:(float)x separation:(float)space alignment:(int)alignment
{
	[self linAnnotation:gridRect->origin.y cut:x length:gridRect->size.height separation:space alignment:alignment];
}

- (void)	annotateMark:(double)mark with:(NSString *)markString at:(double)position alignment:(int)alignment
{
	[scientificView moveto:position :mark];
	[scientificView drawString:markString alignment:alignment];
}


@end
