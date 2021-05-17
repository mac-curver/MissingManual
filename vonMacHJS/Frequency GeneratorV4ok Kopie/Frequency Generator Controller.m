//
// a very simple Cocoa CoreAudio app
// by James McCartney  james@audiosynth.com  www.audiosynth.com
// largely changed by HJS 2005-2006
// Frequency Generator Controller - this controller class manages the GUI and
// forwards actions to the Frequency Generator.
//

#import "ToneToHertzTransformer.h"
#import "Frequency Generator Controller.h"
#import "Frequency Generator.h"
#import <CoreAudio/CoreAudio.h>


static OSStatus GetAudioDevices(Ptr * devices, UInt16 * devicesAvailable ) {
    OSStatus	err = noErr;
    UInt32 		outSize;
    Boolean		outWritable;
    
    // find out how many audio devices there are, if any
    err = AudioHardwareGetPropertyInfo(kAudioHardwarePropertyDevices,
                                       &outSize, &outWritable
          );
    //err = AudioObjectHasProperty();
    //err = AudioObjectGetPropertyDataSize(kAudioHardwarePropertyDevices, );
    if (err != noErr) {
		return err;
	}
    // calculate the number of device available
	*devicesAvailable = outSize / sizeof(AudioDeviceID);						
    if (*devicesAvailable < 1) {
		fprintf( stderr, "No devices\n" );
		return err;
	}
    
    // make space for the devices we are about to get
    *devices = (Ptr) malloc(outSize);		
    	
    memset(*devices, 0, outSize);			
    err = AudioHardwareGetProperty(kAudioHardwarePropertyDevices,
                                   &outSize, (void *) *devices
          );
    if (err != noErr) {
		return err;
	}

    return err;
}

OSStatus AHPropertyListenerProc(AudioHardwarePropertyID inPropertyID, void *inClientData)
{
	FrequencyGenerator *app = (FrequencyGenerator*)inClientData;
    switch (inPropertyID)
	{
/*
 * These are the other types of notifications we might receive, however,
 * they are beyond the scope of this sample and we ignore them.
 *
        case kAudioHardwarePropertyDefaultInputDevice:
			fprintf(stderr, "AHPropertyListenerProc: default input device changed\n");
        break;
			
        case kAudioHardwarePropertyDefaultOutputDevice:
			fprintf(stderr, "AHPropertyListenerProc: default output device changed\n");
		break;
			
        case kAudioHardwarePropertyDefaultSystemOutputDevice:
			fprintf(stderr, "AHPropertyListenerProc: default system output device changed\n");
		break;
*/
        case kAudioHardwarePropertyDevices:
			[app performSelectorOnMainThread:@selector(updateDeviceList) withObject:nil waitUntilDone:NO];
		break;
			
		default:
			fprintf(stderr, "AHPropertyListenerProc: unknown message\n");
		break;
    }
	return noErr;
}




@implementation FrequencyGeneratorController

- (id) init {
    if ((self = [super init])) {
		// create an autoreleased instance of our value transformer
		halftoneToHzTransformer = [[[ToneToHertzTransformer alloc] init] retain];

		// register it with the name that we refer to it with
		[NSValueTransformer setValueTransformer:halftoneToHzTransformer forName:@"ToneToHertzTransformer"];
	}
	return self;
}


- (void)awakeFromNib {
	[self setAmpLeft:amplitudeControlLeft];										// setup fields with control values
	[self setAmpRight:amplitudeControlRight];
	[self setFreqRight:frequencyControlRight];
	[self setFreqLeft:frequencyControlLeft];
	[self setDutyCycleLeft:dutyCycleControlLeft];
	[self setDutyCycleRight:dutyCycleControlRight];
	[self setOscillatorTypeLeft:OscTypeLeftPopUpButton];
	[self setOscillatorTypeRight:OscTypeRightPopUpButton];
	[self setMixer:mixerControl];
	[self setPhase:phaseControl];
	
	repeatTimer = nil;
	//[self setTimerRunning:YES];												// changes all 100ms
	
	// create empty array to hold device info
	deviceArray = [[NSMutableArray alloc] init];
	if (!deviceArray) {
		return;
	}

	// generate initial device list
	[self updateDeviceList];
	
	// install device notification callback
//#define DEPRECTATED
#ifdef DEPRECTATED
	AudioHardwareAddPropertyListener(kAudioHardwarePropertyDevices,
                                     AHPropertyListenerProc,
                                     self
    );
#else
    // This is a largely undocumented but absolutely necessary
    // requirement starting with OS-X 10.6.  If not called, queries and
    // updates to various audio device properties are not handled
    // correctly.
    
    CFRunLoopRef theRunLoop = NULL;
    AudioObjectPropertyAddress property = {
        kAudioHardwarePropertyRunLoop
        , kAudioObjectPropertyScopeGlobal
        , kAudioObjectPropertyElementMaster
    };
    OSStatus result = AudioObjectSetPropertyData(
                                kAudioObjectSystemObject
                               , &property
                               , 0
                               , NULL
                               , sizeof(CFRunLoopRef)
                               , &theRunLoop
                      );
    if ( result != noErr ) {
    }
    

#endif
	
}


