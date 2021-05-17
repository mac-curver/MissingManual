//
//  GraphAxis.m
//  BodeDiagram
//
//  Created by Heinz-Jšrg on Sat Apr 19 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.

#import 	"GraphAxis.h"

#include	"myMath.h"
#import     "MyLog.h"


@implementation GraphAxis

- (id)init {
	conversionFactor	=  1;
	gridLogScale		= NO;
	gridSuffix 		= @"";
	
	return self;
}

- (id)initWithScientificView:(ScientificView *)view  {
    [self setView:view];
    gridRect = view->windowRect;

    return [self init];
}

- (void)    setView:(ScientificView *)view {
    scientificView = view;
}

- (void) lineAt:(double)position {
	NSLog(@"Call to virtual class methode: lineAt\n");
}

- (void) ticMark:(double)mark position:(double)z ticlength:(double)ticlength {
	NSLog(@"Call to virtual class methode: ticMark\n");
}

- (void) setUnit:(double)conversion
     logarithmic:(BOOL)isLog
          format:(NSString*)formatSuffix
{
	conversionFactor = conversion;
	gridLogScale = isLog;
	gridSuffix = [NSString stringWithString:formatSuffix];
}


- (void) logGridFrom:(double)logMin
                  to:(double)logMax
           lineWidth:(double)lineWidth
{
/*
 description:
 axis performs the drawing of a logarithmic grid to base 10. All
 decade lines and all 1st order subdivisions are drawn as lines.
	input:
		logMin:			log10(xmin) with xMin minimum horizontal value.
		logMax:			log10(xmax) with xMax maximum horizontal value.
		lineWidth:		width of the thin lines, decades are twice as thick.
	output:
		-
    example:
*/
	int		decade, subdecade;
	int		numDecades;														    // number of decades to be drawn
	int		incDecades = 1;													    // every decade to be drawn
	int		minDecade = floor(logMin+0.99);									    // left most decade
	int		maxDecade = floor(logMax+1.01);									    // right most decade
	
	numDecades = maxDecade-minDecade;
	incDecades = floor(numDecades/10);
	
	if (0 == incDecades) {													    // only if every decade is shown
		[NSBezierPath setDefaultLineWidth:lineWidth];						    // draw thin lines
			// draw up to 8 thin vertical lines
			for (subdecade = pow(10,(logMin-floor(logMin+0.01)));
                 subdecade <= 9; subdecade++) {
				[self lineAt:log10(subdecade)+floor(logMin+0.01)];
			}
		// for all decades inbetween
		for (decade = floor(logMin+1.01);
             decade < floor(logMax+0.01);
             decade++) {
			// draw 8 thin vertical lines
			for (subdecade = 2; subdecade <= 9; subdecade++) {										
				[self lineAt:log10(subdecade)+decade];
			}
		};
			// draw up to 8 thin lines
			for (subdecade = 2;
                 subdecade <= pow(10,(logMax-floor(logMax+0.01)));
                 subdecade++) {
				[self lineAt:log10(subdecade)+floor(logMax+0.01)];
			}
	}
	// draw the grid for the equidistant decades	
	if (1 > incDecades) incDecades = 1;
	[NSBezierPath setDefaultLineWidth:3*lineWidth];							    // draw thick decade lines
 	for (decade = minDecade; decade < maxDecade; decade += incDecades) {
		[self lineAt:decade*1.0];
	};
}

- (void) linTicsFrom:(double)origin
                 cut:(double)value
              length:(double)size
          separation:(double)space
                 tic:(double)ticlength andMajorEvery:(short)major
           lineWidth:(double)lineWidth
{
	double					mark;
	short					count = 0;
	int						magnitude;
	const int				maxDivisions = 10;								    // the maximum nuber of divisions if space is given

	// when spacing is not defined = 0 calculate an appropriate scale	
	if (0 == major) {
		major = 1;
	}
	if (fabs(space) < EPS) {												    // no space defined so we define it...
		space = pow(10.0, floor(log10(10.0/MAX_DIVISIONS*size)));			    // ... by ourselves
	} else if (size/maxDivisions > space) {									    // we want max about 10 divisions
		space = space * floor(size/(maxDivisions*space));					    // how fine shall we space
	}
	
	if (fabs(space) >= EPS) {
		magnitude	= major*floor((origin-0.5*space)/(space*major));		    // magnitude difference
		mark    	= magnitude * space;									    // location of 0th mark (modulo arithmetic)

		mark += space;														    // location of first space
		while (mark < origin-space/2) {
			count ++;														    // next location
			mark  += space;													    // location of first no mark
		}
		// draw the axis
		while (mark < origin+size) {
			count ++;														    // next location
			if (count % major == 0) {
				[NSBezierPath setDefaultLineWidth:3*lineWidth];				    // draw thick decade lines
				[self ticMark:mark position:value ticlength:ticlength];		    // plot major mark
			} else {
				[NSBezierPath setDefaultLineWidth:lineWidth];				    // draw thin lines
				[self ticMark:mark position:value ticlength:ticlength*0.5];	    // plot minor mark
			};
			mark  += space;													    // calc next position of mark
		}
	}
}

