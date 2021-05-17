#import		"AudioApplication.h"
#import 	"ScientificImage.h"
#import		"MyImageView.h"
#import		"MyDocument.h"

#import		"myPreferences.h"

@implementation myPreferences

#pragma mark --- overwriting standard methods ---


+ (void) initialize
{
	// get values from default controller
	NSUserDefaultsController	*myDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	int							i;
	NSMutableDictionary			*myInitialValues;

	myInitialValues = [NSMutableDictionary dictionaryWithCapacity:30];
	for (i = 0; i < 8; i++) {
		char charValue = '1' + i;
		[myInitialValues setValue:[NSNumber numberWithDouble:0.0] forKey:[NSString stringWithFormat:@"myOffset%c", charValue]];
		[myInitialValues setValue:[NSNumber numberWithDouble:1.0] forKey:[NSString stringWithFormat:@"myYScale%c", charValue]];
		[myInitialValues setValue:[NSNumber numberWithBool:(0 == i)] forKey:[NSString stringWithFormat:@"chSelect%c", charValue]];
	}
		
	[myInitialValues setValue:[NSArchiver archivedDataWithRootObject:[NSColor brownColor]]	forKey:@"chColor1"];
	[myInitialValues setValue:[NSArchiver archivedDataWithRootObject:[NSColor redColor]]	forKey:@"chColor2"];
	[myInitialValues setValue:[NSArchiver archivedDataWithRootObject:[NSColor orangeColor]] forKey:@"chColor3"];
	[myInitialValues setValue:[NSArchiver archivedDataWithRootObject:[NSColor yellowColor]] forKey:@"chColor4"];
	[myInitialValues setValue:[NSArchiver archivedDataWithRootObject:[NSColor greenColor]]	forKey:@"chColor5"];
	[myInitialValues setValue:[NSArchiver archivedDataWithRootObject:[NSColor blueColor]]	forKey:@"chColor6"];
	[myInitialValues setValue:[NSArchiver archivedDataWithRootObject:[NSColor purpleColor]] forKey:@"chColor7"];
	[myInitialValues setValue:[NSArchiver archivedDataWithRootObject:[NSColor darkGrayColor]] forKey:@"chColor8"];
		
	[myInitialValues setValue:[NSNumber numberWithBool:FALSE] forKey:@"showGndMarker"];
	[myInitialValues setValue:[NSNumber numberWithBool:FALSE] forKey:@"whiteOnBlack"];

	[myInitialValues setValue:[NSArchiver archivedDataWithRootObject:[NSColor purpleColor]] forKey:@"gridColor"];
	[myInitialValues setValue:[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]]	forKey:@"bkgColor"];
	[myInitialValues setValue:[NSArchiver archivedDataWithRootObject:[NSColor greenColor]]	forKey:@"cursorColor"];
	[myInitialValues setValue:[NSArchiver archivedDataWithRootObject:[NSColor magentaColor]] forKey:@"specialColor"];
	
	[myInitialValues setValue:[NSNumber numberWithInt:0]		forKey:@"triggerChannel"];
	[myInitialValues setValue:[NSNumber numberWithDouble:0.0]	forKey:@"triggerLevel"];
	[myInitialValues setValue:[NSNumber numberWithDouble:0.0]	forKey:@"triggerPosition"];
	[myInitialValues setValue:[NSNumber numberWithBool:FALSE]	forKey:@"triggerPolarity"];
	[myInitialValues setValue:[NSNumber numberWithInt:0]		forKey:@"triggerMode"];
	[myInitialValues setValue:[NSNumber numberWithDouble:-13]	forKey:@"timing"];
	[myInitialValues setValue:[NSNumber numberWithInt:5]		forKey:@"remanenz"];
	
	[myDefaultsController setInitialValues:myInitialValues];
}



- (void)awakeFromNib
{
	currentDocument = nil;
}



- (void)	makeKeyAndOrderFront:(id)sender
{
	NSWindow			*myWin = [AudioApplication getLastFrontWindow];
	NSWindowController	*myWndCtr = [myWin windowController];

	currentDocument = [myWndCtr document];
	[GetValuesFromWindow setEnabled:(currentDocument && [currentDocument  myType])];
	
	[super makeKeyAndOrderFront:sender];
}

#pragma mark --- my own methods ---



- (IBAction)	getPreferencesFromWindow:(id)sender
{
	MyImageView					*currentImageView;
	
	[bckgndColor setColor:[NSColor blackColor]];
	[[offset cellWithTag:0] setFloatValue:[currentDocument  myOffset1]];
	[[offset cellWithTag:1] setFloatValue:[currentDocument  myOffset2]];
	[[offset cellWithTag:2] setFloatValue:[currentDocument  myOffset3]];
	[[offset cellWithTag:3] setFloatValue:[currentDocument  myOffset4]];
	[[offset cellWithTag:4] setFloatValue:[currentDocument  myOffset5]];
	[[offset cellWithTag:5] setFloatValue:[currentDocument  myOffset6]];
	[[offset cellWithTag:6] setFloatValue:[currentDocument  myOffset7]];
	[[offset cellWithTag:7] setFloatValue:[currentDocument  myOffset8]];

	[[scale cellWithTag:0] setFloatValue:[currentDocument  myYScale1]];
	[[scale cellWithTag:1] setFloatValue:[currentDocument  myYScale2]];
	[[scale cellWithTag:2] setFloatValue:[currentDocument  myYScale3]];
	[[scale cellWithTag:3] setFloatValue:[currentDocument  myYScale4]];
	[[scale cellWithTag:4] setFloatValue:[currentDocument  myYScale5]];
	[[scale cellWithTag:5] setFloatValue:[currentDocument  myYScale6]];
	[[scale cellWithTag:6] setFloatValue:[currentDocument  myYScale7]];
	[[scale cellWithTag:7] setFloatValue:[currentDocument  myYScale8]];
	
	currentImageView = [currentDocument originalImageView];
	[timingPosition			setDoubleValue:		[currentImageView  timingValue]];
	[triggerChannel			selectItemAtIndex:	[currentImageView  triggerChannel]];
	[triggerEdge			setState:			[currentImageView  triggerPolarity]];
	[triggerLevel			setDoubleValue:		[currentImageView  triggerLevel]];
	[triggerMode			selectItemAtIndex:	[currentImageView  triggerMode]];
	[triggerPosition		setIntegerValue:	[currentImageView  triggerPosition]];
	[remanenz				selectItemAtIndex:	[currentImageView  remanenzValue]];


	
	
/*
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
*/


}


- (IBAction)	setFactoryDefaults:(id)sender
{
	NSUserDefaultsController	*myDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	
	[myDefaultsController revertToInitialValues:sender];
}


@end
