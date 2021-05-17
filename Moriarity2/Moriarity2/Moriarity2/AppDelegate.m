//
//  AppDelegate.m
//  Moriarity2
//
//  Created by Heinz-Jörg on 12.03.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import "AppDelegate.h"
#import "TaskWrapper.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    findRunning = NO;
    
    // Insert code here to initialize your application
    if ([self ensureLocateDBExists]==NO) {
        
        // Explain to the user that they need to go update the database as
        // root. That is, if they want locate to be able to really find
        // *any* file on their hard drive (perhaps not great for security,
        //but good for usability).
                
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:@"Sorry, Moriarity's 'locate' database is "
                               "missing or empty.  "
                               "In a terminal, as root run "
                               "'/usr/libexec/locate.updatedb' "
                               "and try Moriarity again."
        ];
        [alert setAlertStyle:NSAlertStyleWarning];
        
        [alert beginSheetModalForWindow:_window completionHandler:nil];
        
        [NSApp terminate:nil];
        
    }

    lorem = _resultView.string;
    NSAttributedString *outputString =
        [[NSAttributedString alloc]
            initWithString:lorem
            attributes:@{
                NSFontAttributeName:
                    [NSFont fontWithName:@"Georgia" size:18.0]
            }
        ];
    [_resultView.textStorage setAttributedString:outputString];
    [self controlTextDidChange:
            [NSNotification
                notificationWithName:@"initialRequest"
                object:_regularExpressionTextField
            ]
    ];
    _command.usesDataSource = NO;
    [_command selectItemAtIndex:0];
    _findCombobox.usesDataSource = NO;
    [_findCombobox selectItemAtIndex:0];
    
    

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
  return YES;
}

- (void)appendOutput:(NSString *)output {
    // add the string (a chunk of the results from locate) to the
    // NSTextView's backing store, in the form of an attributed string
    [_resultView.textStorage
        appendAttributedString: [[NSAttributedString alloc]
                                    initWithString: output
                                ]
    ];
    // setup a selector to be called the next time through the event loop
    // to scroll the view to the just pasted text.  We don't want to
    // scroll right now, because of a bug in Mac OS X version 10.1
    // that causes scrolling in the context of a
    // text storage update to starve the app of events
    [self performSelector:@selector(scrollToVisible:)
               withObject:nil afterDelay:0.1
    ];
}

// This routine is called after adding new results to the text view's
// backing store. We now need to scroll the NSScrollView in which the
// NSTextView sits to the part that we just added at the end
- (void)scrollToVisible:(id)ignore {
    NSRange scroll = NSMakeRange([[_resultView string] length], 0);
    [_resultView scrollRangeToVisible:scroll];
}


// This method is a callback which your controller can use to do other
// initialization when a process is launched.
- (void)processStarted {
    findRunning=YES;
    // clear the results
    NSAttributedString *emptyString = [[NSAttributedString alloc]
                                                    initWithString:@""
                                      ];
    [_resultView.textStorage  setAttributedString:emptyString];
    
    // change the "Sleuth" button to say "Stop"
    [_sleuthButton setTitle:@"Stop"];
}

// This method is a callback which your controller can use to do other
// cleanup when a process is halted.
- (void)processFinished {
    findRunning=NO;
    // change the button's title back for the next search
    [_sleuthButton setTitle:@"Sleuth"];
}

