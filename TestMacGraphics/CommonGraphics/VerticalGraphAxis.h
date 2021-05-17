//
//  VerticalGraphAxis.h
//  BodeDiagram
//
//  Created by Heinz-Jšrg on Sat Apr 19 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.

#import		<Cocoa/Cocoa.h>
#import 	"GraphAxis.h"
@class		GraphAxis;

@interface VerticalGraphAxis: GraphAxis {
//    IBOutlet id verticalAxis;
}
//- (IBAction)drawAxis:(id)sender;

- (void)	lineAt:(double)position;

- (void)	ticMark:(double)mark
                position:(double)z
               ticlength:(double)ticlength;

- (void)	linTics:(double)x
                separation:(double)space
                ticPercent:(double)ticlength
             andMajorEvery:(short)major
                 lineWidth:(double)lineWidth;

- (void)	logGrid:(double)lineWidth;

- (void)	logAnnotation:(double)x
                separation:(double)space
                 alignment:(int)alignment;

- (void)	linAnnotation:(double)x
                separation:(double)space
                 alignment:(int)alignment;

- (void)	annotateMark:(double)mark
                    with:(NSString *)markString
                      at:(double)position
               alignment:(int)alignment;

@end
