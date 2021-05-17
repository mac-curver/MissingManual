////  MyImageView.m//  Oscilloscope////  Created by Heinz-J�rg on Sun Jun 1 2003.//  Copyright (c) 2003 Heinz-J�rg SCHR�DER. All rights reserved.////	Version 1.30: 28.12.2004		all double replaced by float!#import		"TriggerTransformer.h"#import		"MyDocument.h"#import 	"ScientificImage.h"#import 	"ImageAxis.h"#import 	"HorizontalImageAxis.h"#import 	"VerticalImageAxis.h"#import		"MyImageView.h"#import		"msClock.h"#define		NO_SCALE		0			// 1 uses NSViewFrameDidChangeNotification to change size (very slow!)@implementation MyImageViewdouble			myTriggerLevel;double			yScale = 128;double			yOffset = 0;float			*triggerBuffer;#pragma mark --- Key bindings ---- (float)				yOffsetValue:(NSInteger)channel {	return -yOffsetArray[channel];}- (void)				setYOffsetValue:(float)newValue channel:(NSInteger)channel{	yOffsetArray[channel] = -newValue;	return;}- (float)				yScaleValue:(NSInteger)channel {	float		value =  -5.0*log(yScaleArray[channel])/log(10.0);	return		value;}- (void)				setYScaleValue:(float)newValue channel:(NSInteger)channel{	// y = 10 ^ (-x/5);	yScaleArray[channel] = pow(10, -newValue/5);	return;}#pragma mark --- Implementation ---+ (void)initialize{    static BOOL tooLate = NO;    if ( !tooLate ) {		        tooLate = YES;    }}- (id)initWithCoder:(NSCoder *)decoder{	self = [super initWithCoder:decoder];	if (self) {		// get values from default controller		NSUserDefaultsController		*myDefaultController = [NSUserDefaultsController sharedUserDefaultsController];				[self setYScaleValue:[[[myDefaultController values] valueForKey:@"myYScale1"] floatValue] channel:0];		[self setYScaleValue:[[[myDefaultController values] valueForKey:@"myYScale2"] floatValue] channel:1];		[self setYScaleValue:[[[myDefaultController values] valueForKey:@"myYScale3"] floatValue] channel:2];		[self setYScaleValue:[[[myDefaultController values] valueForKey:@"myYScale4"] floatValue] channel:3];		[self setYScaleValue:[[[myDefaultController values] valueForKey:@"myYScale5"] floatValue] channel:4];		[self setYScaleValue:[[[myDefaultController values] valueForKey:@"myYScale6"] floatValue] channel:5];		[self setYScaleValue:[[[myDefaultController values] valueForKey:@"myYScale7"] floatValue] channel:6];		[self setYScaleValue:[[[myDefaultController values] valueForKey:@"myYScale8"] floatValue] channel:7];				[self setYOffsetValue:[[[myDefaultController values] valueForKey:@"myOffset1"] floatValue] channel:0];		[self setYOffsetValue:[[[myDefaultController values] valueForKey:@"myOffset2"] floatValue] channel:1];		[self setYOffsetValue:[[[myDefaultController values] valueForKey:@"myOffset3"] floatValue] channel:2];		[self setYOffsetValue:[[[myDefaultController values] valueForKey:@"myOffset4"] floatValue] channel:3];		[self setYOffsetValue:[[[myDefaultController values] valueForKey:@"myOffset5"] floatValue] channel:4];		[self setYOffsetValue:[[[myDefaultController values] valueForKey:@"myOffset6"] floatValue] channel:5];		[self setYOffsetValue:[[[myDefaultController values] valueForKey:@"myOffset7"] floatValue] channel:6];		[self setYOffsetValue:[[[myDefaultController values] valueForKey:@"myOffset8"] floatValue] channel:7];		//[[myDefaultController defaults] setObject:[NSNumber numberWithFloat:-1.0] forKey:@"myYScale1"];	}		return self;}- (void)awakeFromNib{		initiated = NO;	[super awakeFromNib];				colorChannel[0] = [colorChannel0 color];	colorChannel[1] = [colorChannel1 color];	colorChannel[2] = [colorChannel2 color];	colorChannel[3] = [colorChannel3 color];	colorM[0]		= [colorM0 color];	colorM[1]		= [colorM1 color];	colorM[2]		= [colorM2 color];	colorM[3]		= [colorM3 color];	colorGrid       = [colorWellGrid color];	colorBckgnd     = [[colorWellBckgnd color] colorWithAlphaComponent:myAlpha];	[colorBckgnd		retain];	    xStart			= 0.0;	xStop			= pow(10, -[timingSlider doubleValue]/5);	triggerAutoMode	= NO;	triggerIndex	= 0;	triggerPolarity = 1;	#if	NO_SCALE	// is very slow	[self setImageScaling:NSScaleNone];	[self setImageAlignment:NSImageAlignBottomLeft];	[[NSNotificationCenter defaultCenter]	addObserver:self 											selector:@selector(sizeDidChange:)											name:@"NSViewFrameDidChangeNotification" object:nil];	//[self	setPostsBoundsChangedNotifications:YES];	[self	setPostsFrameChangedNotifications:YES];	#else	[self setImageScaling:NSScaleToFit];	//[self setImageScaling:NSScaleProportionally];#endif	[self sizeDidChange:nil];	[self changeRemanenz: remanenzPopUpButton];		}// this routine is called after the related documents are opened!- (void)	initFirstDisplay{	NSInteger		chnl;    NSButton		*curButton = nil;		for (chnl = 0; chnl < 4; chnl ++) {        curButton = [[NSButton alloc] init];		curButton.cell = [channelMatrix cellWithTag:chnl];		channelDisplay[chnl]   = [curButton state];		curButton.cell = [sumMatrix cellWithTag:chnl];		channelDisplay[chnl+4] = [curButton state];		[yOffsetMatrix selectCellWithTag:chnl];		[self changeOffsetMatrix:yOffsetMatrix];		/*		[yScaleMatrix selectCellWithTag:chnl];		[self changeScaleMatrix:yScaleMatrix];		*/	}	triggerBuffer = [myDocument channel:0];	[self changeTiming:timingSlider];	[self changeTriggerPosition:triggerPositionText];		[self changeTriggerLevel:triggerLevelText];	[self changeTriggerChannel:triggerMatrix];	[self changeShowGroundMarkers:showGroundMarkersButton];	repeatTimer = nil;	displayIsRunning = FALSE;				[self		changeTriggerMode:triggerMode];									// initialize triggerMode from nib file	initiated = YES;															// now we are allowed to draw	[self		updateDrawing];}/*- (void)drawRect:(NSRect)aRect //is not allowed!!!{	[self drawAnother:repeatTimer];}*/- (Boolean)	nextTrigger{					enum {WAIT_FOR_LOW, WAIT_FOR_HIGH, TRIGGERRED};	NSUInteger        x1 = 0, x2;	NSUInteger		newTriggerIndex = triggerIndex;								// take old trigger position	NSUInteger		myLength = [myDocument length:0];	enum			{waitForLow, waitForHigh, triggered};	enum			{autoTrigger, normalTrigger, singleTrigger};	enum			{edgeHighLow, edgeLowHigh, smart};	//static NSInteger		triggerFormat = edgeLowHigh;	//static NSInteger		triggerMode = autoTrigger;	float			y1, y2;	Boolean			triggerFound = FALSE;	NSUInteger		triggerState = WAIT_FOR_LOW;	NSUInteger		xWidth = xStop-xStart;		if (triggerBuffer) {																// check if buffer is not empty		newTriggerIndex += xWidth;		// wait for 1st event (wait for low)		xStart = 0;		for (x1 = newTriggerIndex; x1 < newTriggerIndex+4*xWidth; x1++) {			y1 = triggerBuffer[x1 % myLength];			if (0 > triggerPolarity*(y1 - myTriggerLevel)) {				triggerState = WAIT_FOR_HIGH;				break;			}		}		// wait for 2nd event (wait for high)		for (x2 = x1 ; x2 < newTriggerIndex+4*xWidth; x2++) {			y2 = triggerBuffer[x2 % myLength];			if (0 < triggerPolarity*(y2 - myTriggerLevel)) {				x1 = (x2 + (myLength-1)) % myLength;				y1 = triggerBuffer[x1];				if (fabs(y2 - y1) > 1E-7) {					xFineStart = (myTriggerLevel-y1) / (y1 - y2);				} else {					xFineStart = 0;				}				newTriggerIndex = x1;				triggerIndex = newTriggerIndex;				triggerFound = TRUE;				[retriggerButton	setState:NSOffState];				break;			}		}	}	if (triggerAutoMode && !triggerFound) {		triggerIndex += xWidth;		triggerIndex %= myLength;		triggerFound = YES;	}	return triggerFound;}- (void)				updateDrawing{	if (initiated) {		[self drawFloatBufferTriggered:YES];	}}- (void)				drawFloatBufferTriggered:(Boolean)isTriggered{	NSUInteger		chnl;	NSUInteger		myLength;	enum			{waitForLow, waitForHigh, triggered};	enum			{autoTrigger, normalTrigger, singleTrigger};	enum			{edgeHighLow, edgeLowHigh, smart};	float			*myBuffer;		displayIsRunning = YES;	myLength  = [myDocument shortestLength];	[self lineWidth:0.5];		msClockReset();	if (isTriggered) {		myDensity = [densityText doubleValue];		[currentImage	lockFocus];												// Draw on the new Image.				[colorBckgnd set];//[[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:myAlpha] set];		 //light background		NSRectFillUsingOperation([self bounds], NSCompositePlusLighter);		[self penup];		for (chnl = 0; chnl < 8; chnl++) {			if (channelDisplay[chnl]) {				[colorChannel[chnl] set];				[self		windowFromX:xStart ToX:xStop 							AndFromY:yScaleArray[chnl]*(yOffsetArray[chnl]-1) 							ToY:yScaleArray[chnl]*(yOffsetArray[chnl]+1)];				[self		choosePrimaryNew];				myBuffer = [myDocument channel:chnl];				[self plotData:myBuffer startIndex:triggerIndex-triggerPosition length:myLength from:xFineStart to:xStop+xFineStart];								if (showGroundMarkers) {					[self moveto:xStart :0];					[self drawTriangleSymbol:3];					[self moveto:xStop :0];					[self drawTriangleSymbol:1];				}			}					}		[currentImage unlockFocus];												// Have to balance the -lockFocus/-unlockFocus calls.	}#if	NO_SCALE	NSImage	*bkgImage = [[NSImage alloc] initWithSize:[self bounds].size];		//  background picture, the same size as this one#else	NSImage	*bkgImage = [[NSImage alloc] initWithSize:mySize];					//  background picture, the same size as this one#endif		[bkgImage lockFocus];														// -lockFocus	[gridImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy]; 	myCompositeMode = [compositeModeText intValue];	[currentImage compositeToPoint:NSZeroPoint operation:myCompositeMode];		if (channelDisplay[triggerChannel]) {		[self		windowFromX:xStart ToX:xStop 					AndFromY:yScaleArray[triggerChannel]*(yOffsetArray[triggerChannel]-1) 					ToY:     yScaleArray[triggerChannel]*(yOffsetArray[triggerChannel]+1)];		[self		choosePrimaryNew];		[self lineWidth:1.2];		[[NSColor redColor] set];		[self penup];		[self plotto:xStart		:myTriggerLevel];		[self plotto:xStop		:myTriggerLevel];	}	[bkgImage	unlockFocus];													// Have to balance the -lockFocus/-unlockFocus calls.	[bkgImage	autorelease];													// Always balance the -retain/-release calls.	[self		setImage:bkgImage];	//overPrint ++;	[test setIntegerValue:msClock()];	displayIsRunning = NO;}- (void)				enableChannel:(NSInteger)channel enabled:(Boolean)enabled{	// Attention the 4 channels are numbered from 0...3		NSButton *currentButton = (NSButton*)[channelMatrix  cellWithTag:channel];	[currentButton setEnabled:enabled];	if (!enabled) {		[currentButton setState:NSOffState];	}}- (void)		drawAxis{    // we are plotting a coordinate system taking the xScale from application and using the secondary axix	// to plot +/-5 vertical divisions	float			gridLineWidth = 0.5;	[gridImage	lockFocus];														// Draw on the new Image.	[self		secondaryFromX:xStart ToX:xStop AndFromY:-5 ToY:5];    [self		chooseSecondaryNew];#if	NO_SCALE	NSRectFillUsingOperation([self bounds], NSCompositeClear);#else	NSRectFillUsingOperation(NSMakeRect(0.0 , 0.0, mySize.width, mySize.height), NSCompositeClear);#endif	    [horizontalAxis	setGridRect:&windowRect];    [secondaryAxis	setGridRect:&windowRect];                [colorGrid set];    // draw x and y axis for primary plot    [horizontalAxis	linTics:windowRect.origin.y separation:0.0 ticPercent:200 andMajorEvery:10 lineWidth:gridLineWidth];     [secondaryAxis	linTics:windowRect.origin.x separation:1.0 ticPercent:200 andMajorEvery: 5 lineWidth:gridLineWidth];	[self		choosePrimaryNew];	[gridImage	unlockFocus];													//  Have to balance the -lockFocus/-unlockFocus calls.                            }- (void)        setTimerRunning:(BOOL)run{    // Test if repeatTimer does not exists, but it should then creates a new timer instance	if ((nil == repeatTimer) && run) {        repeatTimer = [[NSTimer scheduledTimerWithTimeInterval:0.0                            target:self                            selector:@selector(drawAnother:)                            userInfo:nil                            repeats:YES            	      ] retain];    } else if ((nil != repeatTimer)  && !run) {		// remove timer instance when we stopped        [repeatTimer invalidate];        [repeatTimer release];        repeatTimer = nil;    }}// as responder to NSViewFrameDidChangeNotification- (void)				sizeDidChange:(NSNotification *)notification{	mySize = [self bounds].size;		[self setViewRectToBounds];	if (currentImage) {		[currentImage	release];	}	currentImage	= [[NSImage alloc] initWithSize:mySize];	//  actual image	[currentImage	retain];		if (gridImage) {		[gridImage		release];	}	gridImage		= [[NSImage alloc] initWithSize:mySize];	//  image from grid	[gridImage		retain];	[self			drawAxis];}#pragma mark --- IBAction ---- (IBAction)    drawHistogram:(id)sender{    double          value = 0;	NSUInteger		myLength;	char			*zeroes;	NSInteger				i;	double			lastZeroPos, zeroPos = 0, rll;		NSInteger				lastPositive, positive;	//char			*topRLL, *bottomRLL;	//NSInteger				*topCount, *bottomCount;	//double			T = 64.0/11.0;												// T period in 	float			*myBuffer;	NSUInteger		oneRowCount;		[self		setTimerRunning:NO];	if ([[self window] isVisible]) {											// can not access document anymore if closed!		myBuffer = [myDocument channel:0];		if (myBuffer) {															// check if budffer is not empty						myLength  = 200; //[myDocument length];			zeroes = malloc(myLength);			zeroes[0] = 0; 			lastPositive = myBuffer[0] >= 0;			lastZeroPos = 0;			for (i = 1; i < myLength; i++) {				positive = myBuffer[i] >= 0;				if (positive) {					if (!lastPositive) {						zeroPos = i-myBuffer[i]/(myBuffer[i+1]-myBuffer[i]);						rll = zeroPos - lastZeroPos;						lastZeroPos = zeroPos;					}				} else {					if (lastPositive) {						zeroPos = i-myBuffer[i]/(myBuffer[i+1]-myBuffer[i]);						rll = zeroPos - lastZeroPos;						lastZeroPos = zeroPos;					}				}				lastPositive = positive;				zeroes[i] = zeroPos;			}			[currentImage	lockFocus];											// Draw on the new Image.			[self lineWidth:0.5];						[self penup];			for (oneRowCount = 0; oneRowCount < myLength; oneRowCount++) {				value = zeroes[oneRowCount];				[self plotto:oneRowCount	:value];				[self plotto:oneRowCount+1  :value];			}			[currentImage unlockFocus];											//  Have to balance the -lockFocus/-unlockFocus calls.			free(zeroes); 						}	}}- (IBAction)			changeStart:(id)sender{	if ([sender intValue]) {		[self setTimerRunning:YES];	} else {		[self setTimerRunning:NO];	}}- (void)    drawAnother:(id)timer{	if ([[self window] isVisible] && !displayIsRunning) {						// can not access document anymore if closed!		Boolean	triggered = [self nextTrigger];		[self drawFloatBufferTriggered:triggered];	}}- (IBAction)			doTrigger:(id)sender{	Boolean triggered =  [self nextTrigger];	[self drawFloatBufferTriggered:triggered];}- (IBAction)			changeRisingEdge:(id)sender{	if ([sender intValue]) {		triggerPolarity = -1;	} else {		triggerPolarity = 1;	}}- (IBAction)			changeTriggerChannel:(id)sender{	NSButton			*triggerButton = [sender selectedCell];	triggerChannel = [triggerButton tag];	triggerBuffer  = [myDocument channel:triggerChannel];}- (IBAction)			changeTriggerLevel:(id)sender{	myTriggerLevel = [sender doubleValue];	[self		doTrigger:self];}- (IBAction)			changeTriggerPosition:(id)sender{	double				relativPosition;	triggerPosition = [sender intValue];	relativPosition = triggerPosition/(xStop-xStart);	[triggerPositionSlider	setDoubleValue:relativPosition];	[self		updateDrawing];}- (IBAction)			changeTriggerPositionRelative:(id)sender{	triggerPosition = [sender doubleValue]*(xStop-xStart);	[triggerPositionText	setIntValue:triggerPosition];	[triggerPositionStepper setIntValue:triggerPosition];}- (IBAction)			changeTriggerMode:(id)sender{	enum {AUTO, NORMAL, SINGLE, SPECIAL};		switch ([sender indexOfSelectedItem]) {		case AUTO:			triggerAutoMode = YES;			[self		setTimerRunning:YES];			break;		case NORMAL:			triggerAutoMode = NO;			[self		setTimerRunning:YES];			break;		case SINGLE:			triggerAutoMode = NO;			[self		setTimerRunning:NO];			break;		case SPECIAL:			triggerAutoMode = NO;			[self		setTimerRunning:NO];			break;	}}- (IBAction)			changeTiming:(id)sender{	double				relativPosition;		xStop = floor(pow(10, -[sender doubleValue]/5));	[self		windowFromX:xStart ToX:xStop AndFromY:yScale*(yOffset-1) ToY:yScale*(yOffset+1)];	[self		drawAxis];	relativPosition = triggerPosition/(xStop-xStart);	[triggerPositionSlider	setDoubleValue:relativPosition];	[self		updateDrawing];}- (IBAction)			changeOffsetMatrix:(id)sender{	//NSControl			*currentControl = [sender selectedCell];	//NSInteger					myChannel		= [currentControl tag];	//yOffsetArray[myChannel]				= -[currentControl floatValue];	[self		updateDrawing];}- (IBAction)			changeScaleMatrix:(id)sender{	[self		updateDrawing];}- (IBAction)			changeChannel:(id)sender{	NSButton			*currentButton = [sender selectedCell];	NSInteger					currentTag     = [currentButton tag];		channelDisplay[currentTag] = [currentButton state];	[self		updateDrawing];}- (IBAction)			changeSum:(id)sender{	NSButton			*currentButton = [sender selectedCell];	NSInteger					currentTag     = [currentButton tag];		channelDisplay[currentTag+4] = [currentButton state];	[self		updateDrawing];}- (IBAction)			changeRemanenz:(id)sender{	switch ([sender indexOfSelectedItem]) {		case 0:			myAlpha = 1;			break;		case 1:			myAlpha = 0.5;			break;		case 2:			myAlpha = 0.25;			break;		case 3:			myAlpha = 0.128;			break;		case 4:			myAlpha = 0.064;			break;		case 5:			myAlpha = 0.032;			break;		case 6:			myAlpha = 0.016;			break;		case 7:			myAlpha = 0.008;			break;		case 8:			myAlpha = 0.004;			break;		case 9:			myAlpha = 0.002;			break;		case 10:			myAlpha = 0;			break;	}	NSColor	*myColorBckgnd = colorBckgnd;	colorBckgnd = [myColorBckgnd colorWithAlphaComponent:myAlpha];	[myColorBckgnd		release];	[colorBckgnd		retain];}- (IBAction)			changeShowGroundMarkers:(id)sender{	showGroundMarkers = (NSOnState == [sender state]);}- (IBAction)			colorChannel0:(id)sender{	colorChannel[0] = [sender color];	[self		updateDrawing];}- (IBAction)			colorChannel1:(id)sender{	colorChannel[1] = [sender color];	[self		updateDrawing];}- (IBAction)			colorChannel2:(id)sender{	colorChannel[2] = [sender color];	[self		updateDrawing];}- (IBAction)			colorChannel3:(id)sender{	colorChannel[3] = [sender color];	[self		updateDrawing];}- (IBAction)			colorM0:(id)sender{	colorM[0] = [sender color];	[self		updateDrawing];}- (IBAction)			colorM1:(id)sender{	colorM[1] = [sender color];	[self		updateDrawing];}- (IBAction)			colorM2:(id)sender{	colorM[2] = [sender color];	[self		updateDrawing];}- (IBAction)			colorM3:(id)sender{	colorM[3] = [sender color];	[self		updateDrawing];}- (IBAction)			colorGrid:(id)sender{	colorGrid = [sender color];	[self		windowFromX:xStart ToX:xStop AndFromY:yScale*(yOffset-1) ToY:yScale*(yOffset+1)];	[self		drawAxis];	[self		updateDrawing];}- (IBAction)			colorBckgnd:(id)sender{	if (nil != colorBckgnd) {		[colorBckgnd	release];	}	colorBckgnd = [[sender color] colorWithAlphaComponent:myAlpha];	[colorBckgnd	retain];	[self		windowFromX:xStart ToX:xStop AndFromY:yScale*(yOffset-1) ToY:yScale*(yOffset+1)];	[self		drawAxis];	[self		updateDrawing];}- (IBAction)			colorCursor:(id)sender{	colorCursor = [sender color];	[self		updateDrawing];}- (IBAction)			colorSpecial:(id)sender{	colorSpecial = [sender color];	[self		updateDrawing];}- (IBAction)			toggleDrawer:(id)sender{	NSButtonCell	*myButton  = [sender selectedCell];	NSInteger				buttonTag  = [myButton tag];	NSDrawer		*toBeClosed, *toBeToggled;		[[sender cellWithTag:1-buttonTag]	setState:NSOffState];					// the other button	switch(buttonTag) {		case 1:			toBeToggled = parameterDrawer;			toBeClosed = colorDrawer;			break;		default:			toBeClosed = parameterDrawer;			toBeToggled = colorDrawer;			break;	}	[toBeClosed		close];	[toBeToggled	toggle:myButton];}#pragma mark --- Clean up ---- (void)			dealloc{	static	BOOL isDeallocated = FALSE;// is release twice due to [self setTimerRunning:NO]		if (!isDeallocated) {			isDeallocated = TRUE;		[self setTimerRunning:NO];						[currentImage	release];		[gridImage		release];		[colorBckgnd	release];		[super dealloc];	}}@end