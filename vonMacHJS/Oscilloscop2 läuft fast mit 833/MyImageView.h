//
//  MyImageView.h
//  Oscilloscope
//
//  Created by Heinz-Jšrg on Sun Jun 1 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.
//
//  Version 1.40: 14.04.2021        all float replaced by double!
//	Version 1.30: 28.12.2004		all double replaced by float!

#import		<Cocoa/Cocoa.h>



@class		MyDocument;
@class		AudioInput;



@interface MyImageView : ScientificImage
{
    IBOutlet MyDocument		   *myDocument;
    IBOutlet NSTextField	   *compositeModeText;
    IBOutlet NSTextField	   *triggerLevelText;
    IBOutlet NSStepper		   *triggerLevelStepper;
    IBOutlet NSTextField	   *triggerPositionText;
    IBOutlet NSStepper		   *triggerPositionStepper;
    IBOutlet NSSlider		   *triggerPositionSlider;
	IBOutlet NSButton		   *retriggerButton;
	IBOutlet NSSlider		   *timingSlider;
	IBOutlet NSMatrix		   *triggerMatrix;
	IBOutlet NSPopUpButton	   *triggerModeButton;
	IBOutlet NSMatrix		   *channelMatrix;
	IBOutlet NSMatrix		   *sumMatrix;
	IBOutlet NSPopUpButton	   *remanenzPopUpButton;
	IBOutlet NSButton		   *showGroundMarkersButton;
	IBOutlet NSTextField	   *test;
	IBOutlet NSButton		   *risingEdge;
	IBOutlet NSColorWell	   *colorChannel0;
	IBOutlet NSColorWell	   *colorChannel1;
	IBOutlet NSColorWell	   *colorChannel2;
	IBOutlet NSColorWell	   *colorChannel3;
	IBOutlet NSColorWell	   *colorM0;
	IBOutlet NSColorWell	   *colorM1;
	IBOutlet NSColorWell	   *colorM2;
	IBOutlet NSColorWell	   *colorM3;
	IBOutlet NSColorWell	   *colorWellGrid;
	IBOutlet NSColorWell	   *colorWellBckgnd;
	IBOutlet NSColorWell	   *colorWellCursor;
	IBOutlet NSColorWell	   *colorWellSpecial;
	IBOutlet NSDrawer		   *colorDrawer;
	IBOutlet NSDrawer		   *parameterDrawer;
	IBOutlet NSMatrix		   *showButtons;
    
    IBOutlet NSSlider          *offsetSlider0;
    IBOutlet NSSlider          *offsetSlider1;
    IBOutlet NSSlider          *offsetSlider2;
    IBOutlet NSSlider          *offsetSlider3;
    IBOutlet NSSlider          *offsetSlider4;
    IBOutlet NSSlider          *offsetSlider5;
    IBOutlet NSSlider          *offsetSlider6;
    IBOutlet NSSlider          *offsetSlider7;

    IBOutlet NSStepper         *offsetStepper0;
    IBOutlet NSStepper         *offsetStepper1;
    IBOutlet NSStepper         *offsetStepper2;
    IBOutlet NSStepper         *offsetStepper3;
    IBOutlet NSStepper         *offsetStepper4;
    IBOutlet NSStepper         *offsetStepper5;
    IBOutlet NSStepper         *offsetStepper6;
    IBOutlet NSStepper         *offsetStepper7;
    
    IBOutlet NSSlider          *scaleSlider0;
    IBOutlet NSSlider          *scaleSlider1;
    IBOutlet NSSlider          *scaleSlider2;
    IBOutlet NSSlider          *scaleSlider3;
    IBOutlet NSSlider          *scaleSlider4;
    IBOutlet NSSlider          *scaleSlider5;
    IBOutlet NSSlider          *scaleSlider6;
    IBOutlet NSSlider          *scaleSlider7;
    
    IBOutlet NSStepper         *scaleStepper0;
    IBOutlet NSStepper         *scaleStepper1;
    IBOutlet NSStepper         *scaleStepper2;
    IBOutlet NSStepper         *scaleStepper3;
    IBOutlet NSStepper         *scaleStepper4;
    IBOutlet NSStepper         *scaleStepper5;
    IBOutlet NSStepper         *scaleStepper6;
    IBOutlet NSStepper         *scaleStepper7;


    NSArray                    *yOffsetMatrix;
    NSArray                    *yScaleMatrix;

    AudioInput				   *grabber;
	NSImage					   *currentImage;				//  image we paint into
	NSImage					   *gridImage;					//  image from grid
	NSSize						mySize;
	
    NSTimer 				   *repeatTimer;				// timer that controls how often we draw

