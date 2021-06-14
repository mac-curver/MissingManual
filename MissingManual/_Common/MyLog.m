//
//  MyLog.c
//  TestMacGraphics
//
//  Created by LegoEsprit on 04.04.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "MyLog.h"

char* stripped(const char *textPtr) {
    static char buffer[1024];
    char *bufferPtr = buffer;
    for (int i = 0; i < 1023 && *textPtr; i++) {
        switch (*textPtr) {
            case '[':
                break;
            case ']':
            case ':':
                i = 1024;
                break;
            default:
                *bufferPtr++ = *textPtr;
                break;
        }
        textPtr++;
    }
    *bufferPtr = 0;
    return buffer;
}

void MyLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...) {
    // Type to hold information about variable arguments.
    va_list ap;
    
    // Initialize a variable argument list.
    va_start (ap, format);
    
    // NSLog only adds a newline to the end of the NSLog format if
    // one is not already there.
    // Here we are utilizing this feature of NSLog()
    if (![format hasSuffix: @"\n"]) {
        format = [format stringByAppendingString: @"\n"];
    }
    
    NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
    
    // End using variable argument list.
    va_end (ap);
    
    NSString *fileName = [NSString stringWithUTF8String:file].lastPathComponent;
    
    NSString *function = [NSString stringWithCString:stripped(functionName)
                                            encoding:NSISOLatin1StringEncoding
                          ];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    
    switch (0) {
        case 0:
            fprintf(stderr, "%s %s:%s",
                    [dateFormatter stringFromDate:[NSDate date]].UTF8String,
                    function.UTF8String,
                    body.UTF8String
            );
            break;
        case 1:
            fprintf(stderr, "(%s) (%s:%d) %s",
                    functionName, fileName.UTF8String,
                    lineNumber, body.UTF8String
            );
            break;
    }
}
