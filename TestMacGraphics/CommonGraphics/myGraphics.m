
#include <ApplicationServices/ApplicationServices.h>
//#include "logFile.h"
#include "myGraphics.h"

			
// Implementation



CGContextRef getCGContextRefFromWindow(NSWindow* window) {
    
	// Get the core graphics context from MyView's window
	// call: windowContext = getCGContextRefFromWindow(graphicsContextWithWindow:[self window]);
    return nil; //[[NSGraphicsContext window] graphicsPort];
}

void	setCGClipRect(CGContextRef context, const CGRect* bounds) {
	CGContextBeginPath(context);
	CGContextAddRect(context, *bounds);
    CGContextClosePath(context);
	CGContextStrokePath(context);
    CGContextClip(context);
}



void filet(CGContextRef context, double x1, double y1,
                                 double x2, double y2,
                                 double x3, double y3,
                                 double radius, int closed
) {

	CGContextBeginPath(context);
	CGContextMoveToPoint(context, x1, y1);

	CGContextAddArcToPoint(context, x2, y2, x3, y3, radius);
	CGContextAddLineToPoint(context, x3, y3);
	//-
	if (closed) {
		CGContextClosePath(context);
	}
	CGContextSetLineWidth(context, 1);
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
	CGContextStrokePath(context);

}

#define			PI				M_PI							// 3.14159265358979323846
#define 		STARTANGLE 		0
#define 		STOPANGLE 		(2*PI)
#define 		CCW				0
#define 		CW				1

void	circle(CGContextRef context, double xc, double yc, double radius)
{
	CGContextBeginPath(context);
	//CGContextAddArc(context, w/2, h/2, ((w>h) ? h : w)/2, STARTANGLE, STOPANGLE, CCW);
	CGContextAddArc(context, xc, yc, radius, STARTANGLE, STOPANGLE, CCW);
	CGContextClosePath(context);
	CGContextSetLineWidth(context, 1);
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
	CGContextStrokePath(context);
	//CGContextClip(context);
}

void	paintCGCrosshair(const CGRect* myBounds, double h, double v)
{
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, v)
                              toPoint:NSMakePoint(myBounds->size.width, v)
     ];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(h, 0)
                              toPoint:NSMakePoint(h, myBounds->size.height)
     ];
}

void	drawManyStars(CGContextRef context, double h, double v,
                      double hScale, double vScale,
                      int howMany, int corners
) {
    int					i;
	
    CGContextTranslateCTM(context, h, v);
	CGContextScaleCTM(context, hScale, vScale);
	
	for (i = 0; i < howMany; i++) {
        CGContextSetRGBFillColor(context, i/19.0, i/30.0, 0.0, 1.0);
		drawStar(context, corners);
    }
}

void drawStar(CGContextRef context, int corners) {
    int					j;
    double				a0, a1;

	CGContextScaleCTM(context, 0.9, 0.9);
	CGContextMoveToPoint(context, 1.0, 0.0);
	for (j = 0; j < corners; j++) {
		a0 = 2 * M_PI * (j + 0.5) / corners;
		a1 = 2 * M_PI * (j + 1.0) / corners;
		CGContextAddCurveToPoint(context, 2*cos(a0), 2*sin(a0), 2*cos(a0), 2*sin(a0), cos(a1), sin(a1));
	}
	CGContextClosePath(context);
	CGContextFillPath(context);
}



