//
//  TriggerClass.m
//  GraphicsTerminal
//
//  Created by Heinz-Jörg on 20.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//


#import "AppDelegate.h"
#import "TriggerClass.h"
#import "LedView.h"

#import "MyLog.h"

@implementation TriggerClass

const  int                              AutoTriggerFactor = 5;                  // number of cycles to wait before forcing trigger
const  double                           AutoTimeStampFactor =   30*0.001;       // width corresponds to ms ?



- (instancetype) initWithChannel:(int)channel {
    if (self = [super init]) {
        [self setTrigger:WaitForLow];

        _channel = channel;
        autoTriggerCount = 0;
        autoTriggerTimeStamp = 0.0;
        appDelegate = (AppDelegate *)NSApplication.sharedApplication.delegate;

    }
    return self;
}

- (void)setTrigger:(TriggerState)newState {
    _state = newState;
    switch (_state) {
        case NoTrigger:
            [appDelegate.led setColor:NSColor.lightGrayColor];
            break;
        case WaitForLow:
            [appDelegate.led setColor:NSColor.greenColor];
            break;
        case WaitForHigh:
            [appDelegate.led setColor:NSColor.orangeColor];
            break;
        case Triggered:
        default:
            [appDelegate.led setColor:NSColor.redColor];
            break;
    }
    appDelegate.triggerLevelState.intValue = _state;
}

- (void)checkAutoTrigger:(nonnull int *)autoTriggerCount {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    switch (_mode) {
        case AutoTrigger:
            *autoTriggerCount = *autoTriggerCount + 1;
            if (*autoTriggerCount > AutoTriggerFactor*[defaults doubleForKey:@"maxX"]) {
                [self setTrigger:Triggered];
            }
            break;
        default:
            break;
    }
}

- (void)checkAutoTriggerTimeStamp:(double)autoTriggerTimeStamp {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    switch (_mode) {
        case AutoTrigger:
            NSLog(@"%f %f", CFAbsoluteTimeGetCurrent()- autoTriggerTimeStamp, AutoTimeStampFactor*[defaults doubleForKey:@"maxX"]);
            if ((CFAbsoluteTimeGetCurrent() - autoTriggerTimeStamp) > AutoTimeStampFactor*[defaults doubleForKey:@"maxX"]) {
                [self setTrigger:Triggered];
                autoTriggerTimeStamp = CFAbsoluteTimeGetCurrent();
                
            }

            break;
        default:
            break;
    }
}

- (void) clearSingleShot {
    AppDelegate *appDelegate = (AppDelegate *)NSApplication.sharedApplication.delegate;
    [appDelegate clearSingleShot];
}

- (void) triggerModeReset {
    autoTriggerCount = 0;
    switch (_mode) {
        case SingleTrigger:
            [self clearSingleShot];
            [self setTrigger:NoTrigger];
            break;
        default:
            [self setTrigger:WaitForLow];
 //           autoTriggerTimeStamp = CFAbsoluteTimeGetCurrent();
            break;
    }
    
}

- (bool) compareWith:(double)value higherThan:(int)higher {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    
    switch (higher) {
        case -1:
            return value < [defaults doubleForKey:@"triggerLevel"];
        case 1:
            return value > [defaults doubleForKey:@"triggerLevel"];
        default:
            NSAssert(false, @"Shouldnever ever happen");
            return false;
    }
}

- (TriggerState) calculateTriggerState:(double) value {
    switch (_state) {
        case NoTrigger:
            break;
            
        case WaitForLow:
            if ([self compareWith:value+_polarity*10 higherThan:_polarity]) {
                //[self checkAutoTrigger:&autoTriggerCount];
                [self checkAutoTriggerTimeStamp:autoTriggerTimeStamp];
                break;
            }
            [self setTrigger:WaitForHigh];
            // fall through
        case WaitForHigh:
            if ([self compareWith:value higherThan:-_polarity]) {
                //[self checkAutoTrigger:&autoTriggerCount];
                [self checkAutoTriggerTimeStamp:autoTriggerTimeStamp];
                break;
            }
            [self setTrigger:Triggered];
            autoTriggerTimeStamp = CFAbsoluteTimeGetCurrent();
            // fall through
        default:
            
            break;
            
    }
    return _state;
}

- (double)secondsElapsed { 
    return  CFAbsoluteTimeGetCurrent() - autoTriggerTimeStamp;
}

@end
