//
// a very simple Cocoa CoreAudio app
// original by James McCartney  james@audiosynth.com  www.audiosynth.com
// changed a lot by HJS for other waveforms
//
// Frequency Generator - this class implements a function generator for several waveforms
//
//	History
//	=======
//    07.09.2020    HJS:    Corrected:   verify_noerr replaced by __Verify_noErr
//  24.07.2005  HJS:    Corrected:    1:7 modulation
//	17.07.2005	HJS:	Corrected:	Phase input
//	04.05.2005	HJS:	Added:		1:7 modulation support
//	04.03.2005	HJS:	Changed:	smooth parameter changes removed to allow stable phase between left and right
//	09.11.2006	HJS:	Changed:	Distortion could be controlled by pre-processor statement


#import <CoreAudio/CoreAudio.h>
#include <AudioUnit/AudioUnit.h>


#import "Frequency Generator.h"



const	double	TwoPi	= 2.*3.14159265359;
const	double	MaxDomain = 60.0;



//const	unsigned short oneSevenTable[] = {1,1,0,0,1,1,0,0,5,5,2,2,2,4,4,4,1,1,2,2,2,0,0,0,5,5,2,2,2,4,4,4};

// now sequence as: prev channel bit = 0, prev channel bit = 1, .... alternate for the complete table

const	unsigned short oneSevenTable[]
        = {1,1,1,1,0,2,0,2,1,2,1,0,0,0,0,0,5,5,5,5,2,2,2,2,2,2,4,4,4,4,4,4};
//		   0                   1                   2                   3
//		   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
//										


@implementation FrequencyGenerator (Private)

// this is the audio processing callback.
OSStatus appIOProcMulti(  AudioDeviceID          inDevice
                        , const AudioTimeStamp*  inNow
                        , const AudioBufferList* inInputData
                        , const AudioTimeStamp*  inInputTime
                        , AudioBufferList*       outOutputData
                        , const AudioTimeStamp*  inOutputTime
                        , void* dataPtr
) {
	FrequencyGenerator		*self = (FrequencyGenerator *)dataPtr;
    int						i;
    
    // load instance vars into registers
	double	TsL = self->left.Ts;
	double	TsR = self->right.Ts;

    float	ampL = self->left.amplitudeValue;
    float	ampR = self->right.amplitudeValue;  
	
	UInt32	numBuffers = outOutputData->mNumberBuffers;
	UInt32	mNumberChannels;
	UInt32	mDataByteSize;
	UInt32	channel;
	UInt32	buffer;
    UInt32	numSamples;
	
	for (buffer = 0; buffer < numBuffers; buffer++) {							// normally only 1 buffer, but who knows
		mNumberChannels = outOutputData->mBuffers[buffer].mNumberChannels;
		mDataByteSize = outOutputData->mBuffers[buffer].mDataByteSize;
	
		// assume floats for now....
		float	*out = outOutputData->mBuffers[buffer].mData;
		numSamples = mDataByteSize/(mNumberChannels*sizeof(float));
			
		for (i = 0; i < numSamples; ++i) {
			float waveLeft;														// amplitude value for left channel  
			float waveRight;													// amplitude value for right channel 
			switch (self->left.oscType) {										// generate left wave
				case sineType:
					waveLeft = sin(TsL * TwoPi) * ampL;							// generate sine wave
					break;
				case rectType:
					if (TsL-floor(TsL) > self->left.dutyCycleValue) {
						waveLeft = ampL;										// generate rect wave
					} else {
						waveLeft = -ampL;
					}
					break;
				case triangleType:
					waveLeft = (4.0*fabs(floor(TsL)-TsL+0.5)-1.0)*ampL;			// generate triangle wave
					break;			
				case risingSawtoothType:
					waveLeft = 2.0*(TsL-floor(TsL)-0.5) * ampL;					// generate rising sawtooth wave
					break;
				case fallingSawtoothType:
					waveLeft = 2.0*(floor(TsL)-TsL+0.5) * ampL;					// generate falling sawtooth wave
					break;
				case sineSweepType:
					waveLeft = sin(TsL * TwoPi * ampL *
                               (1+10*self->left.dutyCycleValue*TsL/MaxDomain));	// generate sine sweep wave
					break;
				case oneSevenPatternType:
					waveLeft = [self nextOneSeven:&(self->left)]* ampL;			// generate 1:7 pattern
					break;
				default:														// case 0: first index
					waveLeft = 0;
					break;
			}
			switch (self->right.oscType) {										// generate right wave
				case sineType:
					waveRight = sin(TsR * TwoPi) * ampR;						// generate sine wave
					break;
				case rectType:
					if (TsR-floor(TsR) > self->right.dutyCycleValue) {
						waveRight = ampR;										// generate rect wave
					} else {
						waveRight = -ampR;
					}
					break;
				case triangleType:
					waveRight = (4.0*fabs(floor(TsR)-TsR+0.5)-1.0)*ampR;		// generate triangle wave
					break;			
				case risingSawtoothType:
					waveRight = 2.0*(TsR-floor(TsR)-0.5) * ampR;				// generate rising sawtooth wave
					break;
				case fallingSawtoothType:
					waveRight = 2.0*(floor(TsR)-TsR+0.5) * ampR;				// generate falling sawtooth wave
					break;
				case sineSweepType:
					waveRight = sin(TsR * TwoPi * ampR *
                               (1+10*self->right.dutyCycleValue*TsR/MaxDomain));// generate sine sweep wave
					break;
				case oneSevenPatternType:
					waveRight = [self nextOneSeven:&(self->right)]* ampR;		// generate 1:7 pattern
					break;
				default:														// case 0: first index
					waveRight = 0;				
					break;
			}
			
			TsL += self->left.frequencyValue;									// increment Ts
			TsR += self->right.frequencyValue;									// increment Ts
			
			// write output
			*out++ = waveLeft  + self->mixer * waveRight;						// left channel
			for (channel = 1; channel < mNumberChannels; channel++) {
				*out++ = waveRight + self->mixer * waveLeft;					// right channel
			}
		}
	}
	if (MaxDomain <= TsL) {
		TsL -= MaxDomain;														// avoid running out of domain
	}
	if (MaxDomain <= TsR) {
		TsR -= MaxDomain;														// avoid running out of domain
	}
    
    // save registers back to object 
	self->left.Ts = TsL;
    self->right.Ts = TsR;
    
    return kAudioHardwareNoError;     
}

