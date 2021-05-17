//
//  myMath.m
//  BodeDiagram
//
//  Created by Heinz-J�rg on Sat Jun 07 2003.
//  Copyright (c) 2003 Heinz-J�rg SCHR�DER. All rights reserved.
//
#import		<Cocoa/Cocoa.h>
#import		"myMath.h"


float calculateLog10(double value) {
	if (value < EPS) value = EPS;
	return log10(value);
}



// Returns a random floating point number between [0.0, 1.0[
double randDouble(void) {
    return ((double) rand() / (double) RAND_MAX);
}
