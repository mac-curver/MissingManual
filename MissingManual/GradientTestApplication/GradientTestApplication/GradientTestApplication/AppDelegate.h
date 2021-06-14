//
//  AppDelegate.h
//  GradientTestApplication
//
//  Changed by LegoEsprit on 04.06.21.
//  Created by LegoEsprit on 23.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//
//  Uses "Menu Controller" with "Prepares content = YES" and "Editable = NO"
//
//  from Terminal: defaults read de.LegoEsprit.GradientTestApplication
//

#import <Cocoa/Cocoa.h>
@class TestGradient;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    @public
    
    __weak IBOutlet NSPopUpButton *drawingContext;
    __weak IBOutlet NSSegmentedControl *kindOfGradient;
    __weak IBOutlet NSColorWell *color0;
    __weak IBOutlet NSColorWell *color1;
    
    __weak IBOutlet NSTextField *startRadius;
    __weak IBOutlet NSTextField *endRadius;
    
    __weak IBOutlet NSPopUpButton *colorSpaceMenu;
    
    __weak IBOutlet TestGradient *testGradientView;
}

- (IBAction)copyGradientCodeToClipboard:(NSMenuItem *)sender;
- (IBAction)changeDrawingContext:(NSPopUpButton *)sender;


@end

