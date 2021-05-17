//
//  GraphAxis.m
//  BodeDiagram
//
//  Created by Heinz-J�rg on Sat Apr 19 2003.
//  Copyright (c) 2003 Heinz-J�rg SCHR�DER. All rights reserved.

#import 	"GraphAxis.h"
#import 	"ScientificView.h"

#include	"myMath.h"

@implementation GraphAxis

- (id)	init
{
	conversionFactor	=  1;
	gridLogScale		= NO;
	gridSuffix 		= [NSString stringWithString:@""];
	[gridSuffix autorelease];
	[gridSuffix retain];
	
	return self;
}

- (void)	lineAt:(float)position
{
	NSLog(@"Call to virtual class methode: lineAt\n");
}

- (void)	ticMark:(float)mark position:(float)z ticlength:(float)ticlength
{
	NSLog(@"Call to virtual class methode: ticMark\n");
}

- (void)	setUnit:(double)conversion logarithmic:(BOOL)isLog format:(NSString*)formatSuffix
{
	conversionFactor = conversion;
	gridLogScale = isLog;
	gridSuffix = [NSString stringWithString:formatSuffix];
	//[gridSuffix autorelease];
	[gridSuffix retain];
}


- (void)	logGridFrom:(float)logMin to:(float)logMax lineWidth:(float)lineWidth
/*
	description:
	axis performs the drawing of a logarithmic grid to base 10. All decade lines and all 1st 
	order subdivisions are drawn as lines.
	input:
		logMin:					log10(xmin) with xMin minimum horizontal value.
		logMax:					log10(xmax) with xMax maximum horizontal value.
		lineWidth:				width of the thin lines, decades are twice as thick.
	output:
		-
	example:
*/
{
	int		decade, subdecade;
	int		numDecades;												// number of decades to be drawn
	int		incDecades = 1;											// every decade to be drawn
	int		minDecade = floor(logMin+0.99);							// left most decade
	int		maxDecade = floor(logMax+1.01);							// right most decade
	
	numDecades = maxDecade-minDecade;
	incDecades = floor(numDecades/10);
	
	if (0 == incDecades) {											// only if every decade is shown
		[NSBezierPath setDefaultLineWidth:lineWidth];				// draw thin lines
			// draw up to 8 thin vertical lines
			for (subdecade = pow(10,(logMin-floor(logMin+0.01))); subdecade <= 9; subdecade++) {
				[self lineAt:log10(subdecade)+floor(logMin+0.01)];
			}
		// for all decades inbetween
		for (decade = floor(logMin+1.01); decade < floor(logMax+0.01); decade++) {	
			// draw 8 thin vertical lines
			for (subdecade = 2; subdecade <= 9; subdecade++) {										
				[self lineAt:log10(subdecade)+decade];
			}
		};
			// draw up to 8 thin lines
			for (subdecade = 2; subdecade <= pow(10,(logMax-floor(logMax+0.01))); subdecade++) {
				[self lineAt:log10(subdecade)+floor(logMax+0.01)];
			}
	}
	// draw the grid for the equidistant decades	
	if (1 > incDecades) incDecades = 1;
	[NSBezierPath setDefaultLineWidth:3*lineWidth];					// draw thick decade lines
 	for (decade = minDecade; decade < maxDecade; decade += incDecades) {
		[self lineAt:decade*1.0];
	};
}

