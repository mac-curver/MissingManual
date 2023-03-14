//
//  AppDelegate.h
//  GradientTestApplication
//
//  V 2.20
//  Changed by LegoEsprit on 04.06.21.
//  Created by LegoEsprit on 23.05.21.
//  Copyright © 2021-2023 LegoEsprit. All rights reserved.
//
//  Uses "Menu Controller" with "Prepares content = YES" and "Editable = NO"
//
//  from Terminal: defaults read de.LegoEsprit.GradientTestApplication
//
//  Ort: /Users/hj/Documents/Development/GitHub/Public/MissingManual/MissingManual/GradientTestApplication/GradientTestApplication/GradientTestApplication

#import <Cocoa/Cocoa.h>
@class TestGradient;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    @public
    
    /// Popup button to select the drawing context
    __weak IBOutlet NSPopUpButton *drawingContext;
    
    /// Segmented control to select the kind of gradient (linear, ...)
    __weak IBOutlet NSSegmentedControl *kindOfGradient;
    
    /// Color well for the starting color.
    __weak IBOutlet NSColorWell *colorWell0;
    
    /// Color well for the ending color.
    __weak IBOutlet NSColorWell *colorWell1;
    
    /// Text field to enter the starting radius.
    __weak IBOutlet NSTextField *startRadius;
    
    /// Text field to enter the end radius.
    __weak IBOutlet NSTextField *endRadius;
    
    /// NSPopUpButton with all available color spaces.
    __weak IBOutlet NSPopUpButton *colorSpaceMenu;
    
    /// Extra view to test the generated gradient code.
    __weak IBOutlet TestGradient *testGradientView;
}

/// Menuaction to copy the generated gradient code into the clipboard.
- (IBAction)copyGradientCodeToClipboard:(NSMenuItem *)sender;

/// Popupbutton action to change the drawing context
///
/// Propagates the drawing context to the NSView and disables the 'Conic'-
/// button if not available.
- (IBAction)changeDrawingContext:(NSPopUpButton *)sender;


/// ColorWell event for the start color.
- (IBAction)updateStartColor:(NSColorWell *)sender;

/// ColorWell event for the end color.
- (IBAction)updateEndColor:(NSColorWell *)sender;


/// Popupbutton action to select the color space.
- (IBAction)selectColorSpace:(NSPopUpButton *)sender;


@end

