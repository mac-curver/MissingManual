//
//  NSTextViewExtension.m
//  TestMacGraphics
//
//  Created by Heinz-Jörg on 05.04.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import "NSTextViewExtension.h"

@implementation NSTextView (NSTextViewExtension)

- (void) appendToEnd:(NSAttributedString *)attrString {
    BOOL atEnd = self.visibleRect.origin.y + self.visibleRect.size.height
                 == self.bounds.origin.y   + self.bounds.size.height;
    
    [self.textStorage appendAttributedString:attrString];
    
    if (atEnd) {
        [self scrollRangeToVisible: NSMakeRange(self.string.length, 0)];
    }
}


@end
