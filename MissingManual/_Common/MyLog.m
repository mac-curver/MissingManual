//
//  MyLog.c
//  TestMacGraphics
//
//  Created by LegoEsprit on 04.04.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "MyLog.h"

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
    
    NSCharacterSet *dividers = [NSCharacterSet characterSetWithCharactersInString:@"()"];
    NSString *functionString = [NSString stringWithCString:functionName encoding:NSISOLatin1StringEncoding];
    functionString = [functionString componentsSeparatedByCharactersInSet:dividers].firstObject;
    switch (0) {
        case 0:
            fprintf(stderr, "(%s) %s",
                    functionString.UTF8String, body.UTF8String);
            break;
        case 1:
            fprintf(stderr, "(%s) (%s:%d) %s",
                    functionName, fileName.UTF8String,
                    lineNumber, body.UTF8String);
            break;
    }
}
