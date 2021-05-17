//
//  GraphAxis.h
//  BodeDiagram
//
//  Created by Heinz-Jšrg on Sat Apr 19 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.

#import		<Cocoa/Cocoa.h>
@class		ScientificView;


@interface GraphAxis : NSObject
{
    IBOutlet ScientificView	*scientificView;
	NSRect					*gridRect;
	double					conversionFactor;
	BOOL					gridLogScale;
	NSString				*gridSuffix;
}
- (void)	lineAt:(float)position;
- (void)	ticMark:(float)mark position:(float)z ticlength:(float)ticlength;
- (void)	setUnit:(double)conversion logarithmic:(BOOL)isLog format:(NSString*)formatSuffix;
- (void)	logGridFrom:(float)logMin to:(float)logMax lineWidth:(float)lineWidth;
- (void)	linTicsFrom:(float)origin cut:(float)value length:(float)size separation:(float)space tic:(float)ticlength andMajorEvery:(short)major lineWidth:(float)lineWidth;
- (void)	linTics:(float)x separation:(float)space ticPercent:(float)ticlength andMajorEvery:(short)major  lineWidth:(float)lineWidth;
- (void)	logGrid:(float)lineWidth;
- (void)	setGridRect:(NSRect *)myGrid;
- (void)	logAnnotation:(float)logMin to:(float)logMax;
- (void)	logAnnotation:(float)origin cut:(float)value length:(double)size separation:(double)space alignment:(int)alignment;
- (void)	linAnnotation:(double)origin cut:(double)value length:(double)size separation:(double)space alignment:(int)alignment;
- (void)	annotateMark:(double)mark with:(NSString *)markString at:(double)position alignment:(int)alignment;

@end
