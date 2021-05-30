//
//  LedView.h
//  GraphicsTerminal
//
//  Created by LegoEsprit on 22.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface LedView : NSView {

}

- (void)setColor:(NSColor *)color;

@property(assign)  NSViewAnimation *animator;
@property(assign)  NSColor         *ledColor;


@end

NS_ASSUME_NONNULL_END