@end

@implementation FrequencyGenerator

double gcd(double p, double q);
double gcd(double p, double q) {
	// determines the greates common divisor:
    // gcd(x, y) scm(x, y) = |x y| (scm=smallest common multiple)
	// bestimmt den gršssten gemeinsamen Teiler:
    // ggT(x, y) kgV(x, y) = |x y| (kgV=kleinstes gemeinsames Vielfaches)
	double		m = p;
	double		n = q;
	double		k;
	
	while (1 < m) {
		k = n;
		n = m;
		m = fmod(k, m);
	}
	return n;
}

- (float)				nextOneSeven:(OneSevenSample*) samplePtr {
	float				averageValue = 0;
	int					numSamples  = 1.0/samplePtr->frequencyValue;
	unsigned long		sourceBits;												// 32 bit assembly of current word and next word
	int					i;
	unsigned short		index;
	
	if (samplePtr->index > 24*numSamples-1) {									// 24 channel bits for 16 source bits
		samplePtr->index = 0;	
		sourceBits = samplePtr->mySourceBits;									// current word
		samplePtr->mySourceBits++;												// next source word
		sourceBits <<= 4;														// current word *16
		sourceBits |= samplePtr->mySourceBits>>12;								// current word *16 + 4 topmost bits of next word
				
		// sourcebits assembly
		//              current bits
		//									next bits
		// 00000000 0000cccc   cccccccc ccccnnnn
		//           (p)ssnn	2*4 bit index (16 values)
		//             \   /
		//              \ /
		//               V
		//				3 channel bits
		
		
		// 194C.   1 ->  6FFEC00
		// 00 01   10 01   01 00   11 00.00 01
		// 001 010 101 010 001 001 010 001
		// 0010 1010 1010 0010 0101 0001
		// 2 A A 2 3 1
		
		samplePtr->myChannelBits &= 0x01;										// reset channel bits preserve last channel bit
		for (i = 0; i < 16; i +=2) {											// 8 conversions
			// array[ 0..31] contains channel bits for previous channel
            // bit == 0 alternated with previous channel bit == 1
			index = (0x1E & sourceBits>>17)+(samplePtr->myChannelBits & 0x01);	// four bits from source + odd/even from prev channel
			samplePtr->myChannelBits <<= 3;										// advance channel bits
			samplePtr->myChannelBits |= oneSevenTable[index];					// get converted value from table
			sourceBits <<= 2;													// advance source bits
		}
	}
	
	// bit for bit convert to nrzi (toggle)
	if (0 == samplePtr->index % numSamples) {									// output oversampling*times the same value 
		if (samplePtr->myChannelBits & 0x00800000L) {							// detect bit
			samplePtr->returnValue = -samplePtr->returnValue;					// toggle if bit is set
		}
		samplePtr->myChannelBits <<= 1;											// next channel bit
	}
	
	samplePtr->array[samplePtr->arrayIndex++] = samplePtr->returnValue;			// digital output value
	if (samplePtr->arrayIndex >= SIZE) {
		samplePtr->arrayIndex = 0;												// reset index to re-use array
	}
	averageValue = 0;
	for (i = 0; i < SIZE; i ++) {												// FIR filter
		averageValue += samplePtr->array[(samplePtr->arrayIndex+i)%SIZE] *
                              samplePtr->firFilter[i];
	}
	
	samplePtr->index ++;
	return averageValue;
}


