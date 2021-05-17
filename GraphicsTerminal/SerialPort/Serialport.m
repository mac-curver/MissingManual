//
//  Serialport.m
//  TestMacGraphics
//
//  Created by Heinz-Jörg on 29.03.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//


#import "../GraphicsTerminal/AppDelegate.h"
#import "Serialport.h"

#include "MyLog.h"



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
//#include <IOKit/IOBSD.h>



/// Replace non-printable characters in str with '\'-escaped equivalents.
/// This function is used for convenient logging of data traffic.
/// \ATTENTION Not thread save
static char *logString(char *str) {
    static char     buf[MaxLineLength+1];
    char            *ptr = buf;
    int             i;
    
    buf[MaxLineLength] = '\0';
    *ptr = '\0';
    
    while (*str) {
        if (isprint(*str)) {
            *ptr++ = *str++;
        }
        else {
            switch(*str) {
                case ' ':
                    *ptr++ = *str;
                    break;
                    
                case 27:
                    *ptr++ = '\\';
                    *ptr++ = '^';
                    break;
                    
                case '\t':
                    *ptr++ = '\\';
                    *ptr++ = 't';
                    break;
                    
                case '\n':
                    *ptr++ = '\\';
                    *ptr++ = 'n';
                    break;
                    
                case '\r':
                    *ptr++ = '\\';
                    *ptr++ = 'r';
                    break;
                    
                default:
                    i = *str;
                    (void)sprintf(ptr, "\\%03o", i);
                    ptr += 4;
                    break;
            }
            
            str++;
        }
        
        *ptr = '\0';
    }
    
    return buf;
}


// Returns an iterator across all known modems. Caller is responsible for
// releasing the iterator when iteration is complete.
kern_return_t findModems(io_iterator_t *matchingServices)
{
    kern_return_t             kernResult;
    CFMutableDictionaryRef    classesToMatch;
    
    // Serial devices are instances of class IOSerialBSDClient.
    // Create a matching dictionary to find those instances.
    classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
    if (classesToMatch == NULL) {
        NSLog(@"IOServiceMatching returned a NULL dictionary.");
    }
    else {
        // Look for devices that claim to be modems.
        CFDictionarySetValue(classesToMatch,
                             CFSTR(kIOSerialBSDTypeKey),
//                             CFSTR(kIOSerialBSDModemType)
                             CFSTR(kIOSerialBSDAllTypes)
//                             CFSTR(kIOSerialBSDRS232Type)
        );
        
        // Each serial device object has a property with key
        // kIOSerialBSDTypeKey and a value that is one of kIOSerialBSDAllTypes,
        // kIOSerialBSDModemType, or kIOSerialBSDRS232Type. You can experiment with the
        // matching by changing the last parameter in the above call to CFDictionarySetValue.
        
        // As shipped, this sample is only interested in modems,
        // so add this property to the CFDictionary we're matching on.
        // This will find devices that advertise themselves as modems,
        // such as built-in and USB modems. However, this match won't find serial modems.
    }
    
    // Get an iterator across all matching devices.
    kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, matchingServices);
    if (KERN_SUCCESS != kernResult) {
        NSLog(@"IOServiceGetMatchingServices returned %d", kernResult);
        goto exit;
    }
    
exit:
    return kernResult;
}

// Given an iterator across a set of modems, return the BSD path to the first one with the callout device
// path matching MATCH_PATH if defined.
// If MATCH_PATH is not defined, return the first device found.
// If no modems are found the path name is set to an empty string.
kern_return_t getModemPath(
                                  io_iterator_t serialPortIterator,
                                  char *bsdPath,
                                  CFIndex maxPathSize
) {
    io_object_t         modemService;
    kern_return_t       kernResult = KERN_FAILURE;
    Boolean             modemFound = false;
    
    // Initialize the returned path
    *bsdPath = '\0';
    
    // Iterate across all modems found. In this example, we bail after finding the first modem.
    
    while ((modemService = IOIteratorNext(serialPortIterator)) && !modemFound) {
        CFTypeRef    bsdPathAsCFString;
        
        // Get the callout device's path (/dev/cu.xxxxx). The callout device should almost always be
        // used: the dialin device (/dev/tty.xxxxx) would be used when monitoring a serial port for
        // incoming calls, e.g. a fax listener.
        
        bsdPathAsCFString = IORegistryEntryCreateCFProperty(
                                modemService,
                                CFSTR(kIOCalloutDeviceKey),
                                kCFAllocatorDefault,
                                0
                            );
        if (bsdPathAsCFString) {
            Boolean result;
            
            // Convert the path from a CFString to a C (NUL-terminated) string for use
            // with the POSIX open() call.
            
            result = CFStringGetCString(
                         bsdPathAsCFString,
                         bsdPath,
                         maxPathSize,
                         kCFStringEncodingUTF8
                     );
            CFRelease(bsdPathAsCFString);
            
#ifdef MATCH_PATH
            if (strncmp(bsdPath, MATCH_PATH, strlen(MATCH_PATH)) != 0) {
                result = false;
            }
#endif


            if (result) {
                char blueToothDevice[] = "/dev/cu.Bluetooth-Incoming-Port";
                if (0 == strncmp(bsdPath, blueToothDevice, strlen(blueToothDevice))) {
                    // skip bluetooth device
                } else {
                    NSLog(@"Modem found with BSD path: %s", bsdPath);
                    modemFound = true;
                    kernResult = KERN_SUCCESS;
                }
            }
        }
        
        // Release the io_service_t now that we are done with it.
        
        (void) IOObjectRelease(modemService);
    }
    
    return kernResult;
}

