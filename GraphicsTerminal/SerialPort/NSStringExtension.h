//
//  NSStringExtension.h
//  GraphicsTerminal
//
//  Created by LegoEsprit on 22.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (NSStringExtension)

+ (instancetype)stringWithPrintableChars:(char *)cString;

@end

NS_ASSUME_NONNULL_END