- (void) controlTextDidChange: (NSNotification *) notification {
    if (notification.object != _regularExpressionTextField) return;

    NSMutableAttributedString *outputString =
                        [[NSMutableAttributedString alloc]
                            initWithString:lorem
                            attributes:@{
                                NSFontAttributeName:
                                    [NSFont fontWithName:@"Georgia"
                                            size:18.0
                                    ]
                            }
                        ];
    [_resultView.textStorage setAttributedString:outputString];

    NSString *sourceString = _regularExpressionTextField.stringValue;
    sourceString = [sourceString
                        stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSError *error;
    NSRegularExpression *regex =
        [NSRegularExpression
            regularExpressionWithPattern:sourceString
            options:0
            error:&error
        ];
    if (!regex) return;

    [regex enumerateMatchesInString:lorem
                            options:0
                              range:NSMakeRange(0, lorem.length)
                         usingBlock:^(
                                      NSTextCheckingResult *match,
                                      NSMatchingFlags flags,
                                      BOOL *stop
                                    )
         {
            NSRange range = match.range;
            BOOL abut = (range.location + range.length) >= self->lorem.length;
            if (!abut) {
                [outputString addAttribute:NSForegroundColorAttributeName
                                     value:[NSColor greenColor]
                                     range:range
                ];
                [outputString addAttribute:NSUnderlineStyleAttributeName
                                     value:@(NSUnderlineStyleThick)
                                     range:range
                ];
            }
         }
    ];
    [_resultView.textStorage setAttributedString:outputString];
}



- (void)commandNotification:(NSNotification *)notification {
    NSData *data = nil;
    while ((data = [outFile availableData]) && [data length]) {
        [self appendOutput: [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];

    }
}

- (IBAction)otherAction:(id)sender {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/ls"];
    NSArray *arguments;
    arguments = @[@"-la"];
    [task setArguments:arguments];

    NSPipe *outPipe;
    outPipe = [NSPipe pipe];
    [task setStandardOutput:outPipe];

    outFile = [outPipe fileHandleForReading];
    [outFile waitForDataInBackgroundAndNotify];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandNotification:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:nil];

    [task launch];
}



- (IBAction)sleuth:(id)sender {
    //NSLog(@"%@", _command.objectValueOfSelectedItem);
    //NSLog(@"%@", _findCombobox.objectValueOfSelectedItem);

    if (findRunning) {
        // This stops the task and calls our callback (-processFinished)
        [searchTask stopProcess];
        
        // Release the memory for this wrapper object
        searchTask=nil;
        return;

    }


    // Let's allocate memory for and initialize a new TaskWrapper object,
    // passing in ourselves as the controller for this TaskWrapper object,
    // the path to the command-line tool, and the contents of the text
    // field that displays what the user wants to search on
       
    NSArray *command = @[_command.stringValue];

    
    NSArray *parameters = [command
                            arrayByAddingObjectsFromArray:
                                [_findCombobox.stringValue
                                    componentsSeparatedByString:@" "
                                ]
                          ];

    NSLog(@"%@", parameters);
    
    
    searchTask = [[TaskWrapper alloc]
                    initWithController:self
                    arguments: parameters
                 ];

    
    // kick off the process asynchronously
    [searchTask startProcess];

}



// Display the release notes, as chosen from the menu item in the Help menu.
- (IBAction)displayReleaseNotes:(id)sender {
    // Grab the release notes from the Resources folder in the app bundle,
    // and stuff them into the proper text field
    NSMutableAttributedString *releaseNotesString =
        [[NSMutableAttributedString alloc]
             initWithString:@"123"
             attributes:@{
                 NSFontAttributeName
                 : [NSFont fontWithName:@"Georgia" size:18.0]
            }
        ];
    [_relNotesTextField.textStorage setAttributedString:releaseNotesString];
    [_relNotesWin makeKeyAndOrderFront:self];
    [_relNotesTextField readRTFDFromFile:
            [[NSBundle mainBundle]
                        pathForResource:@"ReadMe" ofType:@"rtf"
            ]
    ];
}


// here we implement a cheesy check to determine if update.locatedb has
// been run on the current machine. a fresh Mac OS X install has a
// very small database file, that contains no useful information.
- (BOOL)ensureLocateDBExists { NSDictionary *attr;
    
    if ([[NSFileManager defaultManager]
                fileExistsAtPath:@"/var/db/locate.database"]==YES)
    {
        //attr=[[NSFileManager defaultManager] fileAttributesAtPath:@"/var/db/locate.database" traverseLink:YES];
        attr=[[NSFileManager defaultManager] attributesOfItemAtPath:@"/var/db/locate.database" error:nil];
        if ([attr fileSize]>4096) {//we pick some size that seems large enough that it couldn't be empty
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
    
}


- (IBAction)commandComboboxAction:(id)sender {
    NSLog(@"Item was changed or enter pressed");
    if (! [[_command objectValues] containsObject:_command.stringValue]) {
        
        [_command addItemWithObjectValue:_command.stringValue];
    }
}

@end