// Given the path to a serial device, open the device and configure it.
// Return the file descriptor associated with the device.
int openSerialPort(const char *bsdPath, speed_t baudRate) {
    int               fileDescriptor = -1;
    int               handshake;
    struct termios    options;
    
    // Open the serial port read/write, with no controlling terminal, and don't wait for a connection.
    // The O_NONBLOCK flag also causes subsequent I/O on the device to be non-blocking.
    // See open(2) <x-man-page://2/open> for details.
    
    fileDescriptor = open(bsdPath, O_RDWR | O_NOCTTY | O_NONBLOCK);
    if (fileDescriptor == -1) {
        NSLog(@"Error opening serial port %s - %s(%d).",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // Note that open() follows POSIX semantics: multiple open() calls to the same file will succeed
    // unless the TIOCEXCL ioctl is issued. This will prevent additional opens except by root-owned
    // processes.
    // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.
    
    if (ioctl(fileDescriptor, TIOCEXCL) == -1) {
        NSLog(@"Error setting TIOCEXCL on %s - %s(%d).",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // Now that the device is open, clear the O_NONBLOCK flag so subsequent I/O will block.
    // See fcntl(2) <x-man-page//2/fcntl> for details.
    
    if (fcntl(fileDescriptor, F_SETFL, 0) == -1) {
        NSLog(@"Error clearing O_NONBLOCK %s - %s(%d).",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // Get the current options and save them so we can restore the default settings later.
    if (tcgetattr(fileDescriptor, &gOriginalTTYAttrs) == -1) {
        NSLog(@"Error getting tty attributes %s - %s(%d).",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // The serial port attributes such as timeouts and baud rate are set by modifying the termios
    // structure and then calling tcsetattr() to cause the changes to take effect. Note that the
    // changes will not become effective without the tcsetattr() call.
    // See tcsetattr(4) <x-man-page://4/tcsetattr> for details.
    
    options = gOriginalTTYAttrs;
    
    // Print the current input and output baud rates.
    // See tcsetattr(4) <x-man-page://4/tcsetattr> for details.
    
    NSLog(@"Current input baud rate is %d", (int) cfgetispeed(&options));
    NSLog(@"Current output baud rate is %d", (int) cfgetospeed(&options));
    
    // Set raw input (non-canonical) mode, with reads blocking until either a single character
    // has been received or a one second timeout expires.
    // See tcsetattr(4) <x-man-page://4/tcsetattr> and termios(4) <x-man-page://4/termios> for details.
    
    cfmakeraw(&options);
    options.c_cc[VMIN] = 0;
    options.c_cc[VTIME] = 10;
    
    // The baud rate, word length, and handshake options can be set as follows:
    
    cfsetspeed(&options, baudRate);//B115200);        // Set x baud
    options.c_cflag |= (CS8             // Use 8 bit words
//                        | PARENB           // Parity enable (even parity if PARODD not also set)
//                        | CCTS_OFLOW      // CTS flow control of output
//                        | CRTS_IFLOW    // RTS flow control of input
                    );
    
    // The IOSSIOSPEED ioctl can be used to set arbitrary baud rates
    // other than those specified by POSIX. The driver for the underlying serial hardware
    // ultimately determines which baud rates can be used. This ioctl sets both the input
    // and output speed.
    
    speed_t speed = baudRate; // Set 14400 baud as default return value
    if (ioctl(fileDescriptor, IOSSIOSPEED, &speed) == -1) {
        NSLog(@"Error calling ioctl(..., IOSSIOSPEED, ...) %s - %s(%d).",
               bsdPath, strerror(errno), errno);
    }
    
    // Print the new input and output baud rates. Note that the IOSSIOSPEED ioctl interacts with the serial driver
    // directly bypassing the termios struct. This means that the following two calls will not be able to read
    // the current baud rate if the IOSSIOSPEED ioctl was used but will instead return the speed set by the last call
    // to cfsetspeed.
    
    NSLog(@"Input baud rate changed to %d",  (int) cfgetispeed(&options));
    NSLog(@"Output baud rate changed to %d", (int) cfgetospeed(&options));
    
    // Cause the new options to take effect immediately.
    if (tcsetattr(fileDescriptor, TCSANOW, &options) == -1) {
        NSLog(@"Error setting tty attributes %s - %s(%d).",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // To set the modem handshake lines, use the following ioctls.
    // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.
    
    // Assert Data Terminal Ready (DTR)
    if (ioctl(fileDescriptor, TIOCSDTR) == -1) {
        NSLog(@"Error asserting DTR %s - %s(%d).",
               bsdPath, strerror(errno), errno);
    }
    
    // Clear Data Terminal Ready (DTR)
    if (ioctl(fileDescriptor, TIOCCDTR) == -1) {
        NSLog(@"Error clearing DTR %s - %s(%d).",
               bsdPath, strerror(errno), errno);
    }
    
    // Set the modem lines depending on the bits set in handshake
    handshake = TIOCM_DTR | TIOCM_RTS | TIOCM_CTS | TIOCM_DSR;
    if (ioctl(fileDescriptor, TIOCMSET, &handshake) == -1) {
        NSLog(@"Error setting handshake lines %s - %s(%d).",
               bsdPath, strerror(errno), errno);
    }
    
    // To read the state of the modem lines, use the following ioctl.
    // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl>
    // for details.
    
    // Store the state of the modem lines in handshake
    if (ioctl(fileDescriptor, TIOCMGET, &handshake) == -1) {
        NSLog(@"Error getting handshake lines %s - %s(%d).",
               bsdPath, strerror(errno), errno);
    }
    
    NSLog(@"Handshake lines currently set to %d", handshake);
    
    unsigned long mics = 1UL;
    
    // Set the receive latency in microseconds. Serial drivers use this value
    // to determine how often to dequeue characters received by the hardware.
    // Most applications don't need to set this value: if an app reads lines
    // of characters, the app can't do anything until the line termination
    // character has been received anyway. The most common applications
    // which are sensitive to read latency are MIDI and IrDA applications.
    
    if (ioctl(fileDescriptor, IOSSDATALAT, &mics) == -1) {
        // set latency to 1 microsecond
        NSLog(@"Error setting read latency %s - %s(%d).",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // Success
    return fileDescriptor;
    
    // Failure path
error:
    if (fileDescriptor != -1) {
        close(fileDescriptor);
    }
    
    return -1;
}


// Given the file descriptor for a modem device, attempt to initialize the
// modem by sending it a standard AT command and reading the response.
// If successful, the modem's response will be "OK".
// Return true if successful, otherwise false.
Boolean readSerialPort(int fileDescriptor, int numLines) {
    char            buffer[256];        // Input buffer
    char           *bufPtr;             // Current char in buffer
    ssize_t         numBytes;           // Number of bytes read or written
 //   int             tries;              // Number of tries so far
    Boolean         result = false;
    
    for (int line = 0; line < numLines; line ++) {
    //for (tries = 1; tries <= kNumRetries; tries++) {
        
        // Read characters into our buffer until we get a CR or LF
        bufPtr = buffer;
        do {
            numBytes = read(fileDescriptor, bufPtr, &buffer[sizeof(buffer)] - bufPtr - 1);
            
            if (numBytes == -1) {
                NSLog(@"Error reading from modem - %s(%d).", strerror(errno), errno);
            } else if (numBytes > 0) {
                bufPtr += numBytes;
                if (*(bufPtr - 1) == '\n' || *(bufPtr - 1) == '\r') {
                    break;
                }
            } else {
                //NSLog("Nothing read.\n");
            }
        } while (numBytes > 0);
        
        // NUL terminate the string and see if we got an OK response
        *bufPtr = '\0';
        
        //NSLog("%s", buffer);
        
        if (strlen(buffer) != 0) {
            result = true;
        }
    //}
    }
    
    return result;
}

// Given the file descriptor for a modem device, attempt to initialize the
// modem by sending it a standard AT command and reading the response.
// If successful, the modem's response will be "OK".
// Return true if successful, otherwise false.
NSString *readLineFromSerialPort(int fileDescriptor) {
    char            buffer[256];        // Input buffer
    char           *bufPtr;             // Current char in buffer
    ssize_t         numBytes;           // Number of bytes read or written
    NSString       *line = NULL;
    
    // Read characters into our buffer until we get a CR or LF
    bufPtr = buffer;
    do {
        numBytes = read(fileDescriptor, bufPtr, 1);//&buffer[sizeof(buffer)] - bufPtr - 1);
        
        if (numBytes == -1) {
            NSLog(@"Error reading from modem - %s(%d).", strerror(errno), errno);
        } else if (numBytes > 0) {
            bufPtr += numBytes;
            if (*(bufPtr - 1) == '\n' || *(bufPtr - 1) == '\r') {
                break;
            }
        } else {
            //NSLog("Nothing read.\n");
        }
    } while (numBytes > 0);
    
    // NUL terminate the string and see if we got an OK response
    *bufPtr = '\0';
    
    //NSLog("%s", buffer);
    
    if (strlen(buffer) != 0) {
        line = [NSString stringWithCString:buffer encoding:NSISOLatin1StringEncoding];
    }
    
    
    return line;
}


// Given the file descriptor for a serial device, close that device.
void closeSerialPort(int fileDescriptor) {
    // Block until all written output has been sent from the device.
    // Note that this call is simply passed on to the serial device driver.
    // See tcsendbreak(3) <x-man-page://3/tcsendbreak> for details.
    if (tcdrain(fileDescriptor) == -1) {
        NSLog(@"Error waiting for drain - %s(%d).",
               strerror(errno), errno);
    }
    
    // Traditionally it is good practice to reset a serial port back to
    // the state in which you found it. This is why the original termios struct
    // was saved.
    if (tcsetattr(fileDescriptor, TCSANOW, &gOriginalTTYAttrs) == -1) {
        NSLog(@"Error resetting tty attributes - %s(%d).",
               strerror(errno), errno);
    }
    
    close(fileDescriptor);
}


char readFromConsoleToStop() {
    char c = 0;
    read (0, &c, 1);
    return c;
}



int startSerialPort() {
    int                 fileDescriptor;
    kern_return_t       kernResult;
    io_iterator_t       serialPortIterator;
    char                bsdPath[MAXPATHLEN];
    //char            esp32Path[] = "cu.SLAB_USBtoUART";
    
    kernResult = findModems(&serialPortIterator);
    if (KERN_SUCCESS != kernResult) {
        NSLog(@"No modems were found.");
    }
    
    kernResult = getModemPath(serialPortIterator, bsdPath, sizeof(bsdPath));
    if (KERN_SUCCESS != kernResult) {
        NSLog(@"Could not get path for modem.");
    }
    
    IOObjectRelease(serialPortIterator);    // Release the iterator.
    
    // Now open the modem port we found, initialize the modem, then close it
    if (!bsdPath[0]) {
        NSLog(@"No modem port found.");
        return EX_UNAVAILABLE;
    }
    //strcpy(bsdPath, "/dev/cu.usbserial-A50501O4");
    
    fileDescriptor = openSerialPort(bsdPath, 115200UL);
    if (-1 == fileDescriptor) {
        return EX_IOERR;
    }

    struct termios t;
    tcgetattr(0, &t);
    t.c_lflag &= ~ICANON;
    tcsetattr(0, TCSANOW, &t);
    
    fcntl(0, F_SETFL, fcntl(0, F_GETFL) | O_NONBLOCK);
    
    NSLog(@"Starting loop (press q(uit) to stop).");
    
    
    for (char mode = 0; mode != 'q'; mode = readFromConsoleToStop()) {
        if (readSerialPort(fileDescriptor, 1)) {
        }
        else {
            NSLog(@"\nCould not initialize modem.");
        }
    }
    
    
    closeSerialPort(fileDescriptor);
    NSLog(@"Modem port closed.");
    
    return EX_OK;
}

@implementation SerialportInterface

+ (void) initialize {
    [super initialize];
}

+ (NSString *) defaultSerialPort {
    return @"/dev/cu.SLAB_USBtoUART";
}


+ (NSArray*) allSerialPorts {
    NSMutableArray     *array = [NSMutableArray arrayWithCapacity:10];
    io_object_t         modemService;
    io_iterator_t       serialPortIterator;
    
    kern_return_t kernResult = findModems(&serialPortIterator);
    if (KERN_SUCCESS == kernResult) {
        // Iterate across all modems found.
        
        while ((modemService = IOIteratorNext(serialPortIterator))) {
            CFTypeRef    bsdPathAsCFString;
            
            // Get the callout device's path (/dev/cu.xxxxx). The callout
            // device should almost always be
            // used: the dialin device (/dev/tty.xxxxx) would be used when
            // monitoring a serial port for
            // incoming calls, e.g. a fax listener.
            
            bsdPathAsCFString = IORegistryEntryCreateCFProperty(
                                     modemService,
                                     CFSTR(kIOCalloutDeviceKey),
                                     kCFAllocatorDefault,
                                     0
                                );
            if (bsdPathAsCFString) {
                [array addObject:(NSString *)CFBridgingRelease(bsdPathAsCFString)];
            }
            
            // Release the io_service_t now that we are done with it.
            (void) IOObjectRelease(modemService);
        }
    } else {
        NSLog(@"No serial connection found");
    }
    
    return array;
}

+ (NSString *) defaultBaudrate {
    return @(115200).stringValue;
}

+ (nonnull NSArray *)standardBaudrates {
    return [NSArray arrayWithObjects:
                             @"50",    @"110",    @"134",    @"150",    @"200"
                       ,    @"300",    @"600",   @"1200",   @"1800",   @"2400"
                       ,   @"4800",   @"9600",  @"19200",  @"38400",   @"7200"
                       ,  @"14400",  @"28800",  @"57600",  @"76800", @"115200"
                       , @"230400", @"460800", @"921600", nil
                     ];
}

- (instancetype) init {
    logString("");                                                              // used to suppress unused message
    if (self = [super init]) {
        serialPortFileDescriptor = -1;
        _run = false;
    }
    return self;
}

- (NSControlStateValue) connect:(NSString *)portName with:(unsigned long)baudRate {
    [self open:portName with:baudRate];
    if (self.isOpen) {
        [self intervalReading];
        return NSControlStateValueOn;
    }
    else {
        return NSControlStateValueOff;
    }
}

- (void) open:(NSString *)portName with:(unsigned long)baudRate {

    serialPortFileDescriptor = openSerialPort(
                    [portName cStringUsingEncoding:NSISOLatin1StringEncoding]
                  , baudRate
    );
    
    // NSUTF8StringEncoding
    if (-1 == serialPortFileDescriptor) {
        NSLog(@"Error occured: Not able to open port");
    }
}

- (void) close {
    [self stopReading];
    closeSerialPort(serialPortFileDescriptor);
    serialPortFileDescriptor = -1;
}

- (BOOL) isOpen {
    return -1 != serialPortFileDescriptor;
}

///
/// @param timer Timer for the timer event
- (void) readLinePrivate:(NSTimer *)timer {
    NSLog(@"%@", readLineFromSerialPort(serialPortFileDescriptor));
}

- (void) passTextToMainThread:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->_delegate readText:[NSString stringWithString:text]];
    });
}


- (void) intervalReading {
    
    _run = true;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        //Background Thread
        char                outputBuffer[MaxLineLength+1];                      // Output buffer
        char               *outputPointer;

        
        outputPointer = outputBuffer;
        outputBuffer[MaxLineLength] = '\0';
        for (;self->_run;) {
            char            inputBuffer[BufferSize+1];                          // Input buffer
            char           *inputPointer;                                       // Current char in buffer
            
            ssize_t numBytes = read(self->serialPortFileDescriptor, inputBuffer, BufferSize);
            inputBuffer[BufferSize] ='\0';

            if (numBytes == -1) {
                NSLog(@"Error reading from modem - %s(%d).",
                       strerror(errno), errno
                );
                
            } else if (numBytes > 0) {
                for (inputPointer = inputBuffer;
                     inputPointer < inputBuffer + numBytes; ) {
                    switch (*inputPointer) {
                        default:
                            if (isprint(*inputPointer)) {
                                *(outputPointer++) = *inputPointer;
                            }
                            inputPointer++;
                            break;
                        case '\t':
                            *(outputPointer++) = *inputPointer;
                            inputPointer++;
                            break;
                        case '\n':
                            inputPointer++;
                            break;
                        case '\r':
                            *(outputPointer++) = '\0';
                            [self passTextToMainThread:
                                [NSString stringWithCString:outputBuffer
                                          encoding:NSISOLatin1StringEncoding
                                ]
                            ];
   
                            outputBuffer[0] = '\0';
                            outputPointer = outputBuffer;
                            inputPointer++;
                            break;
                    }
                }
                
            } else {
                //NSLog("Nothing read.\n");
            }
            //[NSThread sleepForTimeInterval: 0.001];
        }
    });
}


- (void) stopReading {
    _run = false;
    [readTimer invalidate];
}




@end