- (void)        setTimerRunning:(BOOL)run
{
    // when running we need a timer instance. If an instance exists already
    // we do nothing
	if ((nil == repeatTimer) && run) {
        repeatTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1
                            target:self
                            selector:@selector(switchType:)
                            userInfo:nil
                            repeats:YES
            	      ] retain];
    } else if ((nil != repeatTimer)  && !run) {
		// remove existing timer instance when we stopped
        [repeatTimer invalidate];
        [repeatTimer release];
        repeatTimer = nil;
    }
}

- (void)    switchType:(id)timer
{
	static	BOOL	which = FALSE;
	
	if (which) {
		[oscillator setOscillatorTypeLeftVal:0];
		[oscillator setOscillatorTypeRightVal:0];
	} else {
		[oscillator setOscillatorTypeLeftVal:1];
		[oscillator setOscillatorTypeRightVal:1];
	}
	which = !which;
}



- (IBAction)setAmpLeft:(id)sender
{
    float ampLeft = [sender floatValue];
    [oscillator setAmpLeftVal:ampLeft/100.0];
}

- (IBAction)setAmpRight:(id)sender
{
    float ampRight = [sender floatValue];
    [oscillator setAmpRightVal:ampRight/100.0];
}

- (IBAction)setFreqLeft:(id)sender
{
    // changed by HJS
    double	frequencyLeft = [[halftoneToHzTransformer transformedValue:sender] doubleValue];
	
    [oscillator setFreqLeftVal:frequencyLeft];
	//[phaseField setDoubleValue:1/0.0];	
}

- (IBAction)setFreqHzLeft:(id)sender
{
    // changed by HJS
    double			frequencyLeft = [sender doubleValue];

    [oscillator setFreqLeftVal:frequencyLeft];
	//[phaseField setDoubleValue:1/0.0];
}

- (IBAction)setFreqRight:(id)sender
{
    // changed by HJS
    double	frequencyRight = [[halftoneToHzTransformer transformedValue:sender] doubleValue];
	
    [oscillator setFreqRightVal:frequencyRight];
	//[phaseField setDoubleValue:1/0.0];
}

- (IBAction)setFreqHzRight:(id)sender
{
    // changed by HJS
    double			frequencyRight = [sender doubleValue];
	
    [oscillator setFreqRightVal:frequencyRight];
	//[phaseField setDoubleValue:1/0.0];
}

- (IBAction)setDutyCycleLeft:(id)sender
{
    double value = [sender doubleValue];
	[oscillator				setDutyCycleLeftVal:value/100.0];	
}

- (IBAction)setDutyCycleRight:(id)sender
{
    double value = [sender doubleValue];
	[oscillator				setDutyCycleRightVal:value/100.0];	
}

- (IBAction)setOscillatorTypeLeft:(id)sender {	
	// added by HJS
	long	oscillatorTypeLeft = [sender indexOfSelectedItem];
	[oscillator setOscillatorTypeLeftVal:oscillatorTypeLeft];
	switch (oscillatorTypeLeft) {
		case rectType:
            [parameterLeft              setHidden:NO];
			[parameterLeft				setStringValue:@"Duty Cycle"];
			[dutyCycleControlLeft		setHidden:NO];
			[dutyCycleFieldLeft			setHidden:NO];
			break;
		case sineSweepType:
            [parameterLeft              setHidden:NO];
			[parameterLeft				setStringValue:@"Freq. Ratio"];
			[dutyCycleControlLeft		setHidden:NO];
			[dutyCycleFieldLeft			setHidden:NO];
			break;
		case oneSevenPatternType:
            [parameterLeft              setHidden:NO];
			[parameterLeft				setStringValue:@"MTF Filter"];
			// retrieve and remember frequency
			[dutyCycleControlLeft		setHidden:NO];
			[dutyCycleFieldLeft			setHidden:NO];
			break;
		default:
            [parameterLeft              setHidden:YES];
            [parameterLeft              setStringValue:@"Unused"];
			[dutyCycleControlLeft		setHidden:YES];
			[dutyCycleFieldLeft			setHidden:YES];
			break;
	}
}

