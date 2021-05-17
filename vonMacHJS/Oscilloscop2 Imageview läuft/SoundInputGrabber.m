/* 

Copyright (C) 2003 Yves Schmid (www.garagecube.com)

Author(s): Yves Schmid

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the     GNU General Public License for more details.

You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/

#import "SoundInputGrabber.h"
#import <CoreAudio/CoreAudio.h>
#import <objc/objc-runtime.h>


@interface SoundInputGrabber (Private)

- (BOOL)setUpAudioDevice;

static OSStatus ioProc(AudioDeviceID inDevice, const AudioTimeStamp* inNow, const AudioBufferList* inInputData, const AudioTimeStamp* inInputTime, AudioBufferList* outOutputData, const AudioTimeStamp* inOutputTime, void* inClientData);

@end


@implementation SoundInputGrabber

- (id)initWithDelegate:(id)aDelegate callbackSelector:(SEL)aSel;
{
    if (!(self = [super init]))
        return nil;

    nonretainedDelegate = aDelegate;
    delegateCallbackSelector = aSel;

    if (!nonretainedDelegate || !delegateCallbackSelector || ![nonretainedDelegate respondsToSelector:delegateCallbackSelector]) {
        [self release];
        return nil;
   }

    isRunning = NO;

    if (![self setUpAudioDevice]) {
        [self release];
        return nil;
    }

    return self;
}

- (void)dealloc
{
    AudioDeviceRemoveIOProc(deviceID, ioProc);

    [super dealloc];
}

- (BOOL)start;
{
    OSStatus err;

    if (isRunning) {
        NSLog(@"can't start because we're already running");
        return NO;
    }

    if ((err = AudioDeviceStart(deviceID, ioProc))) 
    {
        NSLog(@"AudioDeviceStart returned error: %lu", err);
        return NO;
    } 
    else 
    {
        isRunning = YES;

        return YES;
    }
}

- (void)stop
{
    OSStatus err;

    if (!isRunning) {
        NSLog(@"can't stop because we're not running");
        return;
    }

    isRunning = NO;

    if ((err = AudioDeviceStop(deviceID, ioProc))) {
        NSLog(@"AudioDeviceStop returned error %lu", err);
    }
}

- (BOOL)isRunning
{
    return isRunning;
}

- (AudioStreamBasicDescription)audioStreamDescription;
{    
    UInt32 size;
    AudioStreamBasicDescription description;
    OSStatus err;

    size = sizeof(description);
    err = AudioDeviceGetProperty(deviceID, 0 /* channel 0 means "first stream" */, true /* is input */, kAudioDevicePropertyStreamFormat, &size, &description);
    if (err) {
        NSLog(@"error %lu from AudioDeviceGetProperty(kAudioDevicePropertyStreamFormat)", err);

        bzero(&description, sizeof(description));
    }

    return description;
}

@end

@implementation SoundInputGrabber (Private)

- (BOOL)setUpAudioDevice;
{
    OSStatus err;
    UInt32 size;

    // get the default input device
    size = sizeof(AudioDeviceID);
    err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultInputDevice, &size, &deviceID);
    if (err) {
        NSLog(@"AudioHardwareGetProperty(kAudioHardwarePropertyDefaultInputDevice) returned error %ld", err);
       return NO;
    }

    // set up our ioproc
    err = AudioDeviceAddIOProc(deviceID, ioProc, self);
    if (err) {
        NSLog(@"AudioDeviceAddIOProc returned error %ld", err);
        return NO;
    }
    
    return YES;
}


OSStatus ioProc(AudioDeviceID inDevice, const AudioTimeStamp* inNow, const AudioBufferList* inInputData, const AudioTimeStamp* inInputTime, AudioBufferList* outOutputData, const AudioTimeStamp* inOutputTime, void* inClientData)
{
    if (inInputTime->mSampleTime != 0) {
        SoundInputGrabber *self = (SoundInputGrabber *)inClientData;

        if (self->isRunning)
            objc_msgSend(self->nonretainedDelegate, self->delegateCallbackSelector, &inInputData->mBuffers[0]);
    }
    
    return noErr;    
}

@end