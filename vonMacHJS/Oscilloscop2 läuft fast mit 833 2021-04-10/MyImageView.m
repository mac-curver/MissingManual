//
//  MyImageView.m
//  Oscilloscope
//
//  Created by Heinz-J�rg on Sun Jun 1 2003.
//  Copyright (c) 2003 Heinz-J�rg SCHR�DER. All rights reserved.
//
//	Version 1.30: 28.12.2004		all double replaced by float!

#import		"TriggerTransformer.h"
#import		"MyDocument.h"
#import 	"ScientificImage.h"
#import 	"ImageAxis.h"
#import 	"HorizontalImageAxis.h"
#import 	"VerticalImageAxis.h"
#import		"AudioInput.h"
#import		"MyImageView.h"


@implementation MyImageView


double			yScale = 128;
double			yOffset = 0;

enum			{waitSpecial, waitSignal, waitForLow, waitForHigh, triggered};
unsigned		triggerState;



#pragma mark --- Key bindings ---




- (float)				yOffsetValue:(NSInteger)channel 
{
	return -yOffsetArray[channel];
}

- (void)				setYOffsetValue:(float)newValue channel:(NSInteger)channel
{
	yOffsetArray[channel] = -newValue;
	return;
}

- (float)				yScaleValue:(NSInteger)channel
{
	float		value =  -5.0*log(yScaleArray[channel])/log(10.0);
	return		value;
}

- (void)				setYScaleValue:(float)newValue channel:(NSInteger)channel
{
	// y = 10 ^ (-x/5);
	yScaleArray[channel] = pow(10, -newValue/5);
	return;
}





#pragma mark --- Implementation ---

+ (void)initialize
{
    static BOOL tooLate = NO;
    if ( !tooLate ) {		
        tooLate		= YES;
    }
}



- (NSNumber *) initializeDefaultKey:(id)key withDefault:(NSNumber *)defaultValue
{
	NSUserDefaults	*defaults		= [NSUserDefaults standardUserDefaults];
	NSNumber		*newNumber;
	
	newNumber	  = (NSNumber *)[defaults objectForKey:key];
	if (nil == newNumber) {
		newNumber = defaultValue;
	}
	[newNumber retain];
	return	newNumber;
}

