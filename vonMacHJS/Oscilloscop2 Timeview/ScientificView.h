//
//  ScientificView.h
//  BodeDiagram
//
//  Created by Heinz-J�rg on Sun Jun 1 2003.
//  Copyright (c) 2003 Heinz-J�rg SCHR�DER. All rights reserved.

#import <Cocoa/Cocoa.h>

@class GraphAxis;									// should be replaced by HorizontalGraphAxis and VerticalGraphAxis%%%%%
@class HorizontalGraphAxis;	
@class VerticalGraphAxis;	

// mouse cursor states
enum {
	arrowState, handState, handClosedState, plusState, minusState, zoomTopRightState, zoomTopLeftState, zoomBottomRightState, zoomBottomLeftState
};

// text position constants gives text vs point position 
enum {
	topLeft = 1,			//
	topCenter,				// (bottom right)     (bottom center)     (bottom left)
	topRight,				//         *******   *******   *    *   *******
	left,					//            *      *          *  *       *
	center,					//   (right)  *      **** (center)*		   *  (left)
	right,					//            *      *          *  *	   *
	bottomLeft,				//            *		 *******   *    *      *
	bottomCenter,			//  (top right)	       (top center)         (top left)
	bottomRight				//
};


@interface ScientificView : NSView
{
    IBOutlet HorizontalGraphAxis	*horizontalAxis;
    IBOutlet VerticalGraphAxis		*secondaryAxis;
    IBOutlet VerticalGraphAxis		*verticalAxis;

	NSRect				viewRect;					// rect inside view where drawing takes place in global coordinates
    NSRect				windowRect;					// maximum window in user coordinates 
													// offset to origin
													// width = 1/xScale, height = 1/yScale
    NSRect				secondaryRect;				// secondary window in user coordinates
    NSRect				*currentRect;				// either windowRect or secondaryRect
	double				x_scale;
	double				x_offset;
	double				y_scale;
	double				y_offset;

	int					currentState;				// state: zoom-in, zoom-out, drag, etc
	NSRect				rubberbandRect;				// for the selection
	BOOL				penIsDown;					// for plot statement to indicate penstate
	double				symbolSize;					// half of centered symbol size
	NSPoint				cursorPosition;				// last point drawn
	NSTrackingRectTag	trackingTag;				// for the mouse move (setBounds)

    NSMutableDictionary *attrs;
}

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;

- (void)	zoomInFromPoint:(NSPoint)mouseLoc;
- (void)	zoomOutFromPoint:(NSPoint)mouseLoc;
- (void)	zoomInToRect:(NSRect)mouseRect;

- (void)	windowFromX:(float)xmin ToX:(float)xmax AndFromY:(float)ymin ToY:(float)ymax;
- (void)	secondaryFromX:(float)xmin ToX:(float)xmax AndFromY:(float)ymin ToY:(float)ymax;
- (void)	secondaryFromX:(float)xmin ToX:(float)xmax;
- (void)	choosePrimary;
- (void)	chooseSecondary;
- (void)	calcScaling;
- (double)	minX;									// returns minimum x-value
- (double)	maxX;									// returns maximum x-value
- (NSRect)	windowRect;								// first window in user coordinates 
- (NSRect)	secondaryRect;							// secondary window in user coordinates
- (void)	setWindowRect:(NSRect)newRect;			// first window in user coordinates 
- (void)	setSecondaryRect:(NSRect)newRect;		// secondary window in user coordinates

- (void)	penup;
- (void)	pendown;
- (void)	lineWidth:(float)width;
- (void)	move:(float)dx :(float)dy;				// move relative
- (void)	moveto:(float)x :(float)y;				// move absolute
- (void)	draw:(float)dx :(float)dy;				// draw relative
- (void)	drawto:(float)x :(float)y;				// draw absolute
- (void)	plot:(float)dx :(float)dy;				// plot relative 
- (void)	plotto:(float)x :(float)y;				// plot absolute
- (void)	setColor:(NSColor *)newColor;			// set color for following outputs
- (void)	drawString:(NSString *)markString 
				alignment:(int)textAlignment;		// draw string at cursor position
- (void)	setSymbolSize:(int)newSymbolSize;		// set symbol size
- (void)	drawCenteredSymbol:(int)symbolCode;		// draw a oval, glyph or rectangle
- (void)	setMyCursor:(int)state;					// set new state

@end
