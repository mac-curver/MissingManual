/* myPreferences */

#import <Cocoa/Cocoa.h>

@class	MyDocument;

@interface myPreferences : NSWindow
{
    IBOutlet NSColorWell	*bckgndColor;
    IBOutlet NSColorWell	*ch1Color;
    IBOutlet NSColorWell	*ch2Color;
    IBOutlet NSColorWell	*ch3Color;
    IBOutlet NSColorWell	*ch4Color;
    IBOutlet NSColorWell	*ch5Color;
    IBOutlet NSColorWell	*ch6Color;
    IBOutlet NSColorWell	*ch7Color;
    IBOutlet NSColorWell	*ch8Color;
    IBOutlet NSColorWell	*cursorColor;
    IBOutlet NSColorWell	*gridColor;
    IBOutlet NSColorWell	*specialColor;
    IBOutlet NSPopUpButton	*math1Arg1;
    IBOutlet NSPopUpButton	*math1Arg2;
    IBOutlet NSPopUpButton	*math1Function;
    IBOutlet NSPopUpButton	*math2Arg1;
    IBOutlet NSPopUpButton	*math2Arg2;
    IBOutlet NSPopUpButton	*math2Function;
    IBOutlet NSPopUpButton	*math3Arg1;
    IBOutlet NSPopUpButton	*math3Arg2;
    IBOutlet NSPopUpButton	*math3Function;
    IBOutlet NSPopUpButton	*math4Arg1;
    IBOutlet NSPopUpButton	*math4Arg2;
    IBOutlet NSPopUpButton	*math4Function;
    IBOutlet NSMatrix		*offset;
    IBOutlet NSMatrix		*scale;
    IBOutlet NSMatrix		*selected;
    IBOutlet NSTextField	*timingPosition;
    IBOutlet NSPopUpButton	*triggerChannel;
    IBOutlet NSButton		*triggerEdge;
    IBOutlet NSTextField	*triggerLevel;
    IBOutlet NSPopUpButton	*triggerMode;
    IBOutlet NSTextField	*triggerPosition;
    IBOutlet NSPopUpButton	*remanenz;
    IBOutlet NSButton		*whiteOnBlack;
    IBOutlet NSButton		*ShowGndMarker;
	
    IBOutlet NSButton		*GetValuesFromWindow;
	
	MyDocument				*currentDocument;
}

- (IBAction)	getPreferencesFromWindow:(id)sender;
- (IBAction)	setFactoryDefaults:(id)sender;

@end