- (NSColor *) initializeDefaultKey:(id)key withColor:(NSColor *)defaultColor
{
	NSUserDefaults	*defaults		= [NSUserDefaults standardUserDefaults];
	NSColor			*newColor		= nil;
	NSData			*newData;
	
	newData = [defaults objectForKey:key];
	if (nil != newData) {
		newColor	  = [NSUnarchiver unarchiveObjectWithData:newData];
	}
	if (nil == newColor) {
		newColor = defaultColor;
	}
	[newColor retain];
	return	newColor;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	
	self = [super initWithCoder:decoder];
	if (self) {
		NSInteger				channel;
		NSNumber		*defaultNumber;
		
		for (channel = 0; channel < 8; channel++) {
			char charValue = '1' + channel;
			defaultNumber = [self initializeDefaultKey:[NSString stringWithFormat:@"myOffset%c", charValue] withDefault:[NSNumber numberWithDouble:0.0]];
			[self setYOffsetValue:[defaultNumber doubleValue] channel:channel];
			
			defaultNumber = [self initializeDefaultKey:[NSString stringWithFormat:@"myYScale%c", charValue] withDefault:[NSNumber numberWithDouble:1.0]];
			[self setYScaleValue:[defaultNumber doubleValue] channel:channel];
			
			defaultNumber = [self initializeDefaultKey:[NSString stringWithFormat:@"chSelect%c", charValue] withDefault:[NSNumber numberWithBool:FALSE]];
			[self enableChannel:channel enabled:[defaultNumber boolValue] && (nil != [myDocument channel:channel])];
			
		}
		defaultNumber	= [self initializeDefaultKey:@"triggerChannel"  withDefault:[NSNumber numberWithDouble:0.0]];
		triggerPosition = [defaultNumber	doubleValue];
		defaultNumber	= [self initializeDefaultKey:@"triggerPosition" withDefault:[NSNumber numberWithInt:0]];
		triggerChannel	= [defaultNumber	intValue];
		defaultNumber	= [self initializeDefaultKey:@"triggerPolarity"	withDefault:[NSNumber numberWithBool:FALSE]];
		triggerPolarity	= [defaultNumber	boolValue];
		defaultNumber	= [self initializeDefaultKey:@"triggerLevel"	withDefault:[NSNumber numberWithDouble:0.0]];
		triggerLevel	= [defaultNumber	doubleValue];
		//[defCntValue setValue:[NSNumber numberWithInt:0]		forKey:@"triggerMode"];
		defaultNumber	= [self initializeDefaultKey:@"timing"			withDefault:[NSNumber numberWithDouble:0.0]];
		timingValue		= [defaultNumber	doubleValue];
		defaultNumber	= [self initializeDefaultKey:@"remanenz"		withDefault:[NSNumber numberWithInt:0]];
		remanenzValue	= [defaultNumber	intValue];
		//Boolean						showGroundMarkers;			// add small trinagles to indicate ground level
		//Boolean						inverseDisplay;				// true if display is white on black
	
		colorChannel[0] = [self initializeDefaultKey:@"chColor1"			withColor:[NSColor magentaColor]];
		colorChannel[1] = [self initializeDefaultKey:@"chColor2"			withColor:[NSColor redColor]];
		colorChannel[2] = [self initializeDefaultKey:@"chColor3"			withColor:[NSColor orangeColor]];
		colorChannel[3] = [self initializeDefaultKey:@"chColor4"			withColor:[NSColor yellowColor]];
		colorM[0]		= [self initializeDefaultKey:@"chColor5"			withColor:[NSColor greenColor]];
		colorM[1]		= [self initializeDefaultKey:@"chColor6"			withColor:[NSColor blueColor]];
		colorM[2]		= [self initializeDefaultKey:@"chColor7"			withColor:[NSColor purpleColor]];
		colorM[3]		= [self initializeDefaultKey:@"chColor8"			withColor:[NSColor darkGrayColor]];
		colorCursor		= [self initializeDefaultKey:@"myCursorColor"		withColor:[NSColor redColor]];
		colorGrid		= [self initializeDefaultKey:@"myGridColor"			withColor:[NSColor greenColor]];
		colorBckgnd		= [self initializeDefaultKey:@"myBackgroundColor"	withColor:[NSColor whiteColor]];
		//NSColor						*colorSpecial;


												
		grabber		= nil;
		center.x	= 50.0;
		center.y	= 250.0;
		speed.x		= 12;
		speed.y		= 0;
		radius		= 10.0;
	}
	
	return self;
}



- (void)awakeFromNib
{		
	[super awakeFromNib];
			
	firstScreen			= TRUE;

    xStart				= 0.0;
	xStop				= pow(10, -[timingSlider doubleValue]/5);
	triggerAutoMode		= NO;
	triggerIndex		= 0;
	triggerPolarity		= 1;
	triggerStartState	= waitForLow;
	
	[self	setTimingValue:timingValue];
	[self	setRemanenzValue:remanenzValue];
	
	//[self setImageScaling:(1? NSScaleNone: NSScaleToFit)];
	[self	sizeDidChange:nil];

	[[NSNotificationCenter defaultCenter]	addObserver:self 
											selector:@selector(sizeDidChange:)
											name:@"NSViewFrameDidChangeNotification" object:nil];
											
											
	//[self	setPostsBoundsChangedNotifications:YES];
	//[self	setPostsFrameChangedNotifications:YES];	
}


