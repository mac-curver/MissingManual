/* 

Copyright (C) 2003 Yves Schmid (www.garagecube.com)

Author(s): Yves Schmid

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the     GNU General Public License for more details.

You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/


#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>

@interface SoundInputGrabber : NSObject
{
    id nonretainedDelegate;
    SEL delegateCallbackSelector;

    BOOL isRunning;
    AudioDeviceID deviceID; 
}

- (id)initWithDelegate:(id)aDelegate callbackSelector:(SEL)aSel;
    // This class will send a message to the delegate when each buffer of audio data arrives.
    // (That message will be sent in the CoreAudio I/O thread.)
    // The delegate's callback should be something like this:
    // - (void)takeDataFromAudioInput:(AudioBuffer *)buffer;

- (BOOL)start;
- (void)stop;
- (BOOL)isRunning;

- (AudioStreamBasicDescription)audioStreamDescription;

@end