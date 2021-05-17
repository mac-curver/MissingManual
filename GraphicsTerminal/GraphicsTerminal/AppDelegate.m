//
//  AppDelegate.m
//  TestMacGraphics
//
//  Created by Heinz-Jörg on 07.09.20.
//  Copyright © 2020 LegoEsprit. All rights reserved.
//

#import "AppDelegate.h"
#import "NSTextViewExtension.h"

#import "MyLog.h"

@implementation AppDelegate

const int MinHeightToUpdate = 20;

- (IBAction)menuPreferences:(NSMenuItem *)sender {
    [_settings setIsVisible:YES];
    //[_settings setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
}

- (IBAction)menuShowTerminal:(NSMenuItem *)sender {
    [_window setIsVisible:YES];
    //[_window setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
}


- (void) initializePreferences {
    
    // Register the preference defaults early.
    NSDictionary *appDefaults = @{
                         @"min0" : @0.0
                       , @"min1" : @0.0
                       , @"min2" : @0.0
                       
                       , @"max0" : @1000.0
                       , @"max1" : @1000.0
                       , @"max2" : @1000.0
  
                       , @"slider0": @   0.0
                       , @"slider1": @ 500.0
                       , @"slider2": @1000.0
                       
                       , @"minX": @    0.0
                       , @"maxX": @  499.0
                       , @"minY": @    0.0
                       , @"maxY": @ 2048.0
                       
                         
                       , @"triggerLevel":    @1.0
                       , @"triggerPolarity": @1
                       , @"triggerMode":     @1
                       , @"baudRate": @115200
                
                       
    };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    
    NSLog(@"%d", [defaults integerForKey:@"triggerPolarity"]);
    
    [_slider0 setDoubleValue:[defaults doubleForKey:@"slider0"]];
    [_slider1 setDoubleValue:[defaults doubleForKey:@"slider1"]];
    [_slider2 setDoubleValue:[defaults doubleForKey:@"slider2"]];
    
    [_baudRate setStringValue:[defaults stringForKey:@"baudRate"]];             // Must use string to avoid group separator
    
    [_triggerModeControl     setSelectedSegment:0];//[defaults integerForKey:@"triggerMode"]];
    [self changeTriggerMode:_triggerModeControl];

    [_triggerPolarity setSelectedSegment:0];//[defaults integerForKey:@"triggerPolarity"]];
    [self changeTriggerPolarity:_triggerPolarity];

    _scientificView.triggerChannel = 0;
    /*
    if ([defaults objectForKey:@"SettingsLeft"]) {
        NSPoint topLeft = NSMakePoint([defaults doubleForKey:@"SettingsLeft"], [defaults doubleForKey:@"SettingsTop"]);
        [_settings setFrameTopLeftPoint:topLeft];
    }
    */

}



- (void) sliderGesture:(NSGestureRecognizer *)g {
    NSLog(@"tag: \(v.tag)");
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    [_serialPortPopup removeAllItems];
    [_serialPortPopup addItemsWithTitles:SerialportInterface.allSerialPorts];
    [_serialPortPopup selectItemWithTitle:SerialportInterface.defaultSerialPort];

    [_baudRate removeAllItems];
    [_baudRate addItemsWithObjectValues:SerialportInterface.standardBaudrates];
    [_baudRate selectItemWithObjectValue:SerialportInterface.defaultBaudrate];
    
    serialPort = [[SerialportInterface alloc] init];
    serialPort.delegate = self;//_scientificView;
    
    
    gesture = [[NSClickGestureRecognizer alloc] initWithTarget:_slider0 action:@selector(sliderGesture:)];
    if (gesture) {
        NSLog(@"Works");
    }
    
    
    // Accessing from terminal: defaults read 'de.legoesprit.testmacgraphics'
    [self initializePreferences];
    
    if (_connectButton.state == NSControlStateValueOn) {
        _connectButton.state = [serialPort connect:_serialPortPopup.titleOfSelectedItem
                                              with:_baudRate.integerValue
                                ];
    }
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Be sure that <key>NSSupportsSuddenTermination</key><false/> is set in info.plist
    return NSTerminateNow;
}

- (void) applicationWillTerminate:(NSNotification *)aNotification {
    // Be sure that <key>NSSupportsSuddenTermination</key><false/> is set in info.plist
    //NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    /*
    NSNumber *leftPosition = [NSNumber numberWithDouble:_settings.frame.origin.x];
    NSNumber *topPosition  = [NSNumber numberWithDouble:_settings.frame.origin.y+_settings.frame.size.height];
    [defaults setObject:leftPosition forKey:@"SettingsLeft"];
    [defaults setObject:topPosition  forKey:@"SettingsTop"];
    */
    
    //[defaults setInteger:_triggerMode.selectedSegment forKey:@"triggerMode"];
    //[defaults setInteger:_triggerPolarity.selectedSegment forKey:@"triggerPolarity"];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return true;
}

- (IBAction)changeSerialPort:(NSPopUpButton *)sender {
    NSLog(@"Serial port should change to %@", sender.objectValue);
}

- (IBAction)changeBaudRate:(NSPopUpButton *)sender {
    NSLog(@"Baudrate should change to %@", sender.objectValue);
}



- (IBAction) connect:(NSButton *)sender {
    switch (sender.state) {
        case NSControlStateValueOff:
            [serialPort close];
            break;
        case NSControlStateValueOn:
            sender.state = [serialPort connect:_serialPortPopup.titleOfSelectedItem
                                          with:_baudRate.integerValue
                            ];

            break;
        case NSControlStateValueMixed:
        default:
            break;
            
    }
}



- (IBAction)readLine:(NSButton *)sender {
    if (serialPort.isOpen) {
        switch (sender.state) {
            case NSControlStateValueOff:
                [serialPort stopReading];
                break;
            case NSControlStateValueOn:
                //[serialPort flushSerialInput];
                [serialPort intervalReading];
                break;
            case NSControlStateValueMixed:
            default:
                break;
        }
    }
}



- (void) readText:(NSString *)availableText  {

    NSMutableString *lineString = [[NSMutableString alloc] initWithString:availableText];
    [lineString appendString:@"\n"];
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:lineString];
    
    //[_preferencesTextView appendToEnd:attrText];
    if (_scrollTextView.frame.size.height > MinHeightToUpdate) {
        [_scrollTextView appendToEnd:attrText];
    }

    if (_scientificView.frame.size.height > MinHeightToUpdate) {
        [_scientificView readText:availableText];
    }
    
}


- (IBAction)changeTriggerChannel:(NSPopUpButton *)sender {
}

- (IBAction)changeTriggerMode:(NSSegmentedControl *)sender {
    [_scientificView changeTriggerMode:(int)sender.selectedSegment];    
}

- (IBAction)changeTriggerPolarity:(NSSegmentedControl *)sender {
    switch (sender.selectedSegment) {
        case 0:
            _scientificView.triggerPolarity = -1;
            break;
        default:
            _scientificView.triggerPolarity = +1;
            break;
    }
}

- (void)  clearSingleShot {
    NSLog(@"Clear Single shot");
    [_triggerModeControl setSelectedSegment:-1];

}


@end
