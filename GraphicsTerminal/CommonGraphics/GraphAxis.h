//
//  GraphAxis.h
//  BodeDiagram
//
//  Created by LegoEsprit on Sat Apr 19 2003.
//  Copyright (c) 2003 LegoEsprit. All rights reserved.

#import		<Cocoa/Cocoa.h>
#import     "ScientificView.h"


@interface GraphAxis: NSObject {
    IBOutlet ScientificView	*scientificView;
	NSRect					 gridRect;
	double					 conversionFactor;
	BOOL					 gridLogScale;
	NSString				*gridSuffix;
}

- (id)      initWithScientificView:(ScientificView *)view;

- (void)    setView:(ScientificView *) view;

- (void)	lineAt:(double)position;

- (void)	ticMark:(double)mark position:(double)z
                                ticlength:(double)ticlength;

- (void)	setUnit:(double)conversion logarithmic:(BOOL)isLog
                                            format:(NSString*)formatSuffix;

- (void)	logGridFrom:(double)logMin to:(double)logMax
                                lineWidth:(double)lineWidth;

- (void)	linTicsFrom:(double)origin cut:(double)value
                                    length:(double)size
                                separation:(double)space
                                       tic:(double)ticlength
                             andMajorEvery:(short)major
                                 lineWidth:(double)lineWidth;

- (void)	linTics:(double)x separation:(double)space
                             ticPercent:(double)ticlength
                          andMajorEvery:(short)major
                              lineWidth:(double)lineWidth;

- (void)	logGrid:(double)lineWidth;

- (void)	setGridRect:(NSRect)myGrid;

- (void)	logAnnotation:(double)logMin to:(double)logMax;

- (void)	logAnnotation:(double)origin cut:(double)value
                                     length:(double)size
                                 separation:(double)space
                                  alignment:(TextPosition)alignment;

- (void)	linAnnotation:(double)origin
                                      length:(double)size
                                         cut:(double)value
                                  separation:(double)space
                                   alignment:(TextPosition)alignment
                                 numberOfItems:(int)lengthInPixel;


- (void)	annotateMark:(double)mark with:(NSString *)markString
                                        at:(double)position
                                 alignment:(TextPosition)alignment;

@end
