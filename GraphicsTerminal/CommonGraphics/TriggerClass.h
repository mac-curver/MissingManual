//
//  TriggerClass.h
//  GraphicsTerminal
//
//  Created by Heinz-Jörg on 20.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum TriggerState {
    NoTrigger
    , WaitForLow
    , WaitForHigh
    , Triggered
    , N_TriggerStates
} TriggerState;

typedef enum TriggerMode {
    AutoTrigger
    , NormalTrigger
    , SingleTrigger
    , N_TriggerModes
} TriggerMode;

@interface TriggerClass : NSObject {

    int                             autoTriggerCount;
    CFAbsoluteTime                  autoTriggerTimeStamp;
    
}


- (instancetype) initWithChannel:(int)channel;

- (void) checkAutoTrigger:(int *)autoTriggerCount;

- (void) checkAutoTriggerTimeStamp:(double)autoTriggerTimeStamp;

- (void) triggerModeReset;

- (TriggerState) calculateTriggerState:(double) value;


@property(assign)               TriggerState    state;
@property(assign)               TriggerMode     mode;
@property(assign)               int             polarity;
@property(assign)               int             channel;


@end



NS_ASSUME_NONNULL_END