	double						myAlpha;
    double						xFineStart;					// delay in sampling period to get exact trigger between 0...1
    double						xStart;
	double						xStop;
	Boolean						firstScreen;				// true if first screen trigger in nextTrigger
	Boolean						triggerAutoMode;			// 1 if Auto trigger
	unsigned long				triggerIndex;				// index location where trigger event occurs
	unsigned					triggerStartState;			// startstate for trigger state machine
	double					   *triggerBuffer;				// pointer to the data of the trigger channel
	unsigned long				triggerBufferLength;		// number of data points in the trigger channel
	
    NSInteger                   remanenzValue;              // setting for remanenz
	NSInteger					triggerPolarity;			// +1 for positive edge, -1 for negative edge
	NSInteger					triggerMode;				// integer value for trigger mode
	double						timingValue;				// setting for timing slider
	double					    yOffsetArray[8];
	double					    yScaleArray[8];
	Boolean						channelDisplay[8];
	Boolean						showGroundMarkers;			// add small trinagles to indicate ground level
	Boolean						inverseDisplay;				// true if display is white on black
	NSColor					   *colorChannel[4];
	NSColor					   *colorM[4];
	NSColor					   *colorGrid;
	NSColor					   *colorBckgnd;
	NSColor					   *colorCursor;
	NSColor					   *colorSpecial;
    BOOL                        bufferIsFilled;
    NSPoint                     points[3];

#ifdef OLD
#else
    NSPoint						circleCenter, circleSpeed;
    NSColor					   *circleColor;
    double						circleRadius;
#endif
}


- (double)				yOffsetValue:(NSInteger)channel;
- (void)				setYOffsetValue:(double)newValue channel:(NSInteger)channel;
- (double)				yScaleValue:(NSInteger)channel;
- (void)				setYScaleValue:(double)newValue channel:(NSInteger)channel;


- (IBAction)			drawHistogram:(id)sender;
- (IBAction)			changeStart:(id)sender;
- (IBAction)			doTrigger:(id)sender;
- (IBAction)			changeRisingEdge:(id)sender;
- (IBAction)			changeTriggerChannel:(id)sender;
- (IBAction)			changeTriggerLevel:(id)sender;
- (IBAction)			changeTriggerPosition:(id)sender;
- (IBAction)			changeTriggerPositionRelative:(id)sender;
- (IBAction)			changeTriggerMode:(id)sender;
- (IBAction)			changeTiming:(id)sender;
- (IBAction)			changeOffsetMatrix:(id)sender;
- (IBAction)			changeScaleMatrix:(id)sender;
- (IBAction)			changeMathOffsetMatrix:(id)sender;
- (IBAction)			changeMathScaleMatrix:(id)sender;
- (IBAction)			changeChannel:(id)sender;
- (IBAction)			changeSum:(id)sender;
- (IBAction)			changeShowGroundMarkers:(id)sender;
- (IBAction)			changeInverseDisplay:(id)sender;
- (IBAction)			colorChannel0:(id)sender;
- (IBAction)			colorChannel1:(id)sender;
- (IBAction)			colorChannel2:(id)sender;
- (IBAction)			colorChannel3:(id)sender;
- (IBAction)			colorM0:(id)sender;
- (IBAction)			colorM1:(id)sender;
- (IBAction)			colorM2:(id)sender;
- (IBAction)			colorM3:(id)sender;
- (IBAction)			colorGrid:(id)sender;
- (IBAction)			colorBckgnd:(id)sender;
- (IBAction)			colorCursor:(id)sender;
- (IBAction)			colorSpecial:(id)sender;
- (IBAction)			toggleDrawer:(id)sender;

- (double)				timingValue;
- (void)				setTimingValue:(double)value;
- (NSInteger)			triggerMode;
- (void)				setTriggerMode:(NSInteger)value;



- (void)                setRemanenzValue:(NSInteger)value;
- (NSInteger)           remanenzValue;

- (void)				setTriggerPolarity:(BOOL)value;
- (BOOL)				triggerPolarity;

- (void)				initFirstDisplay;
- (void)				setGrabber:(AudioInput *)sender;
- (void)				enableChannel:(NSInteger)channel enabled:(Boolean)enabled;
- (void)				drawAxis;
- (void)				setTimerRunning:(BOOL)run;
- (void)				sizeDidChange:(NSNotification *)notification;

- (void)				drawAnother:(id)timer;
- (void)				nextTrigger;

- (void)				dealloc;

@property double        triggerLevel;
@property NSInteger     triggerPosition;
@property NSInteger     triggerChannel;
@property NSInteger     triggerHoldTime;




@end
