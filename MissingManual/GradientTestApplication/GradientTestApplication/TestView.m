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
    gradientLayer.locations = @[@0.000000, @0.526155];
    gradientLayer.startPoint = NSMakePoint(0.984460, 0.270354);
    gradientLayer.endPoint   = NSMakePoint(-0.009779, 0.266456);
    gradientLayer.type = kCAGradientLayerAxial;
    CGColorSpaceRef cgColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    NSColorSpace *cs = [[NSColorSpace alloc]
                        initWithCGColorSpace:cgColorSpace
                        ];
    const CGFloat startComponents[] = {1.000000, 0.000000, 1.000000, 1.000000};
    NSColor *startColor = [NSColor colorWithColorSpace:cs components:startComponents count:4];
    const CGFloat endComponents[] = {0.835221, 0.835221, 0.000000, 1.000000};
    NSColor *endColor = [NSColor colorWithColorSpace:cs components:endComponents count:4];
    gradientLayer.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
    [self.layer addSublayer:gradientLayer];
    CGColorSpaceRelease(cgColorSpace);


    
    // /Drawing code here.

}

@end