// this routine is called after the related documents are opened!
- (void)	initFirstDisplay
{
	NSInteger				chnl;
	NSButtonCell		   *curButton;
	
	for (chnl = 0; chnl < 4; chnl ++) {
		curButton = [channelMatrix cellWithTag:chnl];
		channelDisplay[chnl]   = [curButton state];
		curButton = [sumMatrix cellWithTag:chnl];
		channelDisplay[chnl+4] = [curButton state];
	}
	for (chnl = 0; chnl < 8; chnl++) {
		//[self setYScaleValue: [[yScaleMatrix  cellWithTag:chnl] floatValue] channel:chnl];
		//[self setYOffsetValue:[[yOffsetMatrix cellWithTag:chnl] floatValue] channel:chnl];
		[yOffsetMatrix selectCellWithTag:chnl];
		[self changeOffsetMatrix:yOffsetMatrix];
		[yScaleMatrix selectCellWithTag:chnl];
		[self changeScaleMatrix:yScaleMatrix];
	}
	triggerBuffer = [myDocument channel:0];
	triggerBufferLength = [myDocument length:0];
	/*
	[self changeTiming:timingSlider];
	[self changeTriggerPosition:triggerPositionText];
	
	[self changeTriggerLevel:triggerLevelText];
	[self changeTriggerChannel:triggerMatrix];
	[self changeShowGroundMarkers:showGroundMarkersButton];
	*/

	repeatTimer = nil;
			

	[self setTriggerMode:[triggerModeButton indexOfSelectedItem]];				// initialize triggerMode from nib file
}


- (void)				setGrabber:(id)sender
{
	grabber		= sender;
}



- (void)drawRect:(NSRect)aRect													//is not allowed!!!
{
	NSRect			dotRect;
	
	NSWindow			*myWin;
	NSWindowController	*myWndCtr;
	NSDocument			*myDoc;
	
	myWin		= [self window];
	myWndCtr	= [myWin windowController];
	myDoc		= [myWndCtr document];
	
	
	if (inverseDisplay) {
	} else {
	}
    

    [gridImage drawAtPoint:NSZeroPoint fromRect:aRect operation:NSCompositingOperationCopy fraction:1.0];
    if (inverseDisplay) {
        [currentImage drawAtPoint:NSZeroPoint fromRect:aRect operation:NSCompositingOperationPlusLighter fraction:1.0];
	} else {
        [currentImage drawAtPoint:NSZeroPoint fromRect:aRect operation:NSCompositingOperationPlusDarker fraction:1.0];
	}

    
	
	
	if (channelDisplay[triggerChannel]) {
		[self		windowFromX:xStart ToX:xStop 
					AndFromY:yScaleArray[triggerChannel]*(yOffsetArray[triggerChannel]-1) 
					ToY:     yScaleArray[triggerChannel]*(yOffsetArray[triggerChannel]+1)];
		[self		choosePrimary];
		[self lineWidth:1.2];
		[colorCursor set];
		[self penup];
		[self plotto:xStart		:triggerLevel];
		[self plotto:xStop		:triggerLevel];
	}
	
	dotRect.origin.x	= center.x - radius;
    dotRect.origin.y	= center.y - radius;
    dotRect.size.width	= 2 * radius;
    dotRect.size.height	= 2 * radius;
	[colorCursor set];

    [[NSBezierPath bezierPathWithOvalInRect:dotRect] fill];
	
	//[test setIntValue:msClock()];
}


