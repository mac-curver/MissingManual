//
//  GraphicsTerminalView.m
//  GraphicsTerminal
//
//  Created by Heinz-Jörg on 21.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import "GraphicsTerminalView.h"
#import "MyLog.h"


@implementation GraphicsTerminalView

- (void) awakeFromNib {
    [super awakeFromNib];
    _trigger = [[TriggerClass alloc] initWithChannel:0];
}

- (void) changeTriggerMode:(NSInteger) newTriggerMode {
    _trigger.mode = (int) newTriggerMode;
    _trigger.state = WaitForLow;
}

- (void) setTriggerChannel:(NSInteger) channel {
    _trigger.channel = (int) channel;
}

- (void) changeTriggerPolarity:(NSInteger)selectedSegment {
    switch (selectedSegment) {
        case 0:
            _trigger.polarity = -1;
            break;
        default:
            _trigger.polarity = +1;
            break;
    }
}



- (void) readText:(NSString *)availableText  {
    
    // NSMutableString *lineString = [[NSMutableString alloc] initWithString:availableText];
    // [lineString appendString:@"\n"];
    // NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:lineString];
    //
    // [scrollTextView appendToEnd:attrText];
    
    NSArray* textArray = [availableText componentsSeparatedByString:@"\t"];
    NSString *triggerValueAsString = [textArray objectAtIndex:_trigger.channel];
    switch ([_trigger calculateTriggerState:triggerValueAsString.doubleValue]) {
        case NoTrigger:
            break;
            
        case WaitForLow:
        case WaitForHigh:
            index = 0;
            break;
        default:
            
            for (int column = 0; column < MIN(textArray.count, 3); column++) {
                threeArrays[column][index] = NSMakePoint(
                      index,
                      [[textArray objectAtIndex:column] intValue]
                );
            }
            
            index ++;
            
            if (index > scientificWidth) {
                index = 0;
                [_trigger triggerModeReset];
            }
            
            break;
            
    }
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
