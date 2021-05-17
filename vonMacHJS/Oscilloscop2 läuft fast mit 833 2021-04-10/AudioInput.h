////  AudioInput.h//  Oscilloscop2////  Created by Heinz-J�rg on 20.04.05.//  Copyright 2005 __MyCompanyName__. All rights reserved.//#import		<Cocoa/Cocoa.h>#include	<CoreAudio/AudioHardware.h>@interface AudioInput : NSObject{	float							*leftBuffer;	float							*rightBuffer;	unsigned						inIndex;	unsigned						bufferLength;		Boolean							initialized;								// successful init?	Boolean							soundRecording;								// recording now?	AudioDeviceID					device;										// the default audio output device	UInt32							deviceBufferSize;							// bufferSize returned by kAudioDevicePropertyBufferSize	AudioStreamBasicDescription		deviceFormat;								// info about the default device}- (void)		setupAudioLeft:(float *)leftChannel Right:(float *)rightChannel Size:(int)length;- (BOOL)		start;- (BOOL)		stop;- (BOOL)		isRunning;- (unsigned)	inIndex;@end