- (void)	nextTrigger
{
	unsigned long   x1 = 0;
	unsigned long	newTriggerIndex = triggerIndex;								// take old trigger position
	float			y1, y2;
	unsigned		xWidth = xStop-xStart;
	
	if (triggerBuffer) {														// check if buffer is not empty
		// wait for 1st event (wait for low)
		xStart = 0;
		for (x1 = newTriggerIndex; x1 < newTriggerIndex+4*xWidth; x1++) {
			y1 = triggerBuffer[x1 % triggerBufferLength];
			switch (triggerState) {
				case waitForHigh: 
					y2 = triggerBuffer[(x1+1) % triggerBufferLength];
					if (0 < triggerPolarity*(y2 - triggerLevel)) {
						y1 = triggerBuffer[x1 % triggerBufferLength];
						if (fabs(y2 - y1) > 1E-7) {
							xFineStart = (triggerLevel-y1) / (y1 - y2);
						} else {
							xFineStart = 0;
						}
						newTriggerIndex = x1;
						triggerIndex = newTriggerIndex;
						triggerState = triggered;
						[retriggerButton	setState:NSOffState];
						goto triggered;
					}
					break;
				case waitSpecial: 
					break;
				case waitSignal: 
					break;
					
				default:
					if (0 > triggerPolarity*(y1 - triggerLevel)) {
						triggerState = waitForHigh;
					}
					break;
			}
		}
	}
triggered:
	if ((triggered==triggerState) || triggerAutoMode) {
		//msClockReset();
		
		[currentImage	lockFocus];												// Draw on the new Image.
		
		if (firstScreen) {
			[colorBckgnd set];
			NSRectFill([self bounds]);
			firstScreen = FALSE;
		} else {
			if (inverseDisplay) {
				[[colorBckgnd colorWithAlphaComponent:1-myAlpha] set];
				NSRectFillUsingOperation([self bounds], NSCompositingOperationPlusDarker);
			} else {
				[[colorBckgnd colorWithAlphaComponent:myAlpha] set];
				NSRectFillUsingOperation([self bounds], NSCompositingOperationPlusLighter);
			}
		}
		
		[self lineWidth:1.5];

		[self penup];
		unsigned		chnl;
		float			*myBuffer;
		for (chnl = 0; chnl < 8; chnl++) {
			if (channelDisplay[chnl]) {
				[colorChannel[chnl] set];
				[self		windowFromX:xStart ToX:xStop 
							AndFromY:yScaleArray[chnl]*(yOffsetArray[chnl]-1) 
							ToY:yScaleArray[chnl]*(yOffsetArray[chnl]+1)];
				[self		choosePrimary];
				myBuffer = [myDocument channel:chnl];
#if DoesNotWork
				// avoid grabber changing the buffer during plot
				while (([grabber inIndex]-(triggerIndex-triggerPosition)+triggerBufferLength)%triggerBufferLength < xStop) {
					// wait
				}
#endif
				[self plotData:myBuffer startIndex:triggerIndex-triggerPosition length:triggerBufferLength from:xFineStart to:xStop+xFineStart];
				if (showGroundMarkers) {
					[self moveto:xStart :0];
					[self drawTriangleSymbol:3];
					[self moveto:xStop :0];
					[self drawTriangleSymbol:1];
				}
			}
			
		}
		[currentImage unlockFocus];												// Have to balance the -lockFocus/-unlockFocus calls.
		
		triggerIndex += 3*xWidth/4;
		triggerIndex %= triggerBufferLength;
	} else {
		triggerIndex += xWidth;
		triggerIndex %= triggerBufferLength;
	}
}


- (void)				enableChannel:(NSInteger)channel enabled:(Boolean)enabled
{
	// Attention the 4 channels are numbered from 0...3
	
	NSButton *currentButton = (NSButton*)[channelMatrix  cellWithTag:channel];
	[currentButton setEnabled:enabled];
	if (!enabled) {
		[currentButton setState:NSOffState];
	}
}