- (void)	   linTics:(double)y
            separation:(double)space
            ticPercent:(double)ticlength
         andMajorEvery:(short)major
             lineWidth:(double)lineWidth
{
	NSLog(@"Call to virtual class methode: linTics\n");
}

- (void)	logGrid:(double)lineWidth {
	NSLog(@"Call to virtual class methode: logGridFrom\n");
}

- (void)	setGridRect:(NSRect) myGrid {
	gridRect = myGrid;
}

- (NSString*) 	annotationStringWithFormat:(NSString*)format
                                      from:(double)value
{
	double			strValue;
	NSString		*outString;
	
	if (gridLogScale) {
		strValue = conversionFactor*log10(value);
	} else {
		strValue = conversionFactor*value;
	}
	outString	= [NSString stringWithFormat:format, strValue];				    // calculate proper string
	
	return	outString;
}

- (NSString*) 	automaticWithSuffix:(NSString*)myGridSuffix
                               from:(double)value
{
	NSString		*formatString;
	double			strValue;
	NSString		*outString;
	
	if (gridLogScale) {
		strValue = conversionFactor*log10(value);
	} else {
		strValue = conversionFactor*value;
	}
	int intValue = (int)log10(strValue+EPS);
	switch (intValue) {
		case -1:
			formatString = @"%-0.2f";
			break;
		case 0:
			formatString = @"%-0.1f";
			break;
		case 1:
			formatString = @"%-1.0f";
			break;
		case 2:
			formatString = @"%-2.0f";
			break;
		case 3:
			formatString = @"%-3.0f";
			break;
		case 4:
			formatString = @"%-4.0f";
			break;
		case 5:
			formatString = @"%-5.0f";
			break;
		default:
			formatString = @"%-1.1E";
			break;
	}			
	formatString = [formatString stringByAppendingString:myGridSuffix];

	outString	= [NSString stringWithFormat:formatString, strValue];		    // calculate proper string

	return	outString;
}


