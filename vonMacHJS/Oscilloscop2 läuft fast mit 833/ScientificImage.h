////  ScientificView.h//  Oscilloscope////  Created by Heinz-J�rg on Sun Jun 1 2003.//  Copyright (c) 2003 Heinz-J�rg SCHR�DER. All rights reserved.////    Version 1.40: 16.04.2021        all float replaced by double!//    Version 1.30: 28.12.2004        all double replaced by float!#import		<Cocoa/Cocoa.h>//#import		"MyDocument.h"							//please remove this@class		ImageAxis;									// should be replaced by HorizontalImageAxis and VerticalImageAxis%%%%%@class		HorizontalImageAxis;	@class		VerticalImageAxis;	// mouse cursor statesenum {	arrowState, handState, handClosedState, plusState, minusState, zoomTopRightState, zoomTopLeftState, zoomBottomRightState, zoomBottomLeftState};// text position constants gives text vs point position enum {	topLeft = 1,	//	topCenter,		// (bottom right)     (bottom center)     (bottom left)	topRight,		//         *******   *******   *    *   *******	left,			//            *      *          *  *       *	center,			//   (right)  *      **** (center)*		   *  (left)	right,			//            *      *          *  *	   *	bottomLeft,		//            *		 *******   *    *      *	bottomCenter,	//  (top right)	       (top center)         (top left)	bottomRight		//};@interface ScientificImage : NSImageView{        IBOutlet HorizontalImageAxis	*horizontalAxis;    IBOutlet VerticalImageAxis		*secondaryAxis;    IBOutlet VerticalImageAxis		*verticalAxis;	NSRect				viewRect;					// rect inside view where drawing takes place in global coordinates    NSRect				windowRect;					// maximum window in user coordinates 													// offset to origin													// width = 1/xScale, height = 1/yScale    NSRect				secondaryRect;				// secondary window in user coordinates    NSRect				*currentRect;				// either windowRect or secondaryRect	double				x_scale;	double				x_offset;	double				y_scale;	double				y_offset;	int					currentState;				// state: zoom-in, zoom-out, drag, etc	NSRect				rubberbandRect;				// for the selection	BOOL				penIsDown;					// for plot statement to indicate penstate	double				symbolSize;					// half of centered symbol size	NSPoint				cursorPosition;				// last point drawn	NSTrackingRectTag	trackingTag;				// for the mouse move (setBounds)    NSMutableDictionary *attrs;}- (IBAction)zoomIn:(id)sender;- (IBAction)zoomOut:(id)sender;- (void)	zoomInFromPoint:(NSPoint)mouseLoc;- (void)	zoomOutFromPoint:(NSPoint)mouseLoc;- (void)	zoomInToRect:(NSRect)mouseRect;- (void)	windowFromX:(double)xmin ToX:(double)xmax AndFromY:(double)ymin ToY:(double)ymax;- (void)	secondaryFromX:(double)xmin ToX:(double)xmax AndFromY:(double)ymin ToY:(double)ymax;- (void)	secondaryFromX:(double)xmin ToX:(double)xmax;- (void)	choosePrimary;- (void)	chooseSecondary;- (void)	choosePrimaryNew;- (void)	chooseSecondaryNew;- (void)	setViewRectToBounds;- (void)	setViewRect:(NSRect)myRect;- (NSRect)	viewRect;- (void)	calcScaling;- (double)	minX;									// returns minimum x-value- (double)	maxX;									// returns maximum x-value- (NSRect)	windowRect;								// first window in user coordinates - (NSRect)	secondaryRect;							// secondary window in user coordinates- (void)	setWindowRect:(NSRect)newRect;			// first window in user coordinates - (void)	setSecondaryRect:(NSRect)newRect;		// secondary window in user coordinates- (void)	penup;- (void)	pendown;- (void)	lineWidth:(double)width;- (void)	move:(double)dx :(double)dy;			// move relative- (void)	moveto:(double)x :(double)y;			// move absolute- (void)	draw:(double)dx :(double)dy;			// draw relative- (void)	drawto:(double)x :(double)y;			// draw absolute- (void)	plot:(double)dx :(double)dy;			// plot relative- (void)	plotto:(double)x :(double)y;			// plot absolute- (void)	plotData:(double*)buffer                startIndex:(unsigned long)index                    length:(unsigned long)length                      from:(double)xStart                        to:(double)xStop;- (void)	setColor:(NSColor *)newColor;			// set color for following outputs- (void)	drawString:(NSString *)markString 				alignment:(int)textAlignment;		// draw string at cursor position- (void)	setSymbolSize:(int)newSymbolSize;		// set symbol size- (void)	drawTriangleSymbol:(int)symbolDirection;// small triangle- (void)	drawCenteredSymbol:(int)symbolCode;		// draw a oval, glyph or rectangle- (void)	setMyCursor:(int)state;					// set new state@end