- (id) init {
    if ((self = [super init])) {
		wantedDevice = kAudioDeviceUnknown;
		[self setupAudio];
    }
	
	return self;
}


- (void) setupAudio {
    UInt32				count;
	   
	device			= wantedDevice;
	 
    initialized = NO;
	
	// initialize Ts 
	left.Ts = 0.0;
    right.Ts = 0.0;
	
	left.arrayIndex = 0;
	right.arrayIndex = 0;
	
	left.returnValue = -1;
	right.returnValue = -1;
	
	left.index = 9999;															// force 1/7 encoding
	left.mySourceBits = 0x194C;
	left.myChannelBits = 0L;
	
	right.index = 9999;															// force 1/7 encoding
	right.mySourceBits = 0x194C;
	right.myChannelBits = 0L;
	
	soundPlayingFctn = nil;														// set the playing status global to nil


	count = sizeof(device);
    


    AudioObjectPropertyAddress theAddress = {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyScopeOutput//kAudioObjectPropertyElementMaster
    };


	if (device == kAudioDeviceUnknown) {										// Retrieve the default output device
        // see https://developer.apple.com/library/content/technotes/tn2223/_index.html
#ifdef OLDSYNTAX1
        __Verify_noErr(
                    AudioHardwareGetProperty(
                                        kAudioHardwarePropertyDefaultOutputDevice,
                                        &count,
                                        &device
                    )
        );
#else

       __Verify_noErr(
                    AudioObjectGetPropertyData(
                                        kAudioObjectSystemObject,
                                        &theAddress,
                                        0,
                                        NULL,
                                        &count,
                                        &device
                    )
        );
        
#endif
        
	}
	if (device == kAudioDeviceUnknown) {
		return;																	// device not found
	}

	count = sizeof(device);
#ifdef OLDSYNTAX1
	__Verify_noErr(AudioDeviceSetProperty(device, NULL, 0, false, kAudioHardwarePropertyDeviceForUID, count, &device));
#else
    theAddress.mSelector = kAudioHardwarePropertyDeviceForUID;

    //verify_noerr(
                AudioObjectSetPropertyData(
                                    device,
                                    &theAddress,
                                    0,
                                    NULL,
                                    count,
                                    &device
                )
    //)
    ;

#endif
    
#define OLDSYNTAX

	
	count = sizeof(safetyOffset);
#ifdef OLDSYNTAX1
    __Verify_noErr(AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertySafetyOffset, &count, &safetyOffset));