- (void)		drawAxis
{

    // we are plotting a coordinate system taking the xScale from application and using the secondary axix
	// to plot +/-5 vertical divisions
	float			gridLineWidth = 0.5;

	if (gridImage) {															// this method might be called, when the gridImage...
		firstScreen = TRUE;														// ... is not yet allocated (avoid to plot somewhere)
		[gridImage	lockFocus];													// Draw on the new Image.
		[self		secondaryFromX:xStart ToX:xStop AndFromY:-5 ToY:5];
		[self		chooseSecondary];
		
		[[NSColor	whiteColor] set];
		NSRectFill([self bounds]);												//NSRectFillUsingOperation([self MYFRAME], NSCompositeDestinationAtop);

		[horizontalAxis	setGridRect:&secondaryRect];
		[secondaryAxis	setGridRect:&secondaryRect];
				
		[colorGrid set];

		// draw x and y axis for primary plot
		[horizontalAxis	linTics:secondaryRect.origin.y separation:0.0 ticPercent:200 andMajorEvery:10 lineWidth:gridLineWidth]; 
		[secondaryAxis	linTics:secondaryRect.origin.x separation:1.0 ticPercent:200 andMajorEvery: 5 lineWidth:gridLineWidth];
		[self		choosePrimary];

		[gridImage	unlockFocus];												//  Have to balance the -lockFocus/-unlockFocus calls.
	}
                           
}


- (void)    drawAnother:(id)timer
{
	if (center.y >= radius-speed.y) {
		speed.y	 -= 0.1;
		center.y += speed.y;
	} else {
		speed.y	 *= -0.9; 
		speed.x	 *= 0.9; 
		center.y = radius+speed.y;
	}
	if ((center.x < radius) || (center.x > [self bounds].size.width-radius)) {
		speed.x	 *= -1;
	}
	center.x += speed.x;
	triggerState = triggerStartState;
	[self	nextTrigger];
	[self	setNeedsDisplay:YES];
}



- (void)        setTimerRunning:(BOOL)run
{
    // when running we need a timer instance. If an instance exists already we do nothing
	if ((nil == repeatTimer) && run) {
        repeatTimer = [[NSTimer scheduledTimerWithTimeInterval:0.040
                            target:self
                            selector:@selector(drawAnother:)
                            userInfo:nil
                            repeats:YES
            	      ] retain];
    } else if ((nil != repeatTimer)  && !run) {
		// remove existing timer instance when we stopped
        [repeatTimer invalidate];
        [repeatTimer release];
        repeatTimer = nil;
    }
}

// as responder to NSViewFrameDidChangeNotification
- (void)				sizeDidChange:(NSNotification *)notification
{
	mySize = [self bounds].size;
	
	if (currentImage) {
		[currentImage	setSize:mySize];										// actual image
	} else {
		currentImage	= [[NSImage alloc] initWithSize:mySize];				// actual image
		[currentImage	retain];
	}
	
	if (gridImage) {
		[gridImage	setSize:mySize];											// image of grid
	} else {
		gridImage		= [[NSImage alloc] initWithSize:mySize];				// image of grid
		[gridImage		retain];
	}
	[self			drawAxis];
}


#pragma mark --- IBAction ---

- (IBAction)    drawHistogram:(id)sender
{
    double          value = 0;
	char			*zeroes;
	NSInteger				i;
	double			lastZeroPos, zeroPos = 0, rll;	
	NSInteger				lastPositive, positive;
	//char			*topRLL, *bottomRLL;
	//NSInteger			*topCount, *bottomCount;
	//double		T = 64.0/11.0;												// T period in 
	float			*myBuffer;
	unsigned		oneRowCount;
	
	[self		setTimerRunning:NO];

	if ([[self window] isVisible]) {											// can not access document anymore if closed!
		myBuffer = [myDocument channel:0];
		if (myBuffer) {															// check if budffer is not empty
			
			zeroes = malloc(triggerBufferLength);
			zeroes[0] = 0; 
			lastPositive = myBuffer[0] >= 0;
			lastZeroPos = 0;
			for (i = 1; i < triggerBufferLength; i++) {
				positive = myBuffer[i] >= 0;
				if (positive) {
					if (!lastPositive) {
						zeroPos = i-myBuffer[i]/(myBuffer[i+1]-myBuffer[i]);
						rll = zeroPos - lastZeroPos;
						lastZeroPos = zeroPos;
					}
				} else {
					if (lastPositive) {
						zeroPos = i-myBuffer[i]/(myBuffer[i+1]-myBuffer[i]);
						rll = zeroPos - lastZeroPos;
						lastZeroPos = zeroPos;
					}
				}
				lastPositive = positive;
				zeroes[i] = zeroPos;
			}

			[currentImage	lockFocus];											// Draw on the new Image.
			[self lineWidth:0.5];
			
			[self penup];
			for (oneRowCount = 0; oneRowCount < triggerBufferLength; oneRowCount++) {
				value = zeroes[oneRowCount];
				[self plotto:oneRowCount	:value];
				[self plotto:oneRowCount+1  :value];
			}
			[currentImage unlockFocus];											//  Have to balance the -lockFocus/-unlockFocus calls.
			free(zeroes);
 				
		}
	}
}



