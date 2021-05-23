//
//  AppDelegate.h
//  GradientTestApplication
//
//  Created by Heinz-Jörg on 23.05.21.
//  Copyright © 2021 Heinz-Jörg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    @public
    
    __weak IBOutlet NSSegmentedControl *kindOfGradient;
    __weak IBOutlet NSColorWell *color0;
    __weak IBOutlet NSColorWell *color1;
    __weak IBOutlet NSTextField *location0;
    __weak IBOutlet NSTextField *location1;
    
    __weak IBOutlet NSTextField *startRadius;
    __weak IBOutlet NSTextField *endRadius;
}


@end