#else
    theAddress.mSelector = kAudioDevicePropertySafetyOffset;

    __Verify_noErr(
                AudioObjectGetPropertyData(
                                    kAudioObjectSystemObject,
                                    &theAddress,
                                    0,
                                    NULL,
                                    &count,
                                    &safetyOffset
                )
    )
    ;
#endif
	
	count = sizeof(deviceBufferSize);
#ifdef OLDSYNTAX1
	__Verify_noErr(AudioDeviceGetProperty(
                        device,
                        0, false,
                        kAudioDevicePropertyBufferSize,
                        &count, &deviceBufferSize
                   )
    );
#else
    theAddress.mSelector = kAudioDevicePropertyBufferSize;
    
    __Verify_noErr(
                 AudioObjectGetPropertyData(
                     kAudioObjectSystemObject,
                     &theAddress,
                     0,
                     NULL,
                     &count,
                     &deviceBufferSize
                 )
    )
    ;
    
#endif
	count = sizeof(deviceFormat);
    
#ifdef OLDSYNTAX
	__Verify_noErr(
        AudioDeviceGetProperty(
            device, 0, false,
            kAudioDevicePropertyStreamFormat,
            &count,
            &deviceFormat
        )
    );
#else
    /*
     The AudioObjectPropertyAddress structure is used with the new APIs to
     encapsulate the distinguishing information for a specific property;
     the selector ID (mSelector), the scope (mScope) and the element (mElement).
     The HAL uses the terms scope and element in the same way that the
     AudioUnit API does.
     
     Most objects have only one scope and one element, for example the
     System Object, Stream Object and Control Object have only one scope,
     kAudioObjectPropertyScopeGlobal and one element,
     kAudioObjectPropertyElementMaster.
     
     Device Objects are different and may have three other scopes beside
     kAudioObjectPropertyScopeGlobal. These are kAudioDevicePropertyScopeInput,
     kAudioDevicePropertyScopeOutput, and kAudioDevicePropertyScopePlayThrough.
     
     For a Device Object, the element (mElement) of the
     AudioObjectPropertyAddress structure refers to the channel number on
     the device.
     
     AudioObjectPropertySelector mSelector;
     AudioObjectPropertyScope    mScope;
     AudioObjectPropertyElement  mElement;


     */

    theAddress.mSelector = kAudioDevicePropertyStreamFormat;
    theAddress.mScope = kAudioObjectPropertyScopeGlobal;
    theAddress.mSelector = kAudioObjectPropertyElementMaster;
    
    __Verify_noErr(
                 AudioObjectGetPropertyData(
                               kAudioObjectSystemObject,
                               &theAddress,
                               0,
                               NULL,
                               &count,
                               &deviceFormat
                 )
    );
#endif
    
 	[self setFreqLeftVal:left.frequency];										// reset frequency as side effect depends on sampling rate
	[self setFreqRightVal:right.frequency];
   
    initialized = YES;
}


- (void) setOutputDeviceID:(AudioDeviceID)outPutDeviceID {
	BOOL			isPlaying	= (soundPlayingFctn != nil);					// remember whether we are playing
	
	wantedDevice = outPutDeviceID;
	
	if (isPlaying) {
		[self stopAudio];														// stop if it was playing
	}

	[self setupAudio];															// this will initialize our CoreAudio data
	
	if (isPlaying) {
		[self startAudio];
	}
}



- (AudioDeviceID)		getOutputDeviceID {
	return	device;
}

- (AudioDeviceID)		getWantedDeviceID {
	return	wantedDevice;
}



- (void)setAmpLeftVal:(float)val {
    if (val > 0) {
        left.amplitudeValue = expf(3.0f*logf(val));
    } else {
        left.amplitudeValue = 0;
    }
}

- (void)setFreqLeftVal:(double)val {
	left.frequency = val;														// frequency in Hz
	left.frequencyValue = left.frequency / deviceFormat.mSampleRate;
}

