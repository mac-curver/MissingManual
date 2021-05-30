//
//  TriggerClass.h
//  GraphicsTerminal
//
//  Created by LegoEsprit on 20.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSInteger {
      NoTrigger
    , WaitForLow
    , WaitForHigh
    , Triggered
    , N_TriggerStates
} TriggerState;

typedef enum : NSInteger {
      AutoTrigger
    , NormalTrigger
    , SingleTrigger
    , N_TriggerModes
} TriggerMode;

@class AppDelegate;

@interface TriggerClass : NSObject {

    int                             autoTriggerCount;
    CFAbsoluteTime                  autoTriggerTimeStamp;
    
    AppDelegate                    *appDelegate;

    
}


- (instancetype)    initWithChannel:(int)channel;

- (void)            checkAutoTrigger:(int *)autoTriggerCount;

- (void)            checkAutoTriggerTimeStamp:(double)autoTriggerTimeStamp;

- (void)            triggerModeReset;

- (TriggerState)    calculateTriggerState:(double) value;
- (double)          secondsElapsed;


@property(assign)                  TriggerState state;
@property(assign)                  TriggerMode  mode;
@property(assign)                  int          polarity;
@property(assign)                  int          channel;


@end



NS_ASSUME_NONNULL_END
