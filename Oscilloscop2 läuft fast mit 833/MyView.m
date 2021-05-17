//
//  MyView.m
//  BodeDiagram
//
//  Created by Heinz-Jšrg on Sat Apr 19 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.

#import		"MyView.h"
#include	"BodeWindow.h"
#import		"PreferencesWindow.h"
#import		"MyCursor.h"
#import 	"FilterWindow.h"
#import 	"NSViewExtensions.h"

#include	"myConstants.h"


/* 
	The initialization scheme calls:
	first		+ (void)	initialize
	then		- (id)		initWithFrame:(NSRect)frame
	and finally	- (void)	awakeFromNib								09.05.2003 HJS
	
	NSTransform can not be used since than horizontal lines have 
	different linewith than vertical lines, when the image is 
	streched in one direction!											29.04.2003 HJS
*/

BOOL		clip_on = false;			// TRUE if drawing is to be clipped inside the viewport 

enum {
	arrowState, handState, handClosedState, plusState, minusState, zoomTopRightState, zoomTopLeftState, zoomBottomRightState, zoomBottomLeftState
};


@implementation MyView

- (void)awakeFromNib
{
	static BOOL	initiated = FALSE;
	
    if ([[self superclass] instancesRespondToSelector:@selector(awakeFromNib)]) {
        [super awakeFromNib];
    }
    if (!initiated) {
		// class-specific initialization goes here
		[self setMyCursor:plusState];								// when the cursor is already inside it does not work!
		[self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
				
		rubberbandRect = NSZeroRect;
		[self choosePrimary];
			
		//[[self window] invalidateCursorRectsForView:self];
    }
}

- (BOOL)	acceptsFirstResponder
{
	return YES;
}

- (IBAction)zoomIn:(id)sender
{
	[self zoomInFromPoint:NSMakePoint(viewRect.origin.x + viewRect.size.width/2, 
									  viewRect.origin.y + viewRect.size.height/2)];
}

- (IBAction)zoomOut:(id)sender
{
	[self zoomOutFromPoint:NSMakePoint(viewRect.origin.x + viewRect.size.width/2, 
									   viewRect.origin.y + viewRect.size.height/2)];
}

- (IBAction)openFilterCoefficients:(id)sender
{
	[filterWindow makeKeyAndOrderFront:sender];
}


- (IBAction)openPreferences:(id)sender
{
	[prefWindow makeKeyAndOrderFront:sender];
	[prefWindow updateWindow:windowRect secondary:secondaryRect];
}


- (void)	flagsChanged:(NSEvent *)theEvent
{
	if ([theEvent modifierFlags] & NSShiftKeyMask) {
		[self setMyCursor:minusState];
	} else if ([theEvent modifierFlags] & NSAlternateKeyMask) {
		[self setMyCursor:handState];
	} else {
		[self setMyCursor:plusState];
	}
}


- (BOOL)	acceptsFirstMouse:(NSEvent *)theEvent
{
	return TRUE;
}



- (void)mouseDown:(NSEvent *)theEvent
{
    BOOL		keepOn = YES;
    BOOL		dragged = NO;
    BOOL		isInside = YES;
    NSPoint		mouseLoc, origPoint;
	float		dx;
	float		dy;
	int			corner = 0;

	switch (currentState) {
		case handState:
			[self setMyCursor:handClosedState];
			break;
	}
	while (keepOn) {
        theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSRightMouseUpMask | NSLeftMouseDraggedMask];
        mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        isInside = [self mouse:mouseLoc inRect:[self bounds]];

        switch ([theEvent type]) {
            case NSLeftMouseDragged:
				if (!dragged) {				
					origPoint = mouseLoc;
				} else {
					switch (currentState) {
						case handClosedState:
							dx = origPoint.x-mouseLoc.x;
							dy = origPoint.y-mouseLoc.y;
							if ((fabs(dx)>EPS) && (fabs(dy)>EPS)) {
								[self zoomInToRect:NSOffsetRect([self bounds], dx, dy)];
								origPoint = mouseLoc;
							}
							break;
						case zoomTopLeftState:
						case zoomTopRightState:
						case zoomBottomLeftState:
						case zoomBottomRightState:
						case plusState: {
								NSRect newRubberbandRect = NSMakeRectFromPoints(origPoint, mouseLoc);
								if (!NSEqualRects(rubberbandRect, newRubberbandRect)) {
									corner = 1*(origPoint.x>mouseLoc.x)+2*(origPoint.y>mouseLoc.y);
									[self setMyCursor:zoomTopRightState+corner];
									[self setNeedsDisplayInRect:rubberbandRect];
									rubberbandRect = newRubberbandRect;
									[self setNeedsDisplayInRect:rubberbandRect];
								}
							}
							break;
					}
				}
				dragged = YES;
				break;
            case NSLeftMouseUp:
				switch (currentState) {
					case handClosedState:
						[self setMyCursor:handState];
						break;
					case plusState:
						if (isInside) {						 						
							[self zoomInFromPoint:mouseLoc];
						}
						break;
					case zoomTopLeftState:
					case zoomTopRightState:
					case zoomBottomLeftState:
					case zoomBottomRightState:
						if (dragged && (rubberbandRect.size.width>5) && (rubberbandRect.size.height>5)) {
							[self zoomInToRect:rubberbandRect];
						}
						[self setNeedsDisplayInRect:rubberbandRect];
						rubberbandRect = NSZeroRect;
						[self setMyCursor:plusState];
						break;
				}
				// fall through!!!
			case NSRightMouseUp:
				keepOn = NO;
				switch (currentState) {
					case minusState:
						if (isInside) {
							[self zoomOutFromPoint:mouseLoc];
						}
						break;
				}
				break;
            default:
				/* Ignore any other kind of event. */
				break;
        }

    };

    return;
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	[[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[[self window] setAcceptsMouseMovedEvents:NO];
}


- (void)mouseMoved:(NSEvent *)theEvent
{
	NSPoint			topLoc;
    NSPoint			bottomLoc;
	double			myFrequency;
	GenericFilter	*currentFilter = [filterWindow getCurrentFilter];

	//NSPoint		myMouseLocation = [NSEvent mouseLocation];	// [theEvent locationInWindow]
	
	// here we misuse the rubberbandRect to display a vertical line for the cursor position
	bottomLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	bottomLoc.y = [self bounds].origin.y;
	topLoc = bottomLoc;
	topLoc.x += 1;
	topLoc.y += [self bounds].size.height;
	
	NSRect newRubberbandRect = NSMakeRectFromPoints(bottomLoc, topLoc);
	if (!NSEqualRects(rubberbandRect, newRubberbandRect)) {
		[self setNeedsDisplayInRect:rubberbandRect];				// to erase the old line
		rubberbandRect = newRubberbandRect;							// change it
		[self setNeedsDisplayInRect:rubberbandRect];				// to display the new line
	}
	
	if (logarithmicX) {
		myFrequency	= pow(10, (bottomLoc.x-x_offset)/x_scale);		// get frequency for log scale
	} else {
		myFrequency	= (bottomLoc.x-x_offset)/x_scale;				// get frequency for lin scale
	}
	[frequencyValue setDoubleValue:myFrequency];
	[gainValue 	setDoubleValue:[currentFilter calculatedB:myFrequency]];
	[phaseValue setDoubleValue:[currentFilter calculatePhase:myFrequency]];
}

- (void)	setFrame:(NSRect)frameRect
{
	static	NSTrackingRectTag myTag = nil;
	
	[super setFrame:frameRect];
	[self removeTrackingRect:myTag];
	myTag = [self addTrackingRect:frameRect owner:self userData:nil assumeInside:NO];
	
	rubberbandRect.size.height = [self bounds].size.height;			// for the missused rubberbandRect
}

- (void)	zoomInFromPoint:(NSPoint)mouseLoc
{
	float				xLeft, xRight, yBottom, yTop;
	NSPoint				myLocation;
	
	// reset transform matrix
	myLocation.x = (mouseLoc.x-x_offset)/x_scale;
	myLocation.y = (mouseLoc.y-y_offset)/y_scale;
	
	xLeft = -(myLocation.x-windowRect.origin.x)/2;
	xRight = (windowRect.origin.x-myLocation.x+windowRect.size.width)/2;
	yBottom = -(myLocation.y-windowRect.origin.y)/2;
	yTop = (windowRect.origin.y-myLocation.y+windowRect.size.height)/2;
	
	[self windowFromX:myLocation.x+xLeft ToX:myLocation.x+xRight AndFromY:myLocation.y+yBottom ToY:myLocation.y+yTop];
	[self secondaryFromX:myLocation.x+xLeft ToX:myLocation.x+xRight];	
	[prefWindow updateWindow:windowRect secondary:secondaryRect];
	[self setNeedsDisplay: YES];
}

- (void)	zoomOutFromPoint:(NSPoint)mouseLoc
{
	float				xLeft, xRight, yBottom, yTop;
	NSPoint				myLocation;
	
	myLocation.x = (mouseLoc.x-x_offset)/x_scale;
	myLocation.y = (mouseLoc.y-y_offset)/y_scale;

	xLeft = -(myLocation.x-windowRect.origin.x)*2;
	xRight = (windowRect.origin.x-myLocation.x+windowRect.size.width)*2;
	yBottom = -(myLocation.y-windowRect.origin.y)*2;
	yTop = (windowRect.origin.y-myLocation.y+windowRect.size.height)*2;
	
	[self windowFromX:myLocation.x+xLeft ToX:myLocation.x+xRight AndFromY:myLocation.y+yBottom ToY:myLocation.y+yTop];
	[self secondaryFromX:myLocation.x+xLeft ToX:myLocation.x+xRight];	
	[prefWindow updateWindow:windowRect secondary:secondaryRect];
	[self setNeedsDisplay: YES];
}


- (void)	zoomInToRect:(NSRect)mouseRect
{
	NSRect				myRect;
	
	myRect.origin.x	= (mouseRect.origin.x-x_offset)/x_scale;
	myRect.origin.y	= (mouseRect.origin.y-y_offset)/y_scale;
	myRect.size.width = mouseRect.size.width/x_scale;
	myRect.size.height = mouseRect.size.height/y_scale;
	
	[self windowFromX:myRect.origin.x ToX:myRect.origin.x+myRect.size.width 
					AndFromY:myRect.origin.y ToY:myRect.origin.y+myRect.size.height];
	[self secondaryFromX:myRect.origin.x ToX:myRect.origin.x+myRect.size.width];	
	[prefWindow updateWindow:windowRect secondary:secondaryRect];
	[self setNeedsDisplay: YES];
}


- (char *)	version
{
	static char sccsversion[] = "MyView 6.3.2003 by HJS from pslib.c 1.30 22.11.97";
	return sccsversion;
}

- (void)	clear
/*
	description:
	clear initializes the postscript output. This routine resets all settings
	for postscript output as they were after the call initplot.
	input:
		-
	output:
		-
*/
{
	static	BOOL	initialized = FALSE;
	
	if (!initialized) {
		initialized = TRUE;
	}

	[self windowFromX:0.0 ToX:1.0 AndFromY:-1.0 ToY:1.0];			// set my 1st scale
	[self secondaryFromX:0.0 ToX:1.0 AndFromY:0.0 ToY:10.0];		// set my 2nd scale
}

- (void)	windowFromX:(float)xmin ToX:(float)xmax AndFromY:(float)ymin ToY:(float)ymax
/*
	description:
	window defines the scaling of the plot, in the last opened grafport
	(last viewport command). The scale in x- direction can be different
	from that in y- direction.
	input:
		xmin, xmax, ymin, ymax: Bounds to define the scales of the
									drawing for horizontal and vertical
									direction.
	output:
		-
	globals:
		x_min_window, x_max_window, y_min_window, y_max_window,
		x_scale, y_scale, x_offset, y_offset
									are set according to the new
									coordinate system.
	example:
		[self windowFromX:0.0 ToX:3.1415 AndFromY:-1.0 ToY:1.0];
*/
{
	const float	bignum = 1000000000000000.0;	//MAXFLOAT/
	//const float	smallnum = 1.0/bignum;
	
	windowRect.size.width	= xmax-xmin;
	windowRect.size.height	= ymax-ymin;
	if (bignum < fabs(xmin)) {										// not too big
		xmin = (0 <= xmin? bignum : -bignum);
	}
	if (bignum < fabs(ymin)) {										// not too big
		ymin = (0 <= ymin? bignum : -bignum);
	}
	windowRect.origin		= NSMakePoint(xmin, ymin); 
}

- (void)	secondaryFromX:(float)xmin ToX:(float)xmax AndFromY:(float)ymin ToY:(float)ymax
/*
	description:
		see above
	output:
		-
	globals:
		...
	example:
		[self secondaryFromX:0.0 ToX:3.1415 AndFromY:-1.0 ToY:1.0];
*/
{
	const float	bignum = 1000000000000000.0;	//MAXFLOAT/
	//const float	smallnum = 1.0/bignum;
	
	secondaryRect.size.width	= xmax-xmin;
	secondaryRect.size.height	= ymax-ymin;
	if (bignum < fabs(xmin)) {										// not too big
		xmin = (0 <= xmin? bignum : -bignum);
	}
	if (bignum < fabs(ymin)) {										// not too big
		ymin = (0 <= ymin? bignum : -bignum);
	}
	secondaryRect.origin		= NSMakePoint(xmin, ymin); 
}

- (void)	secondaryFromX:(float)xmin ToX:(float)xmax
/*
	description:
		see above, but keeps the y scale
	output:
		-
	globals:
		...
	example:
		[self secondaryFromX:0.0 ToX:3.1415];
*/
{
	const float	bignum = 1000000000000000.0;	//MAXFLOAT/
	//const float	smallnum = 1.0/bignum;
	
	secondaryRect.size.width	= xmax-xmin;
	if (bignum < fabs(xmin)) {										// not too big
		xmin = (0 <= xmin? bignum : -bignum);
	}
	secondaryRect.origin.x		= xmin; 
}


- (NSRect)	getWindowRect;											// return coordinate rect
{
	return windowRect;
}

- (NSRect)	getSecondaryRect;										// return coordinate rect
{
	return secondaryRect;
}

 
- (void)	showFromX:(float)xmin ToX:(float)xmax AndFromY:(float)ymin ToY:(float)ymax
/*
	description:
	show defines the scaling of the plot. The scale in x- direction and
	y- direction are the same, but choosen so, that the whole drawing
	is visible.
	input:
		xmin, xmax, ymin, ymax: Bounds to define the scales of the
								drawing for horizontal and vertical
								direction.
	output:
		-
	globals:
		x_min_window, x_max_window, y_min_window, y_max_window,
		x_scale, y_scale, x_offset, y_offset
								are set according to the new
								coordinate system.
	example:
		[self showFromX:0.0 ToX:3.1415 AndFromY:-1.0 ToY:1.0];
*/
{
	double xcenter, ycenter;

	windowRect.size.width	= xmax-xmin;
	windowRect.size.height	= ymax-ymin;
	windowRect.origin		= NSMakePoint(xmin, ymin); 

	xcenter = windowRect.origin.x + windowRect.size.width/2;
	ycenter = windowRect.origin.y + windowRect.size.height/2;

	// calculate the scaling factors
	x_scale = viewRect.size.width/windowRect.size.width;
	y_scale = viewRect.size.height/windowRect.size.height;

	// allign it arround the center
	if (fabs(x_scale) > fabs(y_scale)) {
		windowRect.size.width = viewRect.size.width/x_scale;
		windowRect.origin.x = xcenter - windowRect.size.width/2;
	} else {
		windowRect.size.height = viewRect.size.height/y_scale;
		windowRect.origin.y = ycenter - windowRect.size.height/2;
	}

	// offset the drawings
	x_offset = viewRect.origin.x - windowRect.origin.x * x_scale;
	y_offset = viewRect.origin.y - windowRect.origin.y * y_scale;
}

- (void)	setLogX:(BOOL)isLogXScale
{
	logarithmicX = isLogXScale;
}

- (void)	setLogY:(BOOL)isLogYScale
{
	logarithmicY = isLogYScale;
}

- (BOOL)	getLogX
{
	return logarithmicX;
}

- (BOOL)	getLogY
{
	return logarithmicY;
}

- (void)	penup
/*
	description:
	penup disables the drawing with plot, resp. plotto. This cammand is used
	to start a new chain of line segments.
	input:
			-
	output:
			-
*/
{
	penIsDown = false;
}

- (void)	pendown
/*
	description:
	pendown enables the drawing with plot, resp. plotto. Usually this command
	is not used.
	input:
		-
	output:
		-
*/
{
	penIsDown = true;
}

- (void) lineWidth:(float)width
/*
	description:
	linewidth defines a new line thickness. The parameter is given in global
	units. A hairline is achieved, when 0.0 is passed as width value.
	input:
		width:			linewidth in global units.
	output:
		-
*/
{
	[NSBezierPath setDefaultLineWidth:width];
}


- (void)	move:(float)dx :(float)dy								// move relative
/*
	description:
	move perfoms a relative move. No drawing is performed. Only the current
	position is changed.
	input:
		dx, dy: Relative displacement of the pen.
	output:
		-
*/
{
	cursorPosition.x += dx*x_scale;
	cursorPosition.y += dy*y_scale;
}

- (void)	moveto:(float)x :(float)y								// move absolute
/*
	description:
	moveto displaces the pen in absolute units. No drawing is performed.
	input:
		x, y:	Displacements of the pen.
	output:
		-
*/
{
	cursorPosition.x = x*x_scale+x_offset;
	cursorPosition.y = y*y_scale+y_offset;
}

- (void) draw:(float)dx :(float)dy									// draw relative
/*
	description:
	draw produces a line with relative coordinates. Drawing is performed
	using the current dash pattern and color.
	input:
		dx, dy: Relative displacement of the pen after drawing the line.
	output:
		-
*/
{
	NSPoint	newPoint;

	newPoint = NSMakePoint(cursorPosition.x+dx*x_scale, cursorPosition.y+dy*y_scale);
	[NSBezierPath strokeLineFromPoint:cursorPosition toPoint:newPoint];
	cursorPosition = newPoint;
}
 
- (void) drawto:(float)x :(float)y									// draw absolute
/*
	description:
	drawto draws a line absolutely. Drawing is performed using the
	current dash pattern and color.
	input:
		x, y:	New coordinates after the drawing.
	output:
		-
*/
{
	NSPoint	newPoint;

	newPoint = NSMakePoint(x*x_scale+x_offset, y*y_scale+y_offset);
	[NSBezierPath strokeLineFromPoint:cursorPosition toPoint:newPoint];
	cursorPosition = newPoint;
}

- (void) plot:(float)dx :(float)dy									// plot relative
/*
	description:
	plot appends a line segment to the current line using relative move.
	If penup() was called directly before, than no drawing will be
	performed. This command enables drawing of a curve out of serveral
	line segments in one single for(;;) loop.
	input:
		dx, dy:
	output:
		-
*/
{
	if (penIsDown) {
		[self draw:dx :dy];
	} else {
		[self move:dx :dy];
		[self pendown];
	}
}
 
- (void) plotto:(float)x :(float)y									// plot absolute
/*
	description:
	plot appends a line segment to the current line using absolute move.
	If penup() was called directly before, than no drawing will be
	performed. This command enables drawing of a curve out of serveral
	line segments in one single for(;;) loop.
	input:
		x, y:
		globals:		pen_is_down
	output:
		-
		globals:		pen_is_down set to true
*/
{
	if (penIsDown) {
		[self drawto:x :y];
	} else {
		[self moveto:x :y];
		[self pendown];
	}
}



- (void)	myCircleAtX:(float)cx AtY:(float)cy radius:(float)radius
{
	//float				x = 0, y = radius/10.0, a = 0.95;
	float				x = 2*sqrt(radius), y = 0;
	float				a; 
	float				b;
	float				t;
	int					i;
	
//	Interesting algorithm to plot a circle with roughly similar visible resolution!
//	if y is replace by y = n*radius, 'a' will be just a constant, but the plot will be bad
//	for large radius. HJS March/2003

	a = 1.0-2/radius;
	b = sqrt(1-a*a);
	[self moveto:cx-x/2  :cy-radius+0.5];
	for (i = 0; i < sqrt(radius)*PI; i++) {
		[self draw:x :y];
		t =  a*x - b*y;
		y =  b*x + a*y;
		x = t;
	}
}

+ (void)	initialize
{
    static BOOL isInitialized = NO;
	
    if (!isInitialized) {
		// initialization code goes here
        isInitialized = YES;										// to avoid to do it more than once
    }
}


- (id)		initWithFrame:(NSRect)frame
{		
	[super initWithFrame:frame];
	[self setFont: [NSFont systemFontOfSize: 5]];
    return self;
}

- (void)	setString:(NSString *)value
{
    [string autorelease];
    string = [value copy];
    [self setNeedsDisplay: YES];
}


- (void)	setFont:(NSFont *)value
{
    [font autorelease];
    font = [value retain];
    [self setNeedsDisplay: YES];
}

- (void)	setValue:(float)value
{
	myValue = value;
    [self setNeedsDisplay: YES];
}

- (void)	setSamples:(int)numSamples
{
	samples = numSamples;
}

- (double *)	allocXData
{
	if (xArray) free(xArray);
	xArray = malloc(samples*sizeof(double));
	
	return	xArray;
}


- (double *)	allocYData
{
	if (yArray) free(yArray);	
	yArray = malloc(samples*sizeof(double));
	return	yArray;
}

- (double *)	allocPhaseData
{
	if (phaseArray) free(phaseArray);	
	phaseArray = malloc(samples*sizeof(double));
	return	phaseArray;
}

- (double)	minX													// returns minimum x-value
{
	if (logarithmicX) {
		return pow(10, currentRect->origin.x);
	} else {
		return currentRect->origin.x;
	}
}

- (double)	maxX													// returns maximum x-value
{
	if (logarithmicX) {
		return pow(10, currentRect->origin.x+currentRect->size.width);
	} else {
		return currentRect->origin.x+currentRect->size.width;
	}
}

- (void)openDrawRect:(NSRect)rect
{	
    NSRect		myBounds	= [self bounds];
	int			egal		= 2;

	/*
	NSPoint		myHelpPoint = NSMakePoint(1.0, 1.0);
	BOOL		dummy;
	
	dummy = [NSHelpManager showContextHelpForObject:self locationHint:myHelpPoint];
	*/

	// paint white background
	switch (egal) {
		case 0:
			[[NSColor whiteColor] set];
			[NSBezierPath fillRect:myBounds];
			break;
		case 1:
			NSEraseRect(myBounds);
			break;
		case 2:
			NSEraseRect(rect);
			break;
	}
    if (!NSEqualRects(rubberbandRect, NSZeroRect)) {
        [[NSColor knobColor] set];
		NSFrameRect(rubberbandRect);
		if([self inLiveResize]) {
			
		}
    }	
}


- (void)closeDrawRect:(NSRect)rect
{
}


- (void)choosePrimary
{
	viewRect	= [self bounds];
	//viewRect.size.height /= 2;
	//viewRect.origin.y += viewRect.size.height;
	//NSRectClip(viewRect);
	currentRect = &windowRect;
	[self calcScaling];
}


- (void)chooseSecondary
{
	viewRect	= [self bounds];
	//viewRect.size.height /= 2;
	//NSRectClip(viewRect);
	currentRect = &secondaryRect;
	[self calcScaling];
}


- (void)calcScaling
{
	// calculate the scaling factors
	x_scale = viewRect.size.width/currentRect->size.width;
	x_offset = viewRect.origin.x - currentRect->origin.x * x_scale;
	y_scale = viewRect.size.height/currentRect->size.height;
	y_offset = viewRect.origin.y - currentRect->origin.y * y_scale;
}

- (void)drawRect:(NSRect)rect
{
	int					i;
	float				gridLineWidth = 0.15;
    NSMutableDictionary *attrs		= [NSMutableDictionary dictionary];
	
	[self openDrawRect:rect];
	
	if([self inLiveResize]) {
		// do not recalculate
		//glFlush();
	} else {
		//[[self openGLContext] flushBuffer];
		[self calculateFilterFrom:[self minX] to:[self maxX]];
	}
	
	[horizontalAxis setGridRect:&windowRect];
	[verticalAxis setGridRect:&windowRect];
	[secondaryAxis setGridRect:&secondaryRect];
	// calculate the scaling factors for phase
	[self chooseSecondary];
	[[NSColor redColor] set];
	// draw x and y axis for secondary plot
	[secondaryAxis linTics:windowRect.origin.x  separation:90.0 ticPercent:100 andMajorEvery:0  lineWidth:gridLineWidth];
	
	// draw the phase graph
	[self lineWidth:1.2];
	[self penup];
	for (i = 0; i < samples; i++) {
		if (logarithmicX) {
			[self plotto:log10(xArray[i]) :phaseArray[i]];
		} else {
			[self plotto:xArray[i] :phaseArray[i]];
		}
	}
	
	// calculate the scaling factors
	[self choosePrimary];
	
	[[NSColor blackColor] set];
	
	[[NSColor blueColor] set];
	// draw x and y axis for primary plot
	if (logarithmicX) {
		[horizontalAxis logGrid:gridLineWidth];
	} else {
		[horizontalAxis linTics:windowRect.origin.y separation:0.0 ticPercent:200 andMajorEvery:10 lineWidth:gridLineWidth]; 
	}
	if (logarithmicY) {
		[verticalAxis logGrid:gridLineWidth];
	} else {
		[verticalAxis linTics:windowRect.origin.x separation:0.0 ticPercent:200 andMajorEvery:10 lineWidth:gridLineWidth];
	}
    [attrs setObject: font forKey: NSFontAttributeName];
    [string drawAtPoint: NSMakePoint(0, 0) withAttributes: attrs];
			
	// draw the magnitude graph
	[self lineWidth:1.2];
	[self penup];
	for (i = 0; i < samples; i++) {
		if (logarithmicX) {
			if (logarithmicY) {
				[self plotto:log10(xArray[i]) :log10(yArray[i])];
			} else {
				[self plotto:log10(xArray[i]) :yArray[i]];
			}
		} else {
			if (logarithmicY) {
				[self plotto:xArray[i] :log10(yArray[i])];
			} else {
				[self plotto:xArray[i] :yArray[i]];
			}
		}
	}

	NSRectClip([self bounds]);	

	// calculate the scaling factors
	[self choosePrimary];

	[self closeDrawRect:rect];

}


- (void)calculateFilterFrom:(double)freq_min to:(double)freq_max
{
	double			*frequenz, *gain_dB, *phase;
	int				i;	
	GenericFilter	*currentFilter = [filterWindow getCurrentFilter];

	samples 	= MAX_SAMPLES;
	frequenz	= [self allocXData];
	gain_dB		= [self allocYData];	
	phase		= [self allocPhaseData];
	for (i = 0; i < samples; i++) {
		frequenz[i]	= 0.0;
		gain_dB[i]	= 0.0;	
		phase[i]	= 0.0;
	}		
	BOOL unwrap = [unwrapPhase intValue];
	
	[currentFilter concatFilterFrom:freq_min to:freq_max with:samples logarithmic:logarithmicX hArray:frequenz vArray:gain_dB v2Array:phase unwrap:unwrap];
}

- (void)	testGraphics
{
    NSRect				myBounds	= [self bounds];
    NSMutableDictionary *attrs		= [NSMutableDictionary dictionary];

	// draw some crosshair on the view
	[[NSColor redColor] set];
	[self paintCrosshair:&myBounds];

	[self lineWidth:0.0];
	[self penup];
	[self plotto:-100.0 :-100.0];
	[self plotto: 100.0 : 100.0];
	[self penup];
	[self plotto: 100.0 :-100.0];
	[self plotto:-100.0 : 100.0];

	[self penup];
	[self plotto: 20.0 : 20.0];
	[self plotto:100.0 :100.0];
	[self penup];
	[self plotto:100.0 : 20.0];
	[self plotto: 20.0 :100.0];
	[self penup];
	[self plotto:310.0 :120.0];
	[self plotto:220.0 :200.0];
	[self penup];
	[self plotto:220.0 :220.0];
	[self plotto:300.0 :200.0];
	[self penup];
		
	[self myCircleAtX:200 AtY:100 radius:10];
	[self myCircleAtX:200 AtY:100 radius:20];
	[self myCircleAtX:200 AtY:100 radius:40];
	[self myCircleAtX:200 AtY:100 radius:80];
	[self myCircleAtX:200 AtY:100 radius:160];
	[self myCircleAtX:200 AtY:100 radius:320];
	[self myCircleAtX:200 AtY:100 radius:640];
	    
	[[NSColor blackColor] set];
    [attrs setObject: font forKey: NSFontAttributeName];
    [string drawAtPoint: NSMakePoint(myBounds.size.width/4.0, 5) withAttributes: attrs];

	// Define CG clip area!
	//setCGClipRect(contfloat, (CGRect *)&myBounds);

}

- (void)	paintCrosshair:(const NSRect*) bounds
{
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, NSMidY(*bounds)) toPoint:NSMakePoint(bounds->size.width, NSMidY(*bounds))];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMidX(*bounds), 0) toPoint:NSMakePoint(NSMidX(*bounds), bounds->size.height)];	
}