- (void)setDutyCycleLeftVal:(double)val
{
	float		sum = 0;
	double		x;
	int			index;
	
	left.dutyCycleValue = val;
	for (index = 0; index < SIZE; index++) {
		left.array[index] = 0.0;												// reset
		x = index-SIZE/2.0;
		left.firFilter[index] = exp(-x*x/(100*val+1));
		sum += left.firFilter[index];
	}
	// normalize filter
	for (index = 0; index < SIZE; index++) {
		left.firFilter[index] /= sum;
	}
	left.arrayIndex = 0;
}

- (void)setOscillatorTypeLeftVal:(long)val {
	left.oscType = val;
}

- (void)setAmpRightVal:(float)val {
    if (val > 0) {
        right.amplitudeValue = expf(3.0f*logf(val));
    } else {
        right.amplitudeValue = 0;
    }
}

- (void)setFreqRightVal:(double)val
{
	right.frequency = val;														// frequency in Hz
	right.frequencyValue = right.frequency / deviceFormat.mSampleRate;
}

- (void)setDutyCycleRightVal:(double)val
{
	float		sum = 0;
	double		x;
	int			index;
	
	right.dutyCycleValue = val;
	for (index = 0; index < SIZE; index++) {
		right.array[index] = 0.0;												// reset
		x = index-SIZE/2.0;
		right.firFilter[index] = exp(-x*x/(100*val+1));
		sum += right.firFilter[index];
	}
	// normalize filter
	for (index = 0; index < SIZE; index++) {
		right.firFilter[index] /= sum;
	}
	right.arrayIndex = 0;
}

- (void)setOscillatorTypeRightVal:(long)val {
	right.oscType = val;
}

- (void)setMixerVal:(double)val {
	mixer = val;
}

- (void)setPhaseVal:(double)val {
	right.Ts = left.Ts + val;
}

OSStatus ioProc(
                AudioObjectID deviceID,
                const AudioTimeStamp *inTs,
                const AudioBufferList *bl,
                const AudioTimeStamp *outTs,
                AudioBufferList* outputData,
                const AudioTimeStamp *otherTs,
                void *unused
) {
    /*
    if (outputData != NULL) {
        
        const size_t numBuffers = outputData->mNumberBuffers;
        for (size_t iBuffer = 0; iBuffer < numBuffers; ++iBuffer) { const AudioBuffer& buffer = outputData->mBuffers[iBuffer]; const size_t numSamples = buffer.mDataByteSize /
            sizeof(float);
            float* pDataFloat = static_cast<float*>(buffer.mData); for (size_t i = 0; i < buffer.mDataByteSize; ++i) {
                pDataFloat[i] = get_random_sample_value(); }
        }
    }
    */
    return noErr;
}

- (BOOL)startAudio {
    OSStatus					err = kAudioHardwareNoError;

    if (!initialized) return false;
    if (soundPlayingFctn) return false;
	
	soundPlayingFctn = appIOProcMulti;											// set the playing to multi-channel
//#define WORKS
#ifdef WORKS
    err = AudioDeviceAddIOProc(device, soundPlayingFctn, (void *) self);		// setup our device with an IO proc
#else
    AudioDeviceIOProcID outIOProcID;                                            // No idea whats the purpose of this
    err = AudioDeviceCreateIOProcID(                                            // Apple documentation sucks
                device,
                appIOProcMulti,
                (__bridge void *)self,
                &outIOProcID
     );

#endif
    if (err != kAudioHardwareNoError && 0 != outIOProcID) return false;
    
    err = AudioDeviceStart(device, soundPlayingFctn);							// start playing sound through the device
    if (err != kAudioHardwareNoError) return false;

    return true;
}

- (BOOL)stopAudio {
    OSStatus 	err = kAudioHardwareNoError;
    
    if (!initialized) return false;
    if (!soundPlayingFctn) return false;
    
    err = AudioDeviceStop(device, soundPlayingFctn);							// stop playing sound through the device
    if (err != kAudioHardwareNoError) return false;

    err = AudioDeviceDestroyIOProcID(device, soundPlayingFctn);					// remove the IO proc from the device
    if (err != kAudioHardwareNoError) return false;
    
    soundPlayingFctn = nil;														// set the playing status global to false
    return true;
}



@end