- (void)	linTicsFrom:(float)origin cut:(float)value length:(float)size separation:(float)space tic:(float)ticlength andMajorEvery:(short)major lineWidth:(float)lineWidth
{
	float					mark;
	short					count = 0;
	int						magnitude;
	const int				maxDivisions = 10;						// the maximum nuber of divisions if space is given

	// when spacing is not defined = 0 calculate an appropriate scale	
	if (0 == major) {
		major = 1;
	}
	if (fabs(space) < EPS) {										// no spce defined so we define it...
		space = pow(10.0, floor(log10(10.0/MAX_DIVISIONS*size)));	// ... by ourselves
	} else if (size/maxDivisions > space) {							// we want max about 10 divisions
		space = space * floor(size/(maxDivisions*space));			// how fine shall we space
	}
	
	if (fabs(space) >= EPS) {
		magnitude	= major*floor((origin-0.5*space)/(space*major));// magnitude difference
		mark    	= magnitude * space;							// location of 0th mark (modulo arithmetic)

		mark += space;												// location of first space
		while (mark < origin-space/2) {
			count ++;												// next location
			mark  += space;											// location of first no mark
		}
		// draw the axix
		while (mark < origin+size) {
			count ++;												// next location
			if (count % major == 0) {
				[NSBezierPath setDefaultLineWidth:3*lineWidth];		// draw thick decade lines
				[self ticMark:mark position:value ticlength:ticlength];	// plot major mark
			} else {
				[NSBezierPath setDefaultLineWidth:lineWidth];		// draw thin lines
				[self ticMark:mark position:value ticlength:ticlength*0.5];	// plot minor mark
			};
			mark  += space;											// calc next position of mark
		}
	}
}

- (void)	linTics:(float)y separation:(float)space ticPercent:(float)ticlength andMajorEvery:(short)major lineWidth:(float)lineWidth
{
	NSLog(@"Call to virtual class methode: linTics\n");
}

- (void)	logGrid:(float)lineWidth
{
	NSLog(@"Call to virtual class methode: logGridFrom\n");
}

- (void)	setGridRect:(NSRect *)myGrid
{
	gridRect = myGrid;
}

- (NSString*) 	annotationStringWithFormat:(NSString*)format from:(double)value
{
	double			strValue;
	NSString		*outString;
	
	if (gridLogScale) {
		strValue = conversionFactor*log10(value);
	} else {
		strValue = conversionFactor*value;
	}
	outString	= [NSString stringWithFormat:format, strValue];	// calculate proper string
	[outString autorelease];
	[outString retain];
	
	return	outString;
}

- (void)	linAnnotation:(double)origin cut:(double)value length:(double)size separation:(double)space alignment:(int)alignment
{
	double					mark;
	double					offset;
	NSString				*markString;
	NSString				*offsetString;
	NSString				*formatAdd;
	NSString				*formatString;
	int						logSpace;
	int						magnitude;
	BOOL					itsEnoughSpace;
	const int				maxDivisions = 10;						// the maximum nuber of divisions if space is given

	// when spacing is not defined = 0 calculate an appropriate scale	
	if (fabs(space) < EPS) {										// we have to do automatically
		logSpace = floor(log10(10.0/ANNOTATE_VERT*size)+0.00001);	// how many decades
		space 	 = pow(10, logSpace);								// 
	} else if (size/maxDivisions > space) {							// we want max about 10 divisions
		space = space * floor(size/(maxDivisions*space));			// how fine shall we space
		logSpace = floor(log10(space)+0.00001);						// how many decades
	} else {														// space is given
		logSpace = floor(log10(space)+0.00001);						// how many decades
	}

	// draw the axix
	magnitude		= 10*floor((origin+0.5*space)/(space*10));		// magnitude difference
	itsEnoughSpace	= log10(abs(magnitude)+1) <= 3;
	mark			= magnitude * space;							// location of 0th mark (modulo arithmetic)
	offset			= mark;
	if (offset < origin) {											// not visible
		if (offset + 10*space < origin+size) {						// check next 10th multiple is visible?
			offset += 10*space;
		}
	}
	offsetString	= [self annotationStringWithFormat:@"%1.5E" from:offset];
	if (fabs(space) >= EPS) {
		while (mark < origin) {
			mark  += space;											// location of first no mark
		}
		if (itsEnoughSpace) {
			// display complete numbers
			offset = 0;
			formatString = [NSMutableString stringWithString:@"%-"];
		} else {
			// display just differences from markString offset
			formatString = [NSMutableString stringWithString:@"%+"];
		}
		switch (logSpace) {
			case -3:
				formatAdd = @"0.3f";
				break;
			case -2:
				formatAdd = @"0.2f";
				break;
			case -1:
				formatAdd = @"1.1f";
				break;
			case -0:
				formatAdd = @"2.0f";
				break;
			case 1:
				formatAdd = @"3.0f";
				break;
			case 2:
				formatAdd = @"4.0f";
				break;
			case 3:
				formatAdd = @"5.0f";
				break;
			case 4:
				formatAdd = @"6.0f";
				break;
			case 5:
				formatAdd = @"7.0f";
				break;
			default:
				formatAdd = @"1.2E";
		}
		formatString = [formatString stringByAppendingString:formatAdd];
		formatString = [formatString stringByAppendingString:gridSuffix];
		[formatString autorelease];
		[formatString retain];
	
		while (mark < offset) {
			markString	= [self annotationStringWithFormat:formatString from:mark-offset];
			[self annotateMark:mark with:markString at:value alignment:alignment];
			mark  += space;											// calc next position of mark
		}
		if (itsEnoughSpace) {
			markString	= [self annotationStringWithFormat:formatString from:mark-offset];
			[self annotateMark:mark with:markString at:value alignment:alignment];
		} else {
			[self annotateMark:offset with:offsetString at:value alignment:alignment];
		};
		mark  += space;												// skip next position of mark
		while (mark < origin+size+space/2) {
			markString	= [self annotationStringWithFormat:formatString from:mark-offset];
			[self annotateMark:mark with:markString at:value alignment:alignment];
			mark  += space;											// calc next position of mark
		}
	}
}



