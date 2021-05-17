////  ScientificImage.m//  Oscilloscope////  Created by Heinz-J�rg on Sun Jun 1 2003.//  Copyright (c) 2003 Heinz-J�rg SCHR�DER. All rights reserved.////	Version 1.30: 28.12.2004		all double replaced by float!#import 	"ScientificImage.h"#import 	"NSViewExtensions.h"#import		"MyCursor.h"#import		"myMath.h"@implementation ScientificImage- (char *)	version{	static char sccsversion[] = "ScientificImage 24.10.2003 by HJS from pslib.c 1.30 22.11.2003";	return sccsversion;}- (void)awakeFromNib{	static BOOL			initiated = FALSE;	NSColor				*color;    NSFont				*font;	    if (!initiated) {		//initiated = TRUE;		// class-specific initialization goes here		[self setMyCursor:plusState];								// when the cursor is already inside it does not work!		trackingTag = [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];						rubberbandRect = NSZeroRect;		[self choosePrimary];				font  = [NSFont systemFontOfSize:8];		color = [NSColor blueColor];		attrs = [NSMutableDictionary dictionaryWithCapacity:2];		[attrs setObject:font forKey:NSFontAttributeName];		[attrs setObject:color forKey:NSForegroundColorAttributeName];		[attrs autorelease];		[attrs retain];		[self setSymbolSize:6];    }}- (BOOL)	acceptsFirstResponder{	return YES;}- (void)	setFrame:(NSRect)frameRect{		[super setFrame:frameRect];	[self removeTrackingRect:trackingTag];	trackingTag = [self addTrackingRect:frameRect owner:self userData:nil assumeInside:NO];		rubberbandRect.size.height = [self bounds].size.height;			// for the missused rubberbandRect}- (void)	flagsChanged:(NSEvent *)theEvent{	if ([theEvent modifierFlags] & NSEventModifierFlagShift) {		[self setMyCursor:minusState];	} else if ([theEvent modifierFlags] & NSEventModifierFlagOption) {		[self setMyCursor:handState];	} else {		[self setMyCursor:plusState];	}}- (BOOL)	acceptsFirstMouse:(NSEvent *)theEvent{	return TRUE;}- (void)mouseDown:(NSEvent *)theEvent{    BOOL		keepOn = YES;    BOOL		dragged = NO;    BOOL		isInside = YES;    NSPoint		mouseLoc, origPoint;	float		dx;	float		dy;	NSInteger			corner = 0;	switch (currentState) {		case handState:			[self setMyCursor:handClosedState];			break;	}	while (keepOn) {        theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSRightMouseUpMask | NSLeftMouseDraggedMask];        mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];        isInside = [self mouse:mouseLoc inRect:[self bounds]];        switch ([theEvent type]) {            case NSLeftMouseDragged:				if (!dragged) {									origPoint = mouseLoc;				} else {					switch (currentState) {						case handClosedState:							dx = origPoint.x-mouseLoc.x;							dy = origPoint.y-mouseLoc.y;							if ((fabs(dx)>EPS) && (fabs(dy)>EPS)) {								[self zoomInToRect:NSOffsetRect([self bounds], dx, dy)];								origPoint = mouseLoc;							}							break;						case zoomTopLeftState:						case zoomTopRightState:						case zoomBottomLeftState:						case zoomBottomRightState:						case plusState: {								NSRect newRubberbandRect = NSMakeRectFromPoints(origPoint, mouseLoc);								if (!NSEqualRects(rubberbandRect, newRubberbandRect)) {									corner = 1*(origPoint.x>mouseLoc.x)+2*(origPoint.y>mouseLoc.y);									[self setMyCursor:zoomTopRightState+corner];									[self setNeedsDisplayInRect:rubberbandRect];									rubberbandRect = newRubberbandRect;									[self setNeedsDisplayInRect:rubberbandRect];								}							}							break;					}				}				dragged = YES;				break;            case NSLeftMouseUp:				switch (currentState) {					case handClosedState:						[self setMyCursor:handState];						break;					case plusState:						if (isInside) {						 													[self zoomInFromPoint:mouseLoc];						}						break;					case zoomTopLeftState:					case zoomTopRightState:					case zoomBottomLeftState:					case zoomBottomRightState:						if (dragged && (rubberbandRect.size.width>5) && (rubberbandRect.size.height>5)) {							[self zoomInToRect:rubberbandRect];						}						//[self setNeedsDisplayInRect:rubberbandRect];						rubberbandRect = NSZeroRect;						[self setMyCursor:plusState];						break;				}				// fall through!!!			case NSRightMouseUp:				keepOn = NO;				switch (currentState) {					case minusState:						if (isInside) {							[self zoomOutFromPoint:mouseLoc];						}						break;				}				break;            default:				// Ignore any other kind of event.				break;        }    };    return;}- (IBAction)	zoomIn:(id)sender{	[self zoomInFromPoint:NSMakePoint(viewRect.origin.x + viewRect.size.width/2, 									  viewRect.origin.y + viewRect.size.height/2)];}- (IBAction)	zoomOut:(id)sender{	[self zoomOutFromPoint:NSMakePoint(viewRect.origin.x + viewRect.size.width/2, 									   viewRect.origin.y + viewRect.size.height/2)];}- (void)	zoomInFromPoint:(NSPoint)mouseLoc{	float				xLeft, xRight, yBottom, yTop;	NSPoint				myLocation;		// reset transform matrix	myLocation.x = (mouseLoc.x-x_offset)/x_scale;	myLocation.y = (mouseLoc.y-y_offset)/y_scale;		xLeft = -(myLocation.x-windowRect.origin.x)/2;	xRight = (windowRect.origin.x-myLocation.x+windowRect.size.width)/2;	yBottom = -(myLocation.y-windowRect.origin.y)/2;	yTop = (windowRect.origin.y-myLocation.y+windowRect.size.height)/2;		[self windowFromX:myLocation.x+xLeft ToX:myLocation.x+xRight AndFromY:myLocation.y+yBottom ToY:myLocation.y+yTop];	[self secondaryFromX:myLocation.x+xLeft ToX:myLocation.x+xRight];		[self setNeedsDisplay: YES];}- (void)	zoomOutFromPoint:(NSPoint)mouseLoc{	float				xLeft, xRight, yBottom, yTop;	NSPoint				myLocation;		myLocation.x = (mouseLoc.x-x_offset)/x_scale;	myLocation.y = (mouseLoc.y-y_offset)/y_scale;	xLeft = -(myLocation.x-windowRect.origin.x)*2;	xRight = (windowRect.origin.x-myLocation.x+windowRect.size.width)*2;	yBottom = -(myLocation.y-windowRect.origin.y)*2;	yTop = (windowRect.origin.y-myLocation.y+windowRect.size.height)*2;		[self windowFromX:myLocation.x+xLeft ToX:myLocation.x+xRight AndFromY:myLocation.y+yBottom ToY:myLocation.y+yTop];	[self secondaryFromX:myLocation.x+xLeft ToX:myLocation.x+xRight];		[self setNeedsDisplay: YES];}- (void)	zoomInToRect:(NSRect)mouseRect{	NSRect				myRect;		myRect.origin.x	= (mouseRect.origin.x-x_offset)/x_scale;	myRect.origin.y	= (mouseRect.origin.y-y_offset)/y_scale;	myRect.size.width = mouseRect.size.width/x_scale;	myRect.size.height = mouseRect.size.height/y_scale;		[self windowFromX:myRect.origin.x ToX:myRect.origin.x+myRect.size.width 					AndFromY:myRect.origin.y ToY:myRect.origin.y+myRect.size.height];	[self secondaryFromX:myRect.origin.x ToX:myRect.origin.x+myRect.size.width];		[self setNeedsDisplay: YES];}- (void)	windowFromX:(float)xmin ToX:(float)xmax AndFromY:(float)ymin ToY:(float)ymax/*	description:	window defines the scaling of the plot, in the last opened grafport	(last viewport command). The scale in x- direction can be different	from that in y- direction.	input:		xmin, xmax, ymin, ymax: Bounds to define the scales of the									drawing for horizontal and vertical									direction.	output:		-	globals:		x_min_window, x_max_window, y_min_window, y_max_window,		x_scale, y_scale, x_offset, y_offset									are set according to the new									coordinate system.	example:		[self windowFromX:0.0 ToX:3.1415 AndFromY:-1.0 ToY:1.0];*/{	const float	bignum = 1000000000000000.0;	//MAXFLOAT/		windowRect.size.width	= xmax-xmin;	windowRect.size.height	= ymax-ymin;	if (bignum < fabs(xmin)) {										// not too big		xmin = (0 <= xmin? bignum : -bignum);	}	if (bignum < fabs(ymin)) {										// not too big		ymin = (0 <= ymin? bignum : -bignum);	}	windowRect.origin		= NSMakePoint(xmin, ymin); }- (void)	secondaryFromX:(float)xmin ToX:(float)xmax AndFromY:(float)ymin ToY:(float)ymax/*	description:		see above, for a secondary scale in the same view	output:		-	globals:		...	example:		[self secondaryFromX:0.0 ToX:3.1415 AndFromY:-1.0 ToY:1.0];*/{	const float	bignum = 1000000000000000.0;	//MAXFLOAT/	//const float	smallnum = 1.0/bignum;		secondaryRect.size.width	= xmax-xmin;	secondaryRect.size.height	= ymax-ymin;	if (bignum < fabs(xmin)) {										// not too big		xmin = (0 <= xmin? bignum : -bignum);	}	if (bignum < fabs(ymin)) {										// not too big		ymin = (0 <= ymin? bignum : -bignum);	}	secondaryRect.origin		= NSMakePoint(xmin, ymin); }- (void)	secondaryFromX:(float)xmin ToX:(float)xmax/*	description:		see above, but keeps the y scale	output:		-	globals:		...	example:		[self secondaryFromX:0.0 ToX:3.1415];*/{	const float	bignum = 1000000000000000.0;	//MAXFLOAT/	//const float	smallnum = 1.0/bignum;		secondaryRect.size.width	= xmax-xmin;	if (bignum < fabs(xmin)) {										// not too big		xmin = (0 <= xmin? bignum : -bignum);	}	secondaryRect.origin.x		= xmin; }- (void)choosePrimary{	viewRect	= [self bounds];	currentRect = &windowRect;	[self calcScaling];}- (void)choosePrimaryNew{	currentRect = &windowRect;	[self calcScaling];}- (void)chooseSecondary{	viewRect	= [self bounds];	currentRect = &secondaryRect;	[self calcScaling];}- (void)chooseSecondaryNew{	currentRect = &secondaryRect;	[self calcScaling];}- (void)setViewRectToBounds{	viewRect	= [self bounds];}- (void)setViewRect:(NSRect)myRect{	viewRect	= myRect;}- (NSRect)	viewRect{	return	viewRect;}- (void)calcScaling{	// calculate the scaling factors	x_scale = viewRect.size.width/currentRect->size.width;	x_offset = viewRect.origin.x - currentRect->origin.x * x_scale;	y_scale = viewRect.size.height/currentRect->size.height;	y_offset = viewRect.origin.y - currentRect->origin.y * y_scale;}- (float)	minX													// returns minimum x-value{	return currentRect->origin.x;}- (float)	maxX													// returns maximum x-value{	return currentRect->origin.x+currentRect->size.width;}- (NSRect)	windowRect												// first window in user coordinates {	return windowRect;}- (NSRect)	secondaryRect											// secondary window in user coordinates{	return secondaryRect;}- (void)	setWindowRect:(NSRect)newRect							// first window in user coordinates {	windowRect = newRect;}- (void)	setSecondaryRect:(NSRect)newRect						// secondary window in user coordinates{	secondaryRect = newRect;}- (void)	penup/*	description:	penup disables the drawing with plot, resp. plotto. This cammand is used	to start a new chain of line segments.	input:			-	output:			-*/{	penIsDown = false;}- (void)	pendown/*	description:	pendown enables the drawing with plot, resp. plotto. Usually this command	is not used.	input:		-	output:		-*/{	penIsDown = true;}- (void) lineWidth:(float)width/*	description:	linewidth defines a new line thickness. The parameter is given in global	units. A hairline is achieved, when 0.0 is passed as width value.	input:		width:			linewidth in global units.	output:		-*/{	[NSBezierPath setDefaultLineWidth:width];}- (void)	move:(float)dx :(float)dy								// move relative/*	description:	move perfoms a relative move. No drawing is performed. Only the current	position is changed.	input:		dx, dy: Relative displacement of the pen.	output:		-*/{	cursorPosition.x += dx*x_scale;	cursorPosition.y += dy*y_scale;}- (void)	moveto:(float)x :(float)y								// move absolute/*	description:	moveto displaces the pen in absolute units. No drawing is performed.	input:		x, y:	Displacements of the pen.	output:		-*/{	cursorPosition.x = x*x_scale+x_offset;	cursorPosition.y = y*y_scale+y_offset;}- (void) draw:(float)dx :(float)dy									// draw relative/*	description:	draw produces a line with relative coordinates. Drawing is performed	using the current dash pattern and color.	input:		dx, dy: Relative displacement of the pen after drawing the line.	output:		-*/{	NSPoint	newPoint;	newPoint = NSMakePoint(cursorPosition.x+dx*x_scale, cursorPosition.y+dy*y_scale);	[NSBezierPath strokeLineFromPoint:cursorPosition toPoint:newPoint];	cursorPosition = newPoint;} - (void) drawto:(float)x :(float)y									// draw absolute/*	description:	drawto draws a line absolutely. Drawing is performed using the	current dash pattern and color.	input:		x, y:	New coordinates after the drawing.	output:		-*/{	NSPoint	newPoint;	newPoint = NSMakePoint(x*x_scale+x_offset, y*y_scale+y_offset);	[NSBezierPath strokeLineFromPoint:cursorPosition toPoint:newPoint];	cursorPosition = newPoint;}- (void) plot:(float)dx :(float)dy									// plot relative/*	description:	plot appends a line segment to the current line using relative move.	If penup() was called directly before, than no drawing will be	performed. This command enables drawing of a curve out of serveral	line segments in one single for(;;) loop.	input:		dx, dy:	output:		-*/{	if (penIsDown) {		[self draw:dx :dy];	} else {		[self move:dx :dy];		[self pendown];	}} - (void) plotto:(float)x :(float)y									// plot absolute/*	description:	plot appends a line segment to the current line using absolute move.	If penup() was called directly before, than no drawing will be	performed. This command enables drawing of a curve out of serveral	line segments in one single for(;;) loop.	input:		x, y:		globals:		pen_is_down	output:		-		globals:		pen_is_down set to true*/{	if (penIsDown) {		[self drawto:x :y];	} else {		[self moveto:x :y];		[self pendown];	}}- (void)	plotData:(float*)buffer startIndex:(NSUInteger)index length:(NSUInteger)length				from:(double)xStart to:(double)xStop;{	NSPoint			aPoint;	double			x, y;	NSUInteger		i = index % length;	NSBezierPath	*myPath = [NSBezierPath bezierPath];		x = xStart;	y = buffer[i];	aPoint = NSMakePoint(x*x_scale+x_offset, y*y_scale+y_offset);	[myPath moveToPoint:aPoint];	x++;	for (; x < xStop; x++) {		i ++;		i %= length;		y = buffer[i];		aPoint = NSMakePoint(x*x_scale+x_offset, y*y_scale+y_offset);		[myPath lineToPoint:aPoint];	}	[myPath stroke];}- (void)	setColor:(NSColor *)newColor										// set color for following outputs{	[newColor set];																// set forground color	//[attrs removeObjectForKey:NSForegroundColorAttributeName];				// remove text color	[attrs setObject:newColor forKey:NSForegroundColorAttributeName];			// set new text color}- (void) drawString:(NSString *)markString alignment:(NSInteger)textAlignment {	NSSize				size;	NSPoint				textPosition= cursorPosition;		size = [markString sizeWithAttributes:attrs];	switch (textAlignment) {		case 	topLeft:		case 	left:		case 	bottomLeft:			textPosition.x -= size.width;			break;		case 	topCenter:		case 	center:		case 	bottomCenter:			textPosition.x -= size.width/2;			break;		default:			break;	}	switch (textAlignment) {		case 	left:		case 	center:		case 	right:			textPosition.y -= size.height/2;			break;		case 	bottomLeft:		case 	bottomCenter:		case 	bottomRight:			textPosition.y -= size.height;			break;		default:			break;	}	[markString drawAtPoint:textPosition withAttributes:attrs];	// obviously somebody tries to release attrs, who?!	[attrs retain]; 										// if not called the program crashes	}- (void)	setSymbolSize:(NSInteger)newSymbolSize{	symbolSize = newSymbolSize;}- (void)	drawTriangleSymbol:(NSInteger)symbolDirection{	NSPoint			A; 	NSPoint			B;	NSPoint			C;	NSBezierPath	*triangle = [NSBezierPath bezierPath];	switch (symbolDirection) {		case 0: // v			A = NSMakePoint(cursorPosition.x+symbolSize/2, cursorPosition.y); 			B = NSMakePoint(cursorPosition.x, cursorPosition.y-symbolSize);			C = NSMakePoint(cursorPosition.x-symbolSize/2, cursorPosition.y);			break;		case 1: // <			A = NSMakePoint(cursorPosition.x, cursorPosition.y-symbolSize/2); 			B = NSMakePoint(cursorPosition.x-symbolSize, cursorPosition.y);			C = NSMakePoint(cursorPosition.x, cursorPosition.y+symbolSize/2);			break;		case 2: // ^			A = NSMakePoint(cursorPosition.x-symbolSize/2, cursorPosition.y); 			B = NSMakePoint(cursorPosition.x, cursorPosition.y+symbolSize);			C = NSMakePoint(cursorPosition.x+symbolSize/2, cursorPosition.y);			break;		default: // >			A = NSMakePoint(cursorPosition.x, cursorPosition.y+symbolSize/2); 			B = NSMakePoint(cursorPosition.x+symbolSize, cursorPosition.y);			C = NSMakePoint(cursorPosition.x, cursorPosition.y-symbolSize/2);			break;	}	[triangle moveToPoint:A];	[triangle lineToPoint:B];	[triangle lineToPoint:C];	[triangle closePath];	[triangle fill];	[triangle stroke];}- (void)	drawCenteredSymbol:(NSInteger)symbolCode{	NSRect			enclosingRect;		enclosingRect  = NSMakeRect(cursorPosition.x-symbolSize/2, cursorPosition.y-symbolSize/2, symbolSize, symbolSize);	switch (symbolCode) {		case 0:			[[NSBezierPath bezierPathWithOvalInRect:enclosingRect] fill];			break;		case 1: 			[NSBezierPath drawPackedGlyphs:"x" atPoint:cursorPosition];			break;		default:			[NSBezierPath fillRect:enclosingRect];			break;	}}- (void)	setMyCursor:(NSInteger)state{	currentState = state;	switch (state) {		case	arrowState:			[[MyCursor arrowCursor] set];			break;		case	handState:			[[MyCursor handCursor] set];			break;		case	handClosedState:			[[MyCursor handClosedCursor] set];			break;		case	plusState:			[[MyCursor plusCursor] set];			break;		case	zoomTopLeftState:			[[MyCursor zoomTopLeftCursor] set];			break;		case	zoomTopRightState:			[[MyCursor zoomTopRightCursor] set];			break;		case	zoomBottomLeftState:			[[MyCursor zoomBottomLeftCursor] set];			break;		case	zoomBottomRightState:			[[MyCursor zoomBottomRightCursor] set];			break;		case	minusState:			[[MyCursor minusCursor] set];			break;	}}- (void)resetCursorRects{    NSRect		myBounds	= [self bounds];		[self setMyCursor:currentState];	[self discardCursorRects];	[self addCursorRect:myBounds cursor:[MyCursor currentCursor]];	[[MyCursor currentCursor] setOnMouseEntered:YES];}@end