- (IBAction)setOscillatorTypeRight:(id)sender {
	// added by HJS
	long	oscillatorTypeRight = [sender indexOfSelectedItem];
	[oscillator setOscillatorTypeRightVal:oscillatorTypeRight];
	switch (oscillatorTypeRight) {
		case rectType:
            [parameterRight             setHidden:NO];
			[parameterRight				setStringValue:@"Duty Cycle"];
			[dutyCycleControlRight		setHidden:NO];
			[dutyCycleFieldRight		setHidden:NO];
			break;
		case sineSweepType:
            [parameterRight             setHidden:NO];
			[parameterRight				setStringValue:@"Freq. Ratio"];
			[dutyCycleControlRight		setHidden:NO];
			[dutyCycleFieldRight		setHidden:NO];
			break;
		case oneSevenPatternType:
            [parameterRight             setHidden:NO];
			[parameterRight				setStringValue:@"MTF Filter"];
			[dutyCycleControlRight		setHidden:NO];
			[dutyCycleFieldRight		setHidden:NO];
			break;
		default:
            [parameterRight             setHidden:YES];
			[parameterRight				setStringValue:@"Unused"];
			[dutyCycleControlRight		setHidden:YES];
			[dutyCycleFieldRight		setHidden:YES];
			break;
	}
}

- (IBAction)setMixer:(id)sender {
    double mixer = [sender doubleValue];
    [oscillator setMixerVal: mixer/100.0];
}

- (IBAction)setPhase:(id)sender {
	double value = [sender doubleValue];										// in units of unit circle 360 deg == 1
	[oscillator setPhaseVal:value/360.0];
}


- (IBAction)setOutputDevice:(id)sender {
	long			outPutDeviceIndex	= [sender indexOfSelectedItem]-1L;		// the list contains one index more!
	AudioDeviceID	outPutDeviceID		= kAudioDeviceUnknown;

	
	if (0 <= outPutDeviceIndex) {												// 1st or none selected
		NSDictionary	*audioDict = [deviceArray objectAtIndex:outPutDeviceIndex];
		outPutDeviceID = [[audioDict objectForKey:@"id"] intValue];
		[audioDeviceText setIntValue:[[audioDict objectForKey:@"och"] intValue]];
	}
	[oscillator setOutputDeviceID:outPutDeviceID];
}





