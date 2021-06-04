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

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[NSUserDefaults standardUserDefaults] registerDefaults:TestGradient.gradientDefaults];

    [colorSpaceMenu removeAllItems];
    [colorSpaceMenu addItemsWithTitles:TestGradient.allColorSpaces];
    [colorSpaceMenu selectItemWithTitle:TestGradient.defaultColorSpace];
    
    [kindOfGradient setSegmentCount:testGradientView.numberOfKinds];

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
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

@end
