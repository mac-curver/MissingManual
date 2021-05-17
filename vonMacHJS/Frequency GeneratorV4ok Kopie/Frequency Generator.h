//
//

#import <Cocoa/Cocoa.h>

#define								SIZE	64

enum {
	noneType = 0,
	sineType, 
	rectType,
	triangleType,
	risingSawtoothType,
	fallingSawtoothType,
	sineSweepType,
	oneSevenPatternType
};

typedef	struct {
	int								index;								// bit index for 1:7 modulation
	int								returnValue;						// last value of encoder

	float							array[SIZE];						// last 24 left channel analog samples
	float							firFilter[SIZE];					// 24 coefficients for FIR filter
	int								arrayIndex;							// index into left analog samples
	float							amplitudeValue;						// 16 bit amplitude values
	double							frequency;							// frequency in Hz
	double							frequencyValue;						// frequency over sampling rate
	double							dutyCycleValue;						// controls for right
	double							Ts;									// oscillator left sampling in radians
	long							oscType;							// sine, rect .... left channel
	unsigned short					mySourceBits;						// input word pattern
	unsigned long					myChannelBits;						// output pattern
}	OneSevenSample;	



@interface FrequencyGenerator : NSObject {	
	OneSevenSample					left;								// bit index for 1:7 modulation
	OneSevenSample					right;								// bit index for 1:7 modulation
        
	double							mixer;								// controls for mixer
	Boolean							initialized;						// successful init?
	AudioDeviceIOProc				soundPlayingFctn;					// playing now through which function
	AudioDeviceID					device;								// the selected audio output device
	AudioDeviceID					wantedDevice;						// teh demanded audio output device
	UInt32							safetyOffset;						// what is this?
	UInt32							deviceBufferSize;					// bufferSize returned by kAudioDevicePropertyBufferSize
	AudioStreamBasicDescription		deviceFormat;						// info about the default device
}

- (float)				nextOneSeven:(OneSevenSample*) samplePtr;
- (void)				setupAudio;
- (void)				setOutputDeviceID:(AudioDeviceID)outPutDeviceID;
- (AudioDeviceID)		getOutputDeviceID;
- (AudioDeviceID)		getWantedDeviceID;
- (BOOL)				startAudio;
- (BOOL)				stopAudio;

/*
- (UInt32)              audioInput
UInt32 audioInputIsAvailable;
UInt32 propertySize = sizeof (audioInputIsAvailable);

AudioSessionGetProperty (
                         kAudioSessionProperty_AudioInputAvailable,
                         &propertySize,
                         &audioInputIsAvailable // A nonzero value on output means that
// audio input is available
);
 */


- (void)setAmpLeftVal:(float)val;
- (void)setFreqLeftVal:(double)val;
- (void)setDutyCycleLeftVal:(double)val;
- (void)setOscillatorTypeLeftVal:(long)val;
- (void)setAmpRightVal:(float)val;
- (void)setFreqRightVal:(double)val;
- (void)setDutyCycleRightVal:(double)val;
- (void)setOscillatorTypeRightVal:(long)val;
- (void)setMixerVal:(double)val;
- (void)setPhaseVal:(double)val;


@end
