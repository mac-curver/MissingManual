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
    
    // NSLog only adds a newline to the end of the NSLog format if one is not
    // already there.
    if (![format hasSuffix: @"\n"]) {
        format = [format stringByAppendingString: @"\n"];
    }
    
    NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
    
    // End using variable argument list.
    va_end (ap);
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    
    switch (1) {
        case 0: {
            NSString *function = [NSString stringWithCString:stripped(functionName)
                                                    encoding:NSISOLatin1StringEncoding
                                  ];

            fprintf(stderr, "%s %s:%s",
                    [dateFormatter stringFromDate:[NSDate date]].UTF8String
                    , function.UTF8String
                    , body.UTF8String
            );
            }
            break;
        case 1: {
            NSString *fileName = [NSString stringWithUTF8String:file].lastPathComponent;
            fprintf(stderr, "%s %s:%d %s %s",
                    [dateFormatter stringFromDate:[NSDate date]].UTF8String
                    , fileName.UTF8String
                    , lineNumber
                    , functionName
                    , body.UTF8String
            );
            }
            break;
    }
}
