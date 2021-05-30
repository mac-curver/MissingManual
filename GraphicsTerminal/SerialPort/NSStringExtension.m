//
//  NSStringExtension.m
//  GraphicsTerminal
//
//  Created by LegoEsprit on 22.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import "NSStringExtension.h"

@implementation NSString (NSStringExtension)


+ (instancetype)stringWithPrintableChars:(char *)cString {
    NSMutableString *stringBuffer = [NSMutableString stringWithCString:cString
                                            encoding:NSISOLatin1StringEncoding];

    for (NSUInteger index = stringBuffer.length-1; index >= 0; index--) {
        unichar myChar = [stringBuffer characterAtIndex:index];
        if (!isprint(myChar)) {
            switch (myChar) {
                case ' ':
                    break;
                case 27: // <esc>
                    [stringBuffer replaceCharactersInRange:NSMakeRange(index, 1)
                                                withString:@"\\^"];
                    break;
                case '\t':
                    [stringBuffer replaceCharactersInRange:NSMakeRange(index, 1)
                                                withString:@"\\t"];
                    break;
                case '\n':
                    [stringBuffer replaceCharactersInRange:NSMakeRange(index, 1)
                                                withString:@"\\n"];
                    break;
                case '\r':
                    [stringBuffer replaceCharactersInRange:NSMakeRange(index, 1)
                                                withString:@"\\r"];
                    break;
                default:
                    [stringBuffer replaceCharactersInRange:NSMakeRange(index, 1)
                     withString:[NSString stringWithFormat:@"\\%03o", myChar]];
                    break;
            }
            
        }
        
    }
    
    return stringBuffer;
    
}


@end