- (IBAction)			changeStart:(id)sender
{
	if ([sender intValue]) {
		[self setTimerRunning:YES];
	} else {
		[self setTimerRunning:NO];
	}
}



- (IBAction)			doTrigger:(id)sender
{
	triggerState = waitForHigh;
	[self	nextTrigger];
	[self	setNeedsDisplay:YES];
}


- (IBAction)			changeRisingEdge:(id)sender
{
	[self	setTriggerPolarity:[sender intValue]];
}


- (IBAction)			changeTriggerChannel:(id)sender
{
	NSButton			*triggerButton = [sender selectedCell];
	double				powScale;
	
	triggerChannel		= [triggerButton tag];
	
	powScale		=  pow(10, -yScaleArray[triggerChannel]/5);

	// When we change the trigger channel, where we trigger, we also need to change the step value
	[triggerLevelStepper setIncrement:0.01*powScale];

	triggerBuffer		= [myDocument channel:triggerChannel];
	triggerBufferLength = [myDocument length:triggerChannel];
}


- (IBAction)			changeTriggerLevel:(id)sender
{
	triggerLevel = [sender doubleValue];
	[self		doTrigger:self];
}


- (IBAction)			changeTriggerPosition:(id)sender
{
	double				relativPosition;
	triggerPosition = [sender intValue];
	relativPosition = triggerPosition/(xStop-xStart);
	[triggerPositionSlider	setDoubleValue:relativPosition];
	[self	setNeedsDisplay:YES];
}

- (IBAction)			changeTriggerPositionRelative:(id)sender
{
	triggerPosition = [sender doubleValue]*(xStop-xStart);
	[triggerPositionText	setIntegerValue:triggerPosition];
	[triggerPositionStepper setIntegerValue:triggerPosition];
}

- (IBAction)			changeTriggerMode:(id)sender
{
	[self setTriggerMode:[sender indexOfSelectedItem]];
}

- (IBAction)			changeTiming:(id)sender
{
	[self	setTimingValue:[sender doubleValue]];
}



- (IBAction)			changeOffsetMatrix:(id)sender
{
	NSControl	*currentControl = [sender selectedCell];
	NSInteger			myChannel		= [currentControl tag];
	[self		setYOffsetValue:[currentControl doubleValue] channel:myChannel];
	[self		setNeedsDisplay:YES];
}

- (IBAction)			changeMathOffsetMatrix:(id)sender
{
	NSControl	*currentControl = [sender selectedCell];
	NSInteger			myChannel		= [currentControl tag];
	[self		setYOffsetValue:[currentControl doubleValue] channel:myChannel+4];
	[self	setNeedsDisplay:YES];
}



- (IBAction)			changeScaleMatrix:(id)sender
{
	NSControl	*currentControl = [sender selectedCell];
	NSInteger			myChannel		= [currentControl tag];
	double		scale			= [currentControl doubleValue];
	
	double		powScale		=  pow(10, -scale/5);

	// When we change the scale of the channel, where we trigger, we also need to change the step value
	if (myChannel == triggerChannel) {
		[triggerLevelStepper setIncrement:0.01*powScale];
	}

	[self		setYScaleValue:scale channel:myChannel];
	[self	setNeedsDisplay:YES];
}


