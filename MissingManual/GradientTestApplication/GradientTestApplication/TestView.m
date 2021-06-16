//
//  TestView.m
//  GradientTestApplication
//
//

#import <QuartzCore/QuartzCore.h>

#import "TestView.h"

@implementation TestView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    self.wantsLayer = YES;
    CAGradientLayer *gradientLayer = CAGradientLayer.layer;
    gradientLayer.frame = self.bounds;
    gradientLayer.locations = @[@0.926711, @1.000000];
    gradientLayer.startPoint = NSMakePoint(0.376816, 0.426236);
    gradientLayer.endPoint   = NSMakePoint(0.159694, 0.157326);
    gradientLayer.type = kCAGradientLayerRadial;
    NSColorSpace *cs = [[NSColorSpace alloc]
                        initWithCGColorSpace:CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)
                        ];
    const CGFloat startComponents[] = {0.899135, 0.426617, 0.065031, 1.000000};
    NSColor *startColor = [NSColor colorWithColorSpace:cs components:startComponents count:4];
    const CGFloat endComponents[] = {0.678343, 0.864587, 1.000000, 1.000000};
    NSColor *endColor = [NSColor colorWithColorSpace:cs components:endComponents count:4];
    gradientLayer.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
    [self.layer addSublayer:gradientLayer];


    
    // /Drawing code here.

}

@end
