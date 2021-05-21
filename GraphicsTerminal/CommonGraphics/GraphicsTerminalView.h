//
//  GraphicsTerminalView.h
//  GraphicsTerminal
//
//  Created by Heinz-Jörg on 21.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import "TriggerClass.h"

#import "ScientificView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GraphicsTerminalView: ScientificView {
    
}

@property(nonatomic, readwrite) TriggerClass   *trigger;

- (void)                changeTriggerMode:(NSInteger) newTriggerMode;
- (void)                changeTriggerPolarity:(NSInteger) selectedSegment;
- (void)                setTriggerChannel:(NSInteger) channel;


- (void)                readText:(NSString *) availableText;

@end

NS_ASSUME_NONNULL_END
