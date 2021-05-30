//
//  HorizontalGraphAxis.m
//  BodeDiagram
//
//  Created by LegoEsprit on Sat Apr 19 2003.
//  Copyright (c) 2003 LegoEsprit. All rights reserved.

#import 	"HorizontalGraphAxis.h"
#import 	"ScientificView.h"



@implementation HorizontalGraphAxis



- (void)	lineAt:(double)position {
    [scientificView moveto:gridRect.origin.x                     :position];
    [scientificView drawto:gridRect.origin.x+gridRect.size.width :position];
}

- (void) ticMark:(double)mark position:(double)y ticlength:(double)ticlength {
	[scientificView moveto:mark	:y-ticlength];								    // plot mark vertical line
	[scientificView drawto:mark	:y+ticlength];
}

- (void)	linTics:(double)y separation:(double)space
    ticPercent:(double)ticlength andMajorEvery:(short)major
     lineWidth:(double)lineWidth
{
    [self linTicsFrom:gridRect.origin.x cut:y length:gridRect.size.width
           separation:space tic:ticlength*gridRect.size.height/100.0
        andMajorEvery:major lineWidth:lineWidth
    ];
}

- (void)	logGrid:(double)lineWidth {
	[self logGridFrom:gridRect.origin.x
                   to:gridRect.origin.x+gridRect.size.width
            lineWidth:lineWidth
    ];
}

- (void)	logAnnotation:(double)y separation:(double)space
             alignment:(TextPosition)alignment
{
	[self logAnnotation:gridRect.origin.x cut:y length:gridRect.size.width
             separation:space alignment:alignment
    ];
}

- (void)	linAnnotation:(double)y separation:(double)space
                                    alignment:(TextPosition)alignment
{
	[self linAnnotation:gridRect.origin.x length:gridRect.size.width
                    cut:y 
             separation:space
              alignment:alignment
            numberOfItems:0.008*scientificView.bounds.size.width
    ];
}

- (void)	annotateMark:(double)mark with:(NSString *)markString
                      at:(double)position alignment:(TextPosition)alignment
{
	[scientificView moveto:mark :position];
	[scientificView drawString:markString alignment:alignment];
}

@end
