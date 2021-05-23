//
//  GraphicsTerminalView.m
//  GraphicsTerminal
//
//  Created by Heinz-Jörg on 21.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import "GraphicsTerminalView.h"
#import "HorizontalGraphAxis.h"
#import "VerticalGraphAxis.h"

#import "MyLog.h"


@implementation GraphicsTerminalView

- (void) awakeFromNib {
    [super awakeFromNib];
    _overType = Samples;
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
            switch (_overType) {
                case Samples:
                    for (int column = 0; column < MIN(textArray.count, 3); column++) {
                        threeArrays[column][index] = NSMakePoint(
                            index,
                            [[textArray objectAtIndex:column] intValue]
                        );
                    }
                    break;
                case YOverX:
                    threeArrays[0][index] = NSMakePoint(0, 0);
                    for (int column = 1; column < MIN(textArray.count, 3); column++) {
                        threeArrays[column][index] = NSMakePoint(
                            [[textArray objectAtIndex:0] intValue],
                            [[textArray objectAtIndex:column] intValue]
                        );
                    }
                    break;
                    
                case OverTime:
                    for (int column = 0; column < MIN(textArray.count, 3); column++) {
                        threeArrays[column][index] = NSMakePoint(
                            1000.0*[_trigger secondsElapsed],
                            [[textArray objectAtIndex:column] intValue]
                        );
                    }

                    break;
                default:
                    break;
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
    
    NSArray *colors = @[ [NSColor redColor]
                         , [NSColor greenColor]
                         , [NSColor blueColor]
                         ];
    
    NSEraseRect(self.bounds);
    
    if (self.bounds.origin.x != 0 || self.bounds.origin.y != 0) {
        NSAssert(false, @"Here we have an issue");
    }
    
    NSAffineTransform* xform = [NSAffineTransform transform];
    
    [xform translateXBy:_offset.x yBy:_offset.y];
    // No scaling to avoid impact on lineWidth
    //[xform scaleXBy:_offsetScale.scale.x yBy:_offsetScale.scale.y];
    [xform concat];
    
    [self choosePrimary];
    
    
    [horizontalAxis setGridRect:windowRect];
    [verticalAxis   setGridRect:windowRect];
    
    
    [self setColor:[NSColor grayColor]];
    
    [verticalAxis lineAt: 0.0];
    [verticalAxis linTics:0.0  separation:0.0 ticPercent:0.7
            andMajorEvery:10   lineWidth:0.5
     ];
    [verticalAxis linAnnotation:0.0 separation:0.0 alignment:Left];
    
    
    [horizontalAxis lineAt: 0.0];
    [horizontalAxis linTics:0.0  separation:0.0 ticPercent:0.7
              andMajorEvery:10   lineWidth:0.5
     ];
    [horizontalAxis linAnnotation:0.0 separation:0.0 alignment:Bottom];
    
    [self setColor:[NSColor blueColor]];
    [self plotCircleAt:mouseDownLocation radius:5];
    
    
    [self setColor:[NSColor redColor]];
    [self plotCircleAt:redPoint radius:5];
    
    
    for (int column = 0; column < 3; column++) {
        
        [self setColor:[colors objectAtIndex:column]];
        NSBezierPath *path = [NSBezierPath bezierPath];
        
        [path moveToPoint:
         NSMakePoint(threeArrays[column][0].x*_scale.x,
                     threeArrays[column][0].y*_scale.y)];
        
        for (int i = 1; i < scientificWidth; i++) {
            [path lineToPoint:
             NSMakePoint(threeArrays[column][i].x*_scale.x,
                         threeArrays[column][i].y*_scale.y)];
        }
        [path setLineWidth:1.0];
        [path stroke];
    }
    

//     NSLog(@"%f %f %f %f %f %f", xform.transformStruct.m11
//     , xform.transformStruct.m12
//     , xform.transformStruct.m21
//     , xform.transformStruct.m22
//     , xform.transformStruct.tX
//     , xform.transformStruct.tY);
 
    
    //[self setColor:[NSColor greenColor]];
    //[self plotSine:0.05 amplitude:500.0 phase:sinePhase];
    
    [self setColor:[NSColor blueColor]];
    [threePathes[1] stroke];
    
    [self setColor:[NSColor greenColor]];
    [self plotCircleAt:greenPoint radius:5];
    [threePathes[2] stroke];
    
    [self setColor:[NSColor yellowColor]];
    [self plotCircleAt:yellowPoint radius:5];
    
    
    [xform invert];
    [xform concat];
    
    
    
    [self setColor:[NSColor blueColor]];
    [[NSBezierPath bezierPathWithRect:rubberbandRect] stroke];
}

@end
