//
//  TestGradient.h
//  GradientTestApplication
//
//  Created by Heinz-Jörg on 23.05.21.
//  Copyright © 2021 Heinz-Jörg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

enum GradientKind: NSInteger {
      Linear
    , Radial
    , Conic
} GradientKind;

@interface TestGradient : NSView {
    

}
- (IBAction)myPanGesture:(NSPanGestureRecognizer *)sender;

@property(assign)  NSColor              *startColor;
@property(assign)  NSColor              *endColor;
@property(assign)  double                startLocation;
@property(assign)  double                endLocation;
@property(assign)  NSPoint               startPoint;
@property(assign)  NSPoint               endPoint;
@property(assign)  double                startRadius;
@property(assign)  double                endRadius;

@property(assign)  enum GradientKind     kind;

//@property(assign) CAGradientLayer       *gradient;



- (IBAction)updateKind:(NSSegmentedControl *)sender;
- (IBAction)updateStartColor:(NSColorWell *)sender;
- (IBAction)updateEndColor:(NSColorWell *)sender;
- (IBAction)updateStartLocation:(NSTextField *)sender;
- (IBAction)updateEndLocation:(NSTextField *)sender;
- (IBAction)sliderStartLocation:(NSSlider *)sender;
- (IBAction)sliderEndLocation:(NSSlider *)sender;

- (IBAction)updateStartRadius:(NSTextField *)sender;
- (IBAction)updateEndRadius:(NSTextField *)sender;
- (IBAction)stepperStartRadius:(NSStepper *)sender;
- (IBAction)stepperEndRadius:(NSStepper *)sender;

@end

NS_ASSUME_NONNULL_END