- (void)	linAnnotation:(double)origin                                        // grid rect minimum
                   length:(double)size                                          // grid rect maximum
                      cut:(double)cutValue                                      // location where the other axis crosses
               separation:(double)space                                         // space between tics
                alignment:(TextPosition)alignment                               // alignemnt of the annotation
              numberOfItems:(int)lengthInPixel                                // max number of annotation that could fit
{
  
	double					mark;											    // position of mark string om axis
	double					offset;											    // position of offset string in case there is not enough space
	NSString			   *markString;									        // mark or delta string
	NSString			   *offsetString;									    // mark with offset in case there is not enough space
	NSString			   *formatAdd;
	NSString			   *formatString;
	double					logSpace;
	int  					magnitude;
	BOOL					itsEnoughSpace;
	const int				maxDivisions = 10;								    // the maximum nuber of divisions if space is given
    const int               An = 27;                                            // Avoid negative argument for modf (limited to 27 digits!)

    //NSLog(@"o:%f c:%f s:%f %f", origin, cutValue, size, space);
	// when spacing is not defined = 0 calculate an appropriate scale
	if (fabs(space) < EPS) {												    // we have to do automatically
        
        double fraction = modf(An+log10(size/lengthInPixel), &logSpace);        // the greater less numbers are shown
        logSpace -= An;                                                         // correct the offset
		space 	 = pow(10.0, logSpace);										    // closest power 10 spacing
        if (fraction > 0.7) {
            space *= 5;                                                         // nearly next power of ten
        }
        else if (fraction > 0.3) {
            space *= 2;                                                         // reasonably larger
        }
    } else if (size/maxDivisions > space) {									    // we want max about 10 divisions
		space = space * floor(size/(maxDivisions*space));					    // how fine shall we space
		logSpace = floor(log10(space)+EPS);									    // how many decades
    } else {																    // space is given
		logSpace = floor(log10(space)+EPS);									    // how many decades
	}

	// draw the axix
	magnitude		= floor((origin+0.5*space)/(space*10));				        // magnitude difference
    
    

	itsEnoughSpace	= log10(abs(magnitude)+1) <= 3;
    offset			= cutValue;//magnitude * space;
	if (offset < origin) {													    // not visible
		if (offset +  10*space < origin+size) {								    // check next 10th multiple is visible?
			offset += 10*space;
		}
	}
	offsetString	= [self annotationStringWithFormat:@"%1.5E" from:offset];
	if (fabs(space) >= EPS) {
		if (itsEnoughSpace) {
			// display complete numbers
			offset = 0;
			formatString = [NSMutableString stringWithString:@"%-"];
		} else {
			// display just differences from markString offset
			formatString = [NSMutableString stringWithString:@"%+"];
		}
		switch ((int)logSpace) {
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
        
        
        mark  = cutValue - space;
        if (mark > origin+size) {
            mark = space * floor((+origin+size - cutValue)/space);
        }
        
	
		while (mark > origin) {
			markString	= [self annotationStringWithFormat:formatString
                                                     from:mark-offset];
			[self annotateMark:mark with:markString at:cutValue
                     alignment:alignment];
			mark  -= space;													    // calc next position of mark
		}
     
      
		if (itsEnoughSpace) {
			markString	= [self annotationStringWithFormat:formatString
                                                     from:mark-offset];
			[self annotateMark:mark with:markString at:cutValue
                     alignment:alignment];
		} else {
			[self annotateMark:offset with:offsetString at:cutValue
                     alignment:alignment];
		};
      
        
        mark = cutValue + space;
        if (mark < origin) {
            mark = space * floor((origin - cutValue)/space);
        }

		while (mark < origin+size) {
			markString	= [self annotationStringWithFormat:formatString
                                                     from:mark-offset];
			[self annotateMark:mark with:markString at:cutValue
                     alignment:alignment];
			mark  += space;													    // calc next position of mark
		}
	}
 
}




- (void)	annotateMark:(double)mark
                 with:(NSString *)markString
                   at:(double)position
            alignment:(TextPosition)alignment
{
	NSLog(@"Call to virtual class methode: annotateMark\n");
}

- (void)	logAnnotation:(double)origin
                   cut:(double)value
                length:(double)size
            separation:(double)space
             alignment:(TextPosition)alignment
{
	int				decade, subdecade;										    // temporary counters
	int				numDecades;												    // number of decades to be drawn
	int				minDecade = floor(origin+0.01);							    // left most decade
	int				maxDecade = floor(origin+size+0.01);					    // right most decade
	NSString		*formatString = @"%-3.0f";								    // changed according to contents 29.5.2010 hjs
	NSString		*markString;
	
			
	formatString = [formatString stringByAppendingString:gridSuffix];
	numDecades = maxDecade-minDecade;
	
	// draw the grid for the equidistant decades	
	if (1 >= numDecades) {
		double  start, stop1stDecade, stop;
		start          = pow(10,(origin-minDecade));						    // lowest number for annotation
		stop1stDecade  = pow(10,(origin+size-maxDecade));					    // highest number of annotation for 1st decade
		stop           = stop1stDecade;										    // highest number for 2nd decade
		if (stop1stDecade <= start) {
			stop1stDecade = 10;												    // we have 2 decades
		} else {
			stop = 1;														    // just one decade to display
		}
		// plot annotation for 1st decade
		for (subdecade = start; subdecade <= stop1stDecade; subdecade++) {
			// [NSString stringWithFormat:format, strValue]
			markString	= [self annotationStringWithFormat:formatString
                                from:pow(10, log10(subdecade)+minDecade)];
			[self annotateMark:log10(subdecade)+minDecade with:markString
                            at:value alignment:alignment];
		}
		// eventually plot annotation for 2nd decade
		for (subdecade = 2; subdecade <= stop; subdecade++) {
			markString	= [self annotationStringWithFormat:formatString
                                from:pow(10, log10(subdecade)+maxDecade)];
			[self annotateMark:log10(subdecade)+maxDecade with:markString
                            at:value alignment:alignment];
		}
	} else {
		int incDecades = floor(numDecades/10);								    // avoid too dense annotation
		if (1 > incDecades) incDecades = 1;
		// annotate decades only
		for (decade = minDecade; decade <= maxDecade; decade += incDecades) {
			markString	= [self automaticWithSuffix:gridSuffix
                                              from:pow(10, decade)
                          ];
			[self annotateMark:decade with:markString at:value
                     alignment:alignment
            ];			
		};
	}
}

- (void)	logAnnotation:(double)logMin
                       to:(double)logMax
{
}



@end
