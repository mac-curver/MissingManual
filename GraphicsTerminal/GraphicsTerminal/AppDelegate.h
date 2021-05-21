//
//  AppDelegate.h
//  TestMacGraphics
//
//  Created by Heinz-Jörg on 07.09.20.
//  Copyright © 2020 LegoEsprit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Serialport.h"
#import "GraphicsTerminalView.h"




@interface AppDelegate : NSObject <NSApplicationDelegate, SerialDelegate>  {
    SerialportInterface *serialPort;
    NSGestureRecognizer *gesture;

}

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSPopUpButton *serialPortPopup;
@property (weak) IBOutlet NSComboBox *baudRate;
@property (weak) IBOutlet NSTextView *preferencesTextView;
@property (weak) IBOutlet GraphicsTerminalView *graphicsTerminalView;
@property (weak) IBOutlet NSWindow *settings;
@property (weak) IBOutlet NSSlider *slider0;
@property (weak) IBOutlet NSSlider *slider1;
@property (weak) IBOutlet NSSlider *slider2;
@property (weak) IBOutlet NSButton *connectButton;
@property (weak) IBOutlet NSPopUpButton *triggerChannel;
@property (weak) IBOutlet NSSegmentedControl *triggerPolarity;
@property (weak) IBOutlet NSSegmentedControl *triggerModeControl;


@property (unsafe_unretained) IBOutlet NSTextView *scrollTextView;



- (IBAction)changeSerialPort:(NSPopUpButton *)sender;
- (IBAction)changeBaudRate:(NSComboBox *)sender;
- (IBAction)connect:(NSButton *)sender;

- (IBAction)readLine:(NSButton *)sender;                                        // conforming to SerialDelegate

- (IBAction)changeTriggerChannel:(NSPopUpButton *)sender;
- (IBAction)changeTriggerMode:(NSSegmentedControl *)sender;
- (IBAction)changeTriggerPolarity:(NSSegmentedControl *)sender;

- (void)  clearSingleShot;



@end

