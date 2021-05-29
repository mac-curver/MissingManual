//
//  AppDelegate.h
//  GradientTestApplication
//
//  Created by LegoEsprit on 23.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TestGradient;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    @public
    
    __weak IBOutlet NSSegmentedControl *kindOfGradient;
    __weak IBOutlet NSColorWell *color0;
    __weak IBOutlet NSColorWell *color1;
    __weak IBOutlet NSTextField *location0;
    __weak IBOutlet NSTextField *location1;
    
    __weak IBOutlet NSTextField *startRadius;
    __weak IBOutlet NSTextField *endRadius;
    
    __weak IBOutlet NSPopUpButton *colorSpaceMenu;
    
    __weak IBOutlet TestGradient *testGradientView;
    
}

- (IBAction)copyGradientCodeToClipboard:(NSMenuItem *)sender;

@end