- (IBAction)			changeMathScaleMatrix:(id)sender
{
	NSControl	*currentControl = [sender selectedCell];
	long			myChannel	= [currentControl tag];
	[self		setYScaleValue:[currentControl doubleValue] channel:myChannel+4];
	[self	setNeedsDisplay:YES];
}


- (IBAction)			changeChannel:(id)sender
{
	NSButton			*currentButton = [sender selectedCell];
	NSInteger					currentTag     = [currentButton tag];
	
	channelDisplay[currentTag] = [currentButton state];
	[self	setNeedsDisplay:YES];
}

- (IBAction)			changeSum:(id)sender
{
	NSButton			*currentButton = [sender selectedCell];
	NSInteger					currentTag     = [currentButton tag];
	
	channelDisplay[currentTag+4] = [currentButton state];
	[self	setNeedsDisplay:YES];
}

- (IBAction)			changeShowGroundMarkers:(id)sender
{
	showGroundMarkers = (NSOnState == [sender state]);
}

- (IBAction)			changeInverseDisplay:(id)sender
{
	inverseDisplay = (NSOnState == [sender state]);
}


- (IBAction)			colorChannel0:(id)sender
{
	colorChannel[0] = [sender color];
	[self	setNeedsDisplay:YES];
}

- (IBAction)			colorChannel1:(id)sender
{
	colorChannel[1] = [sender color];
	[self	setNeedsDisplay:YES];
}

- (IBAction)			colorChannel2:(id)sender
{
	colorChannel[2] = [sender color];
	[self	setNeedsDisplay:YES];
}

- (IBAction)			colorChannel3:(id)sender
{
	colorChannel[3] = [sender color];
	[self		setNeedsDisplay:YES];
}

- (IBAction)			colorM0:(id)sender
{
	colorM[0] = [sender color];
	[self		setNeedsDisplay:YES];
}

- (IBAction)			colorM1:(id)sender
{
	colorM[1] = [sender color];
	[self		setNeedsDisplay:YES];
}

- (IBAction)			colorM2:(id)sender
{
	colorM[2] = [sender color];
	[self		setNeedsDisplay:YES];
}

- (IBAction)			colorM3:(id)sender
{
	colorM[3] = [sender color];
	[self		setNeedsDisplay:YES];
}

- (IBAction)			colorGrid:(id)sender
{
	colorGrid = [sender color];
	[self		windowFromX:xStart ToX:xStop AndFromY:yScale*(yOffset-1) ToY:yScale*(yOffset+1)];
	[self		drawAxis];
	[self		setNeedsDisplay:YES];
}

- (IBAction)			colorBckgnd:(id)sender
{
	if (nil != sender) {
		colorBckgnd = [sender color];
	} else {
		if (inverseDisplay) {
			colorBckgnd	= [NSColor blackColor];
		} else {
			colorBckgnd	= [NSColor whiteColor];
		}
	}
	[self		drawAxis];
	[self		setNeedsDisplay:YES];
}

- (IBAction)			colorCursor:(id)sender
{
	colorCursor = [sender color];
	[self		setNeedsDisplay:YES];
}

- (IBAction)			colorSpecial:(id)sender
{
	colorSpecial = [sender color];
	[self		setNeedsDisplay:YES];
}

- (IBAction)			toggleDrawer:(id)sender
{
	NSButtonCell	*myButton  = [sender selectedCell];
	NSInteger				buttonTag  = [myButton tag];
	NSDrawer		*toBeClosed, *toBeToggled;
	
	[[sender cellWithTag:1-buttonTag]	setState:NSOffState];					// the other button

	switch(buttonTag) {
		case 1:
			toBeToggled = parameterDrawer;
			toBeClosed = colorDrawer;
			break;
		default:
			toBeClosed = parameterDrawer;
			toBeToggled = colorDrawer;
			break;
	}
	[toBeClosed		close];
	[toBeToggled	toggle:myButton];
}



