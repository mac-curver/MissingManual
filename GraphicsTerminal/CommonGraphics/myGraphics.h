
#import			<Cocoa/Cocoa.h>


CGContextRef	getCGContextRef(void);
CGContextRef	getCGContextRefFromWindow(NSWindow* window);

void			setCGClipRect(CGContextRef context, const CGRect* bounds);
void 			filet(CGContextRef context, double x1, double y1,
                      double x2, double y2,
                      double x3, double y3,
                      double radius, int closed
                );
void 			circle(CGContextRef context, double xc, double yc,
                       double radius
                );
void			paintCGCrosshair(const CGRect* myBounds, double h,
                    double v
                );

void			drawManyStars(CGContextRef context, double h, double v,
                    double hScale, double vScale, int howMany, int corners
                );
void			drawStar(CGContextRef context, int corners);


