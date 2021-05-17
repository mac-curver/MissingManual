//
// a very simple Cocoa CoreAudio app
// by James McCartney  james@audiosynth.com  www.audiosynth.com
//
// SinewaveController - this controller class manages the GUI and forwards actions to the Sinewave oscillator.
//

#import <Cocoa/Cocoa.h>
#include <CoreAudio/AudioHardware.h>


@interface FrequencyGeneratorController : NSObject
{
	IBOutlet NSPopUpButton		*OscTypeLeftPopUpButton;
	IBOutlet NSPopUpButton		*OscTypeRightPopUpButton;
	IBOutlet NSSlider			*amplitudeControlLeft;
	IBOutlet NSSlider			*amplitudeControlRight;
	IBOutlet NSTextField		*amplitudeFieldLeft;
	IBOutlet NSTextField		*amplitudeFieldRight;
	IBOutlet NSSlider			*phaseControl;
	IBOutlet NSTextField		*phaseField;
	IBOutlet NSSlider			*frequencyControlLeft;
	IBOutlet NSSlider			*frequencyControlRight;
	IBOutlet NSTextField		*frequencyControlFieldLeft;
	IBOutlet NSTextField		*frequencyControlFieldRight;
	IBOutlet NSSlider			*dutyCycleControlLeft;
	IBOutlet NSSlider			*dutyCycleControlRight;
	IBOutlet NSTextField		*dutyCycleFieldLeft;
	IBOutlet NSTextField		*dutyCycleFieldRight;
	IBOutlet NSSlider			*mixerControl;
	IBOutlet NSTextField		*mixerField;
	IBOutlet NSTextField		*parameterLeft;
	IBOutlet NSTextField		*parameterRight;
	IBOutlet NSTextField		*audioDeviceText;
	IBOutlet NSButton			*startStopButton;
	IBOutlet NSBox				*parameterBox;
	IBOutlet id					oscillator;
	IBOutlet NSPopUpButton		*outputDevicePopUpButton;
	IBOutlet NSMenuItem			*showController;
	ToneToHertzTransformer		*halftoneToHzTransformer;
	
	NSMutableArray				*deviceArray;
	NSTimer 					*repeatTimer;				// timer that controls how often change the mode
}

- (void)    setTimerRunning:(BOOL)run;
- (void)    switchType:(id)timer;
- (void)	updateDeviceList;

- (IBAction)setAmpLeft:(id)sender;
- (IBAction)setAmpRight:(id)sender;
- (IBAction)setPhase:(id)sender;
- (IBAction)setFreqLeft:(id)sender;
- (IBAction)setFreqRight:(id)sender;
- (IBAction)setFreqHzLeft:(id)sender;
- (IBAction)setFreqHzRight:(id)sender;
- (IBAction)setDutyCycleLeft:(id)sender;
- (IBAction)setDutyCycleRight:(id)sender;
- (IBAction)setOscillatorTypeLeft:(id)sender;
- (IBAction)setOscillatorTypeRight:(id)sender;
- (IBAction)setMixer:(id)sender;
- (IBAction)setOutputDevice:(id)sender;

- (IBAction)startStop:(id)sender;
- (IBAction)run:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)record:(id)sender;
@end
