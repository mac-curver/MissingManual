//
//  MyView.h
//  BodeDiagram
//
//  Created by Heinz-Jšrg on Sat Apr 19 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "GraphAxis.h"

//static double	**aArrayPointer, **bArrayPointer;	// reserved word static absolutely necessary. Otherwise crash of compiler with message: See log for details!?

@class PreferencesWindow;
@class FilterWindow;
@class HorizontalGraphAxis;
@class VerticalGraphAxis;
@class GraphAxis;									// should be replaced by HorizontalGraphAxis and VerticalGraphAxis%%%%%

@interface MyView : NSView
{
    IBOutlet PreferencesWindow 		*prefWindow;
    IBOutlet FilterWindow			*filterWindow;
    IBOutlet GraphAxis				*horizontalAxis;
    IBOutlet GraphAxis				*verticalAxis;
    IBOutlet GraphAxis				*secondaryAxis;
    IBOutlet NSTextField			*frequencyValue;
    IBOutlet NSTextField			*gainValue;
    IBOutlet NSTextField			*phaseValue;
    IBOutlet NSButton 				*unwrapPhase;	// connected to preferences window
	
	NSString			*string;					// last string
	NSFont				*font;						// current text font
	NSRect				viewRect;					// rect inside view where drawing takes place in global coordinates
@public 
    NSRect				windowRect;					// maximum window in user coordinates 
													// offset to origin
													// width = 1/xScale, height = 1/yScale
    NSRect				secondaryRect;				// secondary window in user coordinates
    NSRect				*currentRect;				// either windowRect or secondaryRect
	double				x_scale;
	double				x_offset;
	double				y_scale;
	double				y_offset;

	NSRect				rubberbandRect;				// for the selection
	BOOL				penIsDown;					// for plot statement to indicate penstate
	NSPoint				cursorPosition;				// last point drawn
	float				myValue;					// arbritary value
	BOOL				logarithmicX;				// true if log display
	BOOL				logarithmicY;				// true if log display
@public 
	int					currentState;				// state: zoom-in, zoom-out, drag, etc
	int					samples;
	double				*xArray;					// x-array
	double				*yArray;					// gain values
	double				*phaseArray;				// phase values
}

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)openFilterCoefficients:(id)sender;
- (IBAction)openPreferences:(id)sender;

- (void)	zoomInFromPoint:(NSPoint)mouseLoc;
- (void)	zoomOutFromPoint:(NSPoint)mouseLoc;
- (void)	zoomInToRect:(NSRect)mouseRect;
- (void)	setLogX:(BOOL)isLogXScale;
- (void)	setLogY:(BOOL)isLogYScale;
- (BOOL)	getLogX;
- (BOOL)	getLogY;
- (void)	windowFromX:(float)xmin ToX:(float)xmax AndFromY:(float)ymin ToY:(float)ymax;
- (void)	secondaryFromX:(float)xmin ToX:(float)xmax AndFromY:(float)ymin ToY:(float)ymax;
- (void)	secondaryFromX:(float)xmin ToX:(float)xmax;
- (NSRect)	getWindowRect;												// return coordinate rect
- (void)	penup;
- (void)	pendown;
- (void)	lineWidth:(float)width;
- (void)	move:(float)dx :(float)dy;									// move relative
- (void)	moveto:(float)x :(float)y;									// move absolute
- (void)	draw:(float)dx :(float)dy;									// draw relative
- (void)	drawto:(float)x :(float)y;									// draw absolute
- (void)	plot:(float)dx :(float)dy;									// plot relative 
- (void)	plotto:(float)x :(float)y;									// plot absolute
- (void)	myCircleAtX:(float)cx AtY:(float)cy radius:(float)radius;	// plot a circle
- (id)		initWithFrame:(NSRect)frame;								// initialization routine
- (void)	setString:(NSString *)value;								// set a string text
- (void)	setFont:(NSFont *)value;									// set font
- (void)	setValue:(float)value;										// set value
- (void)	setSamples:(int)numSamples;
- (double *)allocXData;
- (double *)allocYData;
- (double *)allocPhaseData;
- (double)	minX;														// returns minimum x-value
- (double)	maxX;														// returns maximum x-value
- (void)	paintCrosshair:(const NSRect*) bounds;						// paint crosshair line
- (void)	setMyCursor:(int)state;										// set new state
- (void)	choosePrimary;
- (void)	chooseSecondary;
- (void)	calcScaling;
- (void)	calculateFilterFrom:(double)freq_min to:(double)freq_max;

@end
