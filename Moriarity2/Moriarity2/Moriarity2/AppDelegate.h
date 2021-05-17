//
//  AppDelegate.h
//  Moriarity2
//
//  Created by Heinz-Jörg on 12.03.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//  2021-03-13  hjs Works now on 10.13 MacLG
//

#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, TaskWrapperController> {
    BOOL            findRunning;
    TaskWrapper    *searchTask;
    NSString       *lorem;
    NSFileHandle   *outFile;

    
}
@property (unsafe_unretained) IBOutlet NSTextView *resultView;
@property (weak) IBOutlet NSTextField *regularExpressionTextField;

@property (weak) IBOutlet NSComboBox *command;
@property (weak) IBOutlet NSComboBox *findCombobox;

@property (weak) IBOutlet NSButton *sleuthButton;

@property (weak) IBOutlet NSWindow *relNotesWin;
@property (unsafe_unretained) IBOutlet NSTextView *relNotesTextField;

- (IBAction)otherAction:(id)sender;


- (IBAction)sleuth:(id)sender;
- (IBAction)displayReleaseNotes:(id)sender;
- (BOOL)ensureLocateDBExists; // uses a heuristic to make sure we're up to date
- (void) controlTextDidChange: (NSNotification *) notification;

- (void)commandNotification:(NSNotification *)notification;

- (void)appendOutput:(NSString *)output;

- (IBAction)commandComboboxAction:(id)sender;


// This method is a callback which your controller can use to do other initialization when a process
// is launched.
- (void)processStarted;

// This method is a callback which your controller can use to do other cleanup when a process
// is halted.
- (void)processFinished;


@end

