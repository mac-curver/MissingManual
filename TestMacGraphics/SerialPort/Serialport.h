//
//  Serialport.h
//  TestMacGraphics
//
//  Created by Heinz-Jörg on 29.03.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//
#pragma once

#import <Cocoa/Cocoa.h>

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <paths.h>
#include <termios.h>
#include <sysexits.h>
#include <sys/param.h>
#include <sys/select.h>
#include <sys/time.h>
#include <time.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/serial/ioss.h>
#include <IOKit/IOBSD.h>



NS_ASSUME_NONNULL_BEGIN


@protocol SerialDelegate <NSObject>                                             // define delegate protocol

- (void) readText:(NSString *)availableText;                                    // define delegate method to be implemented within another class

@end //end protocol



// Hold the original termios attributes so we can reset them
static struct termios gOriginalTTYAttrs;

// Function prototypes
kern_return_t findModems(io_iterator_t *matchingServices);
kern_return_t getModemPath(io_iterator_t serialPortIterator,
                           char *bsdPath, CFIndex maxPathSize
             );
int openSerialPort(const char *bsdPath, speed_t baudrate);
void closeSerialPort(int fileDescriptor);



static const int BufferSize     =   40;
static const int MaxLineLength  = 4096;




@interface SerialportInterface: NSObject {
    int                 serialPortFileDescriptor;
    NSTimer            *readTimer;
}

- (NSControlStateValue) connect:(NSString *)portName with:(unsigned long)baudRate;


- (void) open:(NSString *)portName with:(unsigned long)baudRate;
- (void) close;
- (BOOL) isOpen;
- (void) passTextToMainThread:(NSString *)text;
- (void) intervalReading;
- (void) stopReading;



/// 
/// @param timer Timer for the timer event
- (void) readLinePrivate:(NSTimer *)timer;

@property(assign) BOOL run;
@property(class, readonly, weak, nonatomic) NSArray *allSerialPorts;
@property(class, readonly, strong) NSString *defaultSerialPort;

@property(class, readonly, strong) NSString *defaultBaudrate;
@property(class, readonly, strong) NSArray *standardBaudrates;

@property(readonly, getter=isOpen) BOOL isOpen;

@property (nonatomic, weak) id <SerialDelegate> delegate;                       //define SerialDelegate as delegate

@end



NS_ASSUME_NONNULL_END
