////  myMath.h//  BodeDiagram////  Created by LegoEsprit on Sat Jun 07 2003.//  Copyright (c) 2003 LegoEsprit. All rights reserved.//#define			PI				M_PI							                // 3.14159265358979323846#define			E				M_E								                // 2.7... machine e#define			MAXNUMBER		((double)10.0E6)					            // largest number (MAXdouble is too big)#define			EPS				((double)1.0/MAXNUMBER)			                // smallest number != 0#define			MAX_SAMPLES		1024							                // number of points in plot#define			MAX_DIVISIONS	65								                // max division in linear griddouble          calculateLog10(double value);								    // log10 with protection against neg. values