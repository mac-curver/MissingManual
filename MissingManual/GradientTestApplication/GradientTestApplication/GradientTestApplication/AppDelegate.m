//
//  AppDelegate.m
//  GradientTestApplication
//
//  Created by LegoEsprit on 23.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import "TestGradient.h"
#import "AppDelegate.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    /// Register the defaults from the TestGradient view
    [[NSUserDefaults standardUserDefaults] registerDefaults:TestGradient.gradientDefaults];

    /// Fill the menu with the colorspaces from the TestGradient view
    [colorSpaceMenu removeAllItems];
    [colorSpaceMenu addItemsWithTitles:TestGradient.allColorSpaceNames];
    [colorSpaceMenu selectItemWithTitle:TestGradient.defaultColorSpaceName];
    
    /// Disable the Conic button if not available
    [self changeDrawingContext:drawingContext];
    
    color0.color = testGradientView.colors[0];
    color1.color = testGradientView.colors[1];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    /// Store defaults into the shared defaults
    [testGradientView storeDefaults];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return true;
}


- (IBAction)copyGradientCodeToClipboard:(NSMenuItem *)sender {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    NSData *data = [[testGradientView code] dataUsingEncoding:NSUTF8StringEncoding];
    [pasteboard setData:data forType:NSPasteboardTypeString];
}

- (IBAction)changeDrawingContext:(NSPopUpButton *)sender {
    /// propagate the drawing context to the TestGradient view
    [testGradientView updateContext:sender];
    
    /// Enable/disable the Conic item of the segmented control
    BOOL conicIsEnabled = 2<testGradientView.numberOfKinds;
    [kindOfGradient setEnabled:conicIsEnabled forSegment:2];
}

@end