- (void)	updateDeviceList {
    OSStatus		err = noErr;
    UInt32			outSize = 0;
	UInt32			theNumberOutputChannels = 0;
	UInt32			theIndex = 0;
    UInt16			devicesAvailable = 0;
	UInt16			loopCount = 0;
    AudioDeviceID	*devices = NULL;
	AudioBufferList *theBufferList = NULL;
	
	// Save first entry of popup menu button to be able to re-store contents
	NSString		*firstTitle = [NSString stringWithString:[outputDevicePopUpButton itemTitleAtIndex:0]];
	
	// Remove all but...
	[outputDevicePopUpButton removeAllItems];
	// ... re-store first item
	[outputDevicePopUpButton addItemWithTitle:firstTitle];


	// clear out any current entries in device array
	[deviceArray removeAllObjects];
	
	// fetch a pointer to the list of available devices
	if (GetAudioDevices((Ptr*)&devices, &devicesAvailable) != noErr) {
		return;
	}
	
	// iterate over each device gathering information
	for (loopCount = 0; loopCount < devicesAvailable; loopCount++) {
		UInt16					deviceID = devices[loopCount];
		
		// get number of output channels
		outSize = 0;
		theNumberOutputChannels = 0;
		// check whether we have any output devices
		err = AudioDeviceGetPropertyInfo(devices[loopCount], 0, 0, kAudioDevicePropertyStreamConfiguration, &outSize, NULL);
		if ((err == noErr) && (outSize != 0)) {
			// we will get "outSize" buffers
			theBufferList = (AudioBufferList*)malloc(outSize);
			if (theBufferList != NULL) {
				// get the stream configuration
				err = AudioDeviceGetProperty(devices[loopCount], 0, 0, kAudioDevicePropertyStreamConfiguration, &outSize, theBufferList);
				if (err == noErr) {
					// count the total number of output channels in the stream
					for (theIndex = 0; theIndex < theBufferList->mNumberBuffers; ++theIndex) {
						theNumberOutputChannels += theBufferList->mBuffers[theIndex].mNumberChannels;
					}
				}
				free(theBufferList);
				if (theNumberOutputChannels > 0) {
					// create a Dictionary for the entries
					NSMutableDictionary		*theDict = [NSMutableDictionary dictionaryWithCapacity:3];
					
					// save number of output channels
					[theDict setObject:[NSNumber numberWithLong:theNumberOutputChannels] forKey:@"och"];

					// save device id
					[theDict setObject:[NSNumber numberWithLong:deviceID] forKey:@"id"];

					// get device name
					char	theDeviceName[256];
					outSize = sizeof(theDeviceName);
                    

#ifdef OLDSYNTAX

					err = AudioDeviceGetProperty(devices[loopCount], 0, 0, kAudioDevicePropertyDeviceName, &outSize, theDeviceName);
#else
                    AudioObjectPropertyAddress theAddress = {
                        kAudioDevicePropertyDeviceName,
                        kAudioObjectPropertyScopeGlobal,
                        kAudioObjectPropertyElementMaster
                    };
                    
                    __Verify_noErr(
                                   AudioObjectGetPropertyData(
                                                              kAudioObjectSystemObject,
                                                              &theAddress,
                                                              0,
                                                              NULL,
                                                              &outSize,
                                                              theDeviceName
                                                              )
                                   );


#endif
                    [theDict setObject:[NSString stringWithCString:theDeviceName encoding:NSUTF8StringEncoding] forKey:@"name"];
					[deviceArray addObject:theDict];

					[outputDevicePopUpButton addItemWithTitle:(NSString *)[theDict objectForKey:@"name"]];
				}
			}
		}
	}
	
	// this is the device that we want to get either a real device or kAudioDeviceUnknown
	AudioDeviceID currentDevice = [oscillator getWantedDeviceID];

	// search the last wanted device in the list to reselect to proper item
	unsigned i;
	for (i = 0; i < [deviceArray count]; i++) {
		// search the deviceArray index by index
		NSDictionary	*audioDict = [deviceArray objectAtIndex:i];
		if (currentDevice == [[audioDict objectForKey:@"id"] intValue]) {
			// we found the deviceID in the list
			if (0 <= [outputDevicePopUpButton indexOfItemWithTitle:(NSString *)[audioDict objectForKey:@"name"]]) {
				// it also exists in the popup menu item list
				[outputDevicePopUpButton selectItemWithTitle:(NSString *)[audioDict objectForKey:@"name"]];
			} else {
				// strange should not be the case
				[outputDevicePopUpButton selectItemAtIndex:0];
			}
			break;
		}
	}
	// re-select the proper device
	[self setOutputDevice:outputDevicePopUpButton];
}



- (IBAction)startStop:(id)sender {
    if ([sender intValue]) {
		[self run:sender];
	} else {
		[self stop:sender];
	}
}


- (IBAction)run:(id)sender {
	// needed for the menu
	[oscillator startAudio];
	[startStopButton setIntValue:1];
}


- (IBAction)stop:(id)sender {
	// needed for the menu
	[oscillator stopAudio];
	[startStopButton setIntValue:0];
}

- (IBAction)record:(id)sender {
    NSLog(@"Write to file");
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    for (int i = 0; i < [dirPaths count]; i++) NSLog(@"%@", [dirPaths objectAtIndex:i]);
    NSLog(@"%@", [dirPaths objectAtIndex:0]);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"test777.csv"]];
    
    NSMutableData *a = nil;
    a = [NSMutableData dataWithBytes:"Dies ist ein Text" length:18];
    [a writeToFile:databasePath atomically:YES];
}




// delegate methods
- (void)windowDidBecomeKey:(NSNotification *)notification {
	[showController setState:NSOnState];
}

- (void)windowWillClose:(NSNotification *)notification {
	[showController setState:NSOffState];
	
}


- (void) dealloc {
	[halftoneToHzTransformer release];
	[super dealloc];
}

@end