- (void)	setMyCursor:(int)state
{
	currentState = state;

	switch (state) {
		case	arrowState:
			[[MyCursor arrowCursor] set];
			break;
		case	handState:
			[[MyCursor handCursor] set];
			break;
		case	handClosedState:
			[[MyCursor handClosedCursor] set];
			break;
		case	plusState:
			[[MyCursor plusCursor] set];
			break;
		case	zoomTopLeftState:
			[[MyCursor zoomTopLeftCursor] set];
			break;
		case	zoomTopRightState:
			[[MyCursor zoomTopRightCursor] set];
			break;
		case	zoomBottomLeftState:
			[[MyCursor zoomBottomLeftCursor] set];
			break;
		case	zoomBottomRightState:
			[[MyCursor zoomBottomRightCursor] set];
			break;
		case	minusState:
			[[MyCursor minusCursor] set];
			break;
	}
}



- (void)resetCursorRects
{
    NSRect		myBounds	= [self bounds];
	
	[self setMyCursor:currentState];
	[self discardCursorRects];
	[self addCursorRect:myBounds cursor:[MyCursor currentCursor]];
	[[MyCursor currentCursor] setOnMouseEntered:YES];
}

- (void)dealloc 
{
    //NSZoneFree(private, [self zone])
	//NSBeep();
	if (xArray) free(xArray);
	if (yArray) free(yArray);
	if (phaseArray) free(phaseArray);	
	
    [super dealloc];
}

- (void)viewWillStartLiveResize
{
    [super viewWillStartLiveResize];
}

- (void)viewDidEndLiveResize
{
    //[self setNeedsDisplay: YES];
    [super viewDidEndLiveResize];
}


@end
