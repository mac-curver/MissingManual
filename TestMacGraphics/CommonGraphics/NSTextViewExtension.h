//
//  NSTextViewExtension.h
//  TestMacGraphics
//
//  Created by Heinz-Jörg on 05.04.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTextView (NSTextViewExtension)

- (void) appendToEnd:(NSAttributedString *)attrString;

@end

NS_ASSUME_NONNULL_END
