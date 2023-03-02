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

/// Notification when application did finish launching.
///
/// Register the defaults from the TestGradient view.
/// Fill the menu with the colorspaces from the TestGradient view.
/// We can't use [colorSpaceMenu addItemWithTitle:] as it is failing,
/// in case we have multiple entries with the same name!
/// Disable the Conic button if not available and finally initialize
/// starting colors.
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    
    /// Register the defaults from the TestGradient view
    [[NSUserDefaults standardUserDefaults] registerDefaults:TestGradient.gradientDefaults];

    /// Fill the menu with the colorspaces from the TestGradient view
    [colorSpaceMenu removeAllItems];
    /// We can't use [colorSpaceMenu addItemWithTitle:] as it fails,
    /// if we have multiple entries with the same name!
    for (NSString *colorSpaceItem in TestGradient.allColorSpaceNames) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:colorSpaceItem
                                                      action:NULL
                                               keyEquivalent:@""
                            ];
        [colorSpaceMenu.menu addItem:item];
    }
    [colorSpaceMenu selectItemWithTitle:TestGradient.defaultColorSpaceName];
    
    /// Disable the Conic button if not available
    [self changeDrawingContext:drawingContext];
    
    /// Initialize starting colors
    color0.color = testGradientView.colors[0];
    color1.color = testGradientView.colors[1];
    
    testGradientView.didFinishLaunching = TRUE;
}

/// Notification when application will terminate.
///
/// Overwritten to write into user defaults preferences.
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

- (IBAction)updateStartColor:(NSColorWell *)sender {
    NSInteger colorSpaceIndex = [testGradientView updateColor:sender.color
                                                           at:0
                                 ];
    if (colorSpaceIndex >= 0) {
        [colorSpaceMenu selectItemAtIndex:colorSpaceIndex];
        color1.color = [testGradientView colorAtIndex:1];
    }
}

- (IBAction)updateEndColor:(NSColorWell *)sender {
    NSInteger colorSpaceIndex = [testGradientView updateColor:sender.color
                                                           at:1
                                 ];
    if (colorSpaceIndex >= 0) {
        [colorSpaceMenu selectItemAtIndex:colorSpaceIndex];
        color0.color = [testGradientView colorAtIndex:0];
    }
}

- (IBAction)selectColorSpace:(NSPopUpButton *)sender {
    NSInteger colorSpaceIndex = sender.indexOfSelectedItem;
    NSColorSpace *colorSpace = TestGradient.allColorSpaces[colorSpaceIndex];
    [testGradientView selectColorSpace:colorSpace];

    color0.color = [testGradientView colorAtIndex:0];
    color1.color = [testGradientView colorAtIndex:1];
}




@end