#pragma mark --- Bindings ---


- (double)				timingValue
{
	return	timingValue;
}

- (void)				setTimingValue:(double)value
{

	double				relativPosition;
	
	timingValue	= value;
	
	xStop = floor(pow(10, -timingValue/5));
	[self		windowFromX:xStart ToX:xStop AndFromY:yScale*(yOffset-1) ToY:yScale*(yOffset+1)];
	[self		drawAxis];

	relativPosition = triggerPosition/(xStop-xStart);
	[triggerPositionSlider	setDoubleValue:relativPosition];

	[self		setNeedsDisplay:YES];
}

- (NSInteger)					remanenzValue
{
	return		remanenzValue;
}

- (void)				setRemanenzValue:(NSInteger)value
{
	remanenzValue = value;
	switch (remanenzValue) {
		case 0:
			myAlpha = 1;
			break;
		case 1:
			myAlpha = 0.5;
			break;
		case 2:
			myAlpha = 0.25;
			break;
		case 3:
			myAlpha = 0.128;
			break;
		case 4:
			myAlpha = 0.064;
			break;
		case 5:
			myAlpha = 0.032;
			break;
		case 6:
			myAlpha = 0.016;
			break;
		case 7:
			myAlpha = 0.008;
			break;
		case 8:
			myAlpha = 0.004;
			break;
		case 9:
			myAlpha = 0.002;
			break;
		case 10:
			myAlpha = 0;
			break;
	}
	[self	colorBckgnd:nil];
}



- (NSInteger)					triggerHoldTime
{
	return		0;
}

- (void)				setTriggerHoldTime:(NSInteger)value
{
}



- (double)				triggerLevel
{
	return		triggerLevel;
}


- (void)				setTriggerLevel:(double)value
{
	triggerLevel = value;
}


- (NSInteger)					triggerPosition
{
	return		triggerPosition;
}

- (void)				setTriggerPosition:(NSInteger)value
{
	triggerPosition = value;
}


- (NSInteger)					triggerChannel
{
	return		triggerChannel;
}

- (void)				setTriggerChannel:(NSInteger)value
{
	triggerChannel = value;
}


- (BOOL)				triggerPolarity
{
	return		triggerPolarity>0;
}

- (void)				setTriggerPolarity:(BOOL)value
{
	if (value) {
		triggerPolarity = +1;
	} else {
		triggerPolarity = -1;
	}
}




- (NSInteger)					triggerMode
{
	return	triggerMode;
}

- (void)				setTriggerMode:(NSInteger)value
{
	enum {AUTO, NORMAL, SINGLE, SPECIAL};
	
	triggerMode = value;
	
	
	switch (triggerMode) {
		case AUTO:
			triggerAutoMode = YES;
			triggerStartState	= waitForLow;
			[self		setTimerRunning:YES];
			break;
		case NORMAL:
			triggerAutoMode = NO;
			triggerStartState	= waitForLow;
			[self		setTimerRunning:YES];
			break;
		case SINGLE:
			triggerAutoMode = NO;
			triggerStartState	= waitForLow;
			[self		setTimerRunning:NO];
			break;
		case SPECIAL:
			triggerAutoMode = NO;
			triggerStartState	= waitSpecial;
			[self		setTimerRunning:YES];
			break;
	}
}




#pragma mark --- Clean up ---


- (void)			dealloc
{
	[self setTimerRunning:NO];

	[[NSNotificationCenter defaultCenter]	removeObserver:self];
			
	[currentImage	release];
	[gridImage		release];
	[colorBckgnd	release];
	[super dealloc];
}



@end