- (void)	annotateMark:(double)mark with:(NSString *)markString at:(double)position alignment:(int)alignment
{
	NSLog(@"Call to virtual class methode: annotateMark\n");
}

- (void)	logAnnotation:(float)origin cut:(float)value length:(double)size separation:(double)space alignment:(int)alignment
{
	int				decade, subdecade;								// temprary counters
	int				numDecades;										// number of decades to be drawn
	int				minDecade = floor(origin+0.01);					// left most decade
	int				maxDecade = floor(origin+size+0.01);			// right most decade
	NSString		*formatString = @"%-3.0f";
	NSString		*markString;
	
	formatString = [formatString stringByAppendingString:gridSuffix];
	[formatString autorelease];
	[formatString retain];
	numDecades = maxDecade-minDecade;
	
	// draw the grid for the equidistant decades	
	if (1 >= numDecades) {
		double  start, stop1stDecade, stop;
		start          = pow(10,(origin-minDecade));				// lowest number for annotation
		stop1stDecade  = pow(10,(origin+size-maxDecade));			// highest number of annotation for 1st decade
		stop           = stop1stDecade;								// highest number for 2nd decade
		if (stop1stDecade <= start) {
			stop1stDecade = 10;										// we have 2 decades
		} else {
			stop = 1;												// just one decade to display
		}
		// plot annotation for 1st decade
		for (subdecade = start; subdecade <= stop1stDecade; subdecade++) {
			// [NSString stringWithFormat:format, strValue]
			markString	= [self annotationStringWithFormat:formatString from:pow(10, log10(subdecade)+minDecade)];
			[self annotateMark:log10(subdecade)+minDecade with:markString at:value alignment:alignment];			
		}
		// eventually plot annotation for 2nd decade
		for (subdecade = 2; subdecade <= stop; subdecade++) {
			markString	= [self annotationStringWithFormat:formatString from:pow(10, log10(subdecade)+maxDecade)];
			[self annotateMark:log10(subdecade)+maxDecade with:markString at:value alignment:alignment];			
		}
	} else {
		int incDecades = floor(numDecades/10);								// avoid too dense annotation
		if (1 > incDecades) incDecades = 1;
		// annotate decades only
		for (decade = minDecade; decade <= maxDecade; decade += incDecades) {
			markString	= [self annotationStringWithFormat:formatString from:pow(10, decade)];
			[self annotateMark:decade with:markString at:value alignment:alignment];			
		};
	}
}

- (void)	logAnnotation:(float)logMin to:(float)logMax 
{
}



@end
