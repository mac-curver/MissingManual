//
//  MyImageView.h
//  Oscilloscope
//
//  Created by Heinz-J�rg on Sun Jun 1 2003.
//  Copyright (c) 2003 Heinz-J�rg SCHR�DER. All rights reserved.
//
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
	IBOutlet NSMatrix		   *yOffsetMatrix;
	IBOutlet NSMatrix		   *yScaleMatrix;
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
	
    AudioInput				   *grabber;
	NSImage					   *currentImage;				//  image we paint into
	NSImage					   *gridImage;					//  image from grid
	NSSize						mySize;
	
    NSTimer 				   *repeatTimer;				// timer that controls how often we draw

	double						myAlpha;
    double						xFineStart;					// delay in sampling period to get exact trigger
    double						xStart;
	double						xStop;
	Boolean						firstScreen;				// true if first screen trigger in nextTrigger
	Boolean						triggerAutoMode;			// 1 if Auto trigger
	unsigned long				triggerIndex;				// index location where trigger event occurs
	unsigned					triggerStartState;			// startstate for trigger state machine
	float					   *triggerBuffer;				// pointer to the data of the trigger channel
	unsigned long				triggerBufferLength;		// number of data points in the trigger channel
	
	NSInteger					triggerPosition;			// horizontal trigger position
	NSInteger					triggerChannel;				// 0...3 which channel to trigger on
	NSInteger					triggerPolarity;			// +1 for positive edge, -1 for negative edge
	double						triggerLevel;				// trigger level
	NSInteger					triggerMode;				// integer value for trigger mode
	double						timingValue;				// setting for timing slider
	NSInteger					remanenzValue;				// setting for remanenz
	float						yOffsetArray[8];
	float						yScaleArray[8];
	Boolean						channelDisplay[8];
	Boolean						showGroundMarkers;			// add small trinagles to indicate ground level
	Boolean						inverseDisplay;				// true if display is white on black
	NSColor						*colorChannel[4];
	NSColor						*colorM[4];
	NSColor						*colorGrid;
	NSColor						*colorBckgnd;
	NSColor						*colorCursor;
	NSColor						*colorSpecial;
#ifdef OLD
#else
    NSPoint						center, speed;
    NSColor						*color;
    float						radius;
#endif
}


- (float)				yOffsetValue:(NSInteger)channel;
- (void)				setYOffsetValue:(float)newValue channel:(NSInteger)channel;
- (float)				yScaleValue:(NSInteger)channel;
- (void)				setYScaleValue:(float)newValue channel:(NSInteger)channel;


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
- (NSInteger)					remanenzValue;
- (void)				setRemanenzValue:(NSInteger)value;
- (NSInteger)					triggerHoldTime;
- (void)				setTriggerHoldTime:(NSInteger)value;
- (NSInteger)					triggerMode;
- (void)				setTriggerMode:(NSInteger)value;

- (void)				setTriggerLevel:(double)value;
- (double)				triggerLevel;
- (void)				setTriggerPosition:(NSInteger)value;
- (NSInteger)					triggerPosition;
- (void)				setTriggerChannel:(NSInteger)value;
- (NSInteger)					triggerChannel;
- (void)				setTriggerPolarity:(BOOL)value;
- (BOOL)				triggerPolarity;

- (void)				initFirstDisplay;
- (void)				setGrabber:(id)sender;
- (void)				enableChannel:(NSInteger)channel enabled:(Boolean)enabled;
- (void)				drawAxis;
- (void)				setTimerRunning:(BOOL)run;
- (void)				sizeDidChange:(NSNotification *)notification;

- (void)				drawAnother:(id)timer;
- (void)				nextTrigger;

- (void)				dealloc;


@end
