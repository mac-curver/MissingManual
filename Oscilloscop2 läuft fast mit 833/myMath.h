//
//  myMath.h
//  BodeDiagram
//
//  Created by Heinz-Jšrg on Sat Jun 07 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.
//

#define			PI				M_PI							                // 3.14159265358979323846
#define			E				M_E								                // 2.7... machine e
#define			MAXNUMBER		((float)10.0E6)					                // largest number (MAXFLOAT is too big)
#define			EPS				((float)1.0/MAXNUMBER)			                // smallest number != 0
#define			MAX_SAMPLES		1024							                // number of points in plot
#define			MAX_DIVISIONS	35								                // max division in linear grid
#define			ANNOTATE_VERT	14								                // max division for vert. annotation
#define			ANNOTATE_HORIZ	6								                // max division for horiz. annotation

float calculateLog10(double value);								                // log10 with protection against neg. values

double randDouble(void);

