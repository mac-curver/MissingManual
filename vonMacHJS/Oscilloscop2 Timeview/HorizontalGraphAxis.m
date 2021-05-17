//
//  HorizontalGraphAxis.m
//  BodeDiagram
//
//  Created by Heinz-Jšrg on Sat Apr 19 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.

#import 	"HorizontalGraphAxis.h"
#import 	"ScientificView.h"

@implementation HorizontalGraphAxis
/*
- (IBAction)drawAxis:(id)sender
{
}
*/

- (void)	lineAt:(float)position
{
	[scientificView moveto:position :gridRect->origin.y];
	[scientificView drawto:position :gridRect->origin.y+gridRect->size.height];
}

- (void)	ticMark:(float)mark position:(float)z ticlength:(float)ticlength
{
	[scientificView moveto:mark	:z-ticlength];						// plot mark
	[scientificView drawto:mark	:z+ticlength];
}

- (void)	linTics:(float)y separation:(float)space ticPercent:(float)ticlength andMajorEvery:(short)major  lineWidth:(float)lineWidth 
{
	[self linTicsFrom:gridRect->origin.x cut:y length:gridRect->size.width separation:space tic:ticlength*gridRect->size.height/100.0 andMajorEvery:major  lineWidth:lineWidth];
}

- (void)	logGrid:(float)lineWidth
{
	[self logGridFrom:gridRect->origin.x to:gridRect->origin.x+gridRect->size.width lineWidth:lineWidth];
}

- (void)	logAnnotation:(float)y separation:(float)space alignment:(int)alignment
{
	[self logAnnotation:gridRect->origin.x cut:y length:gridRect->size.width separation:space alignment:alignment];
}

- (void)	linAnnotation:(float)y separation:(float)space alignment:(int)alignment
{
	[self linAnnotation:gridRect->origin.x cut:y length:gridRect->size.width separation:space alignment:alignment];
}

- (void)	annotateMark:(double)mark with:(NSString *)markString at:(double)position alignment:(int)alignment
{
	[scientificView moveto:mark :position];
	[scientificView drawString:markString alignment:alignment];
}

@end
