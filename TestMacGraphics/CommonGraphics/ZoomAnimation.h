//
//  ZoomAnimation.h
//  TestMacGraphics
//
//  Created by Heinz-Jörg on 22.03.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ScientificView;


NS_ASSUME_NONNULL_BEGIN

@interface ZoomAnimation: NSAnimation {
    ScientificView *receiver;
    
}


- (void) setCurrentProgress:(NSAnimationProgress)progress;

@end

NS_ASSUME_NONNULL_END
