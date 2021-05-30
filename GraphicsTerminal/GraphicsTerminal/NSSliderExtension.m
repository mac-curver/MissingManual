//
//  NSSliderExtension.m
//  GraphicsTerminal
//
//  Created by LegoEsprit on 15.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import "NSSliderExtension.h"

@implementation NSSlider (NSSliderExtension)

- (void)rightMouseDown:(NSEvent *)event {
    NSLog(@"rightClick 2 occured");
    
    /*
    NSRect frame = NSMakeRect(100, 100, 200, 200);
    NSWindow *window = [[NSWindow alloc] initWithContentRect:frame
                                                   styleMask:NSWindowStyleMaskClosable
                                                     backing: NSBackingStoreBuffered
                                                       defer:false
                        ];
    [window makeKeyAndOrderFront: window];
     */
    
    [super rightMouseDown:event];
    
}

@end
