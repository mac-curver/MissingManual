////  myMath.m//  BodeDiagram////  Created by LegoEsprit on Sat Jun 07 2003.//  Copyright (c) 2003 LegoEsprit. All rights reserved.//#import		<Cocoa/Cocoa.h>#import		"myMath.h"double calculateLog10(double value) {	if (value < EPS) value = EPS;	return log10(value);}