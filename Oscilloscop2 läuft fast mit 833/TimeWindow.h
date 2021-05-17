//
//  TimeWindow.h
//  BodeDiagram
//
//  Created by Heinz-Jšrg on Sun Jun 1 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.


#import <Cocoa/Cocoa.h>
@class	TimeView;
@class	FilterWindow;
@class	GenericPattern;

@protocol ActivateProtocol;

@interface TimeWindow : NSWindow < ActivateProtocol >
{
    IBOutlet NSPopUpButton	*timeFunction;
    IBOutlet NSSlider		*timeSlider;
    IBOutlet TimeView		*timeView;
	IBOutlet NSTextField	*frequencyEditField;
	IBOutlet NSStepper		*frequencyStepper;
	IBOutlet NSTextField	*samplingFrequency;
	IBOutlet NSTextField	*asymmetryEditField;
	IBOutlet NSStepper		*asymmetryStepper;
	IBOutlet NSTextField	*equalizerEditField;
	IBOutlet NSStepper		*equalizerStepper;
	IBOutlet NSTextField	*offsetEditField;
	IBOutlet NSStepper		*offsetStepper;
	IBOutlet NSTextField	*noiseEditField;
	IBOutlet NSStepper		*noiseStepper;
	IBOutlet NSTextField	*limitValueEditField;
	IBOutlet NSStepper		*limitValueStepper;
	IBOutlet NSTextField	*limitScaleEditField;
	IBOutlet NSStepper		*limitScaleStepper;
}


- (void)					makeKeyAndOrderFront:(id)sender;
- (IBAction)				changeFunction:(id)sender;
- (IBAction)				changeEqualizer:(id)sender;
- (IBAction)				changeSlider:(id)sender;
- (IBAction)				changeFrequency:(id)sender;
- (IBAction)				stepperFrequency:(id)sender;
- (IBAction)				changeAsymmetry:(id)sender;
- (IBAction)				stepperAsymmetry:(id)sender;
- (IBAction)				changeEqualizerValue:(id)sender;
- (IBAction)				stepperEqualizerValue:(id)sender;
- (IBAction)				changePersistance:(id)sender;
- (IBAction)				changeOffsetValue:(id)sender;
- (IBAction)				stepperOffsetValue:(id)sender;
- (IBAction)				changeNoise:(id)sender;
- (IBAction)				stepperNoise:(id)sender;
- (IBAction)				changeLimitValue:(id)sender;
- (IBAction)				stepperLimitValue:(id)sender;
- (IBAction)				changeLimitScale:(id)sender;
- (IBAction)				stepperLimitScale:(id)sender;

- (void)					initializePattern;
- (NSPopUpButton *)			getPopUpButton;
- (double)					getFrequency;
- (double)					getAsymmetry;
- (double)					getOffset;
- (double)					getNoiseLevel;
- (double)					getLimitValue;
- (double)					getLimitScale;
- (TimeView *)				getTimeView;
- (void)					setFrequency:(double)hertz;

@end
