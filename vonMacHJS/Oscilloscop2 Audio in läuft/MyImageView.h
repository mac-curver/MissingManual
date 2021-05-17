/* MyImageView */#import <Cocoa/Cocoa.h>#import "SoundInputGrabber.h"@class		MyDocument;@interface MyImageView : ScientificImage{    IBOutlet MyDocument			*myDocument;    IBOutlet NSTextField		*alphaText;    IBOutlet NSTextField		*compositeModeText;    IBOutlet NSTextField		*densityText;    IBOutlet NSTextField		*timeText;    IBOutlet NSTextField		*triggerLevelText;    IBOutlet NSTextField		*triggerPositionText;	IBOutlet NSSlider			*timingSlider;	IBOutlet NSSlider			*yOffsetSlider;	IBOutlet NSSlider			*yScaleSlider;    IBOutlet NSTextField		*whiteText;	IBOutlet NSPopUpButton		*remanenzPopUpButton;	IBOutlet NSTextField		*test;	IBOutlet NSButton			*histogram;	IBOutlet NSButton			*continousButton;	IBOutlet NSButton			*audio;		NSSize						mySize;	NSImage						*currentImage;				//  actual image	NSImage						*gridImage;					//  image from grid	    NSTimer 					*repeatTimer;				// timer that controls how often we draw	double						myAlpha;	double						myWhite;	double						myDensity;	int							myCompositeMode;	double						samplingPeriod;	int							overPrint;	int							state;    double						xStart;	double						xStop;    SoundInputGrabber			*grabber;}- (IBAction)			drawHistogram:(id)sender;- (IBAction)			changeStart:(id)sender;- (IBAction)			doAudio:(id)sender;- (IBAction)			doTrigger:(id)sender;- (IBAction)			changeTriggerLevel:(id)sender;- (IBAction)			changeTriggerPosition:(id)sender;- (IBAction)			changeTriggerMode:(id)sender;- (IBAction)			changeTiming:(id)sender;- (IBAction)			changeOffset:(id)sender;- (IBAction)			changeScale:(id)sender;- (IBAction)			changeRemanenz:(id)sender;- (void)				drawAxis;- (void)				setTimerRunning:(BOOL)run;- (void)				sizeDidChange:(NSNotification *)notification;- (void)				drawAnother:(id)timer;- (void)				drawAudioBuffer;- (void)				drawCharBuffer;@end