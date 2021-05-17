//
//  MyDocument.m
//  Oscilloscop2
//
//  Created by Heinz-Jšrg on Sun Jun 1 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.
//
//	Version 1.31: 30.04.2005		translated to X-Code 2 now needs filetype edit
//	Version 1.30: 28.12.2004		all double replaced by float!

#import		"TriggerTransformer.h"
#import 	"ScientificImage.h"
#import 	"ImageAxis.h"
#import 	"HorizontalImageAxis.h"
#import 	"VerticalImageAxis.h"
#import		"MyImageView.h"
#import		"NumberEntry.h"
#import		"AudioInput.h"
#import		"MyDocument.h"



@implementation MyDocument


BOOL	hiddenValue = TRUE;

#pragma mark --- Key bindings ---

// Macro bind() produces automatically binding glue code
// =====================================================
// name:		the name of the binding variable without my (My) prefix
//				example: Offset1 instead of myOffset1
// type:		C variable type example:float
// viewItem:	read access to the value in the originalImageView view
// valueItem:	write access to the value in the originalImageView view
// the below macro produces the following codes automatically.

// Implementation file definition example:

/*
- (float)			myOffset1
{
	return    [originalImageView yOffsetValue:0];
}
- (void)			setMyOffset1:(float) newValue
{
	[originalImageView setYOffsetValue:newValue channel:0];
	return;
}
*/

// redefine "bind" macro

#undef		bind								
#define		bind(name, type, getItem, setItem)									\
- (type)my##name { return  [originalImageView getItem];	}						\
- (void)setMy##name:(type) newValue {											\
	[originalImageView setItem];	return;										\
}


ALL_BINDINGS																	// see header file



#pragma mark --- Implementation ---


enum {
	none = 0,
	pictureType,
	lecroyType,
	albType,
	audioType
};



#define		REVERSE(x)	byteReverse((char*)&(x), sizeof(x))


- (void) 		WaveDescriptorReverse
{
	REVERSE(myWaveDescriptor.commType);
	REVERSE(myWaveDescriptor.commOrder);
	REVERSE(myWaveDescriptor.waveDescriptorLength);
	REVERSE(myWaveDescriptor.userTextLength);
	REVERSE(myWaveDescriptor.resDescriptor1);
	REVERSE(myWaveDescriptor.trigTimeLength);
	REVERSE(myWaveDescriptor.riseTimeLength);
	REVERSE(myWaveDescriptor.resArray1);
	REVERSE(myWaveDescriptor.waveArray1Length);
	REVERSE(myWaveDescriptor.waveArray2Length);
	REVERSE(myWaveDescriptor.resArray2);
	REVERSE(myWaveDescriptor.resArray3);
	//myWaveDescriptor.instrumentName
	REVERSE(myWaveDescriptor.instrumentNumber);
	//myWaveDescriptor.traceLabel
	REVERSE(myWaveDescriptor.reserved1);
	REVERSE(myWaveDescriptor.reserved2);
	REVERSE(myWaveDescriptor.waveArrayCount);
	REVERSE(myWaveDescriptor.pntsPerScreen);
	REVERSE(myWaveDescriptor.firstValidPoint);
	REVERSE(myWaveDescriptor.lastValidPoint);
	REVERSE(myWaveDescriptor.firstPoint);
	REVERSE(myWaveDescriptor.sparsingFactor);
	REVERSE(myWaveDescriptor.segmentIndex);
	REVERSE(myWaveDescriptor.subArrayCount);
	REVERSE(myWaveDescriptor.sweepsPerAcq);
	REVERSE(myWaveDescriptor.pointsPerPair);
	REVERSE(myWaveDescriptor.pairOffset);
	REVERSE(myWaveDescriptor.verticalGain);
	REVERSE(myWaveDescriptor.verticalOffset);
	REVERSE(myWaveDescriptor.maxValue);
	REVERSE(myWaveDescriptor.minValue);
	REVERSE(myWaveDescriptor.nominalBits);
	REVERSE(myWaveDescriptor.nomSubArrayCount);
	REVERSE(myWaveDescriptor.horizInterval);
	REVERSE(myWaveDescriptor.horizOffset);
	REVERSE(myWaveDescriptor.pixelOffset);
	//myWaveDescriptor.verticalUnit
	//myWaveDescriptor.horizontalUnit
	REVERSE(myWaveDescriptor.reserved3);
	REVERSE(myWaveDescriptor.reserved4);
	
	REVERSE(myWaveDescriptor.triggerTime.seconds);
	REVERSE(myWaveDescriptor.triggerTime.years);

	REVERSE(myWaveDescriptor.acqDuration);
	REVERSE(myWaveDescriptor.recordType);
	REVERSE(myWaveDescriptor.processingDone);
	REVERSE(myWaveDescriptor.reserved5);
	REVERSE(myWaveDescriptor.risSweeps);
	REVERSE(myWaveDescriptor.timeBase);
	REVERSE(myWaveDescriptor.verticalCoupling);
	REVERSE(myWaveDescriptor.probeAttenuation);
	REVERSE(myWaveDescriptor.fixedVerticalGain);
	REVERSE(myWaveDescriptor.bandWidthLimit);
	REVERSE(myWaveDescriptor.verticalVernier);
	REVERSE(myWaveDescriptor.acqVertOffset);
	REVERSE(myWaveDescriptor.waveSource);
}

- (void) addValueToArray:(NSString *)value forName:(NSString *)name ofType:(NSString *)type
{
	NSMutableDictionary		*myDict = [[NSMutableDictionary alloc] init];
	
	[myDict		setObject:value forKey:@"Value"];
	[myDict		setObject:name	forKey:@"Key"];
	[myDict		setObject:type	forKey:@"Type"];
	[myArray	addObject:myDict];
	[myDict		release];
}



	

- (id)init
{
    int				i;
	
	self = [super init];
	if (self) {
		
		// create an autoreleased instance of our value transformer & register it with the name that we refer to it with
		myTriggerTransformer = [[[TriggerTransformer alloc] init] retain];
		[NSValueTransformer setValueTransformer:myTriggerTransformer forName:@"TriggerTransformer"];

		// Add your subclass-specific initialization here.
		// If an error occurs here, send a [self release] message and return nil.
		for (i = 0; i < 8; i++) {
			channel[i] = nil;
			length[i]  = 0;
		}
		myFileType = audioType;
				

		myArray = [[NSMutableArray alloc] init];
		
		[myArray	retain];
		
	}
	return self;

}

- (void)		showWindows
{
	[super showWindows];
}


- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, 
	// you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) windowController 
{
    int				i;
	const	int		maxBuffer = 8192*1;

	
    [super windowControllerDidLoadNib:windowController];
	// memorize screen position of window
	//[myWindow setFrameAutosaveName:@"My Window"];
	
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	switch (myFileType) {
		case 		pictureType:
			[originalImageView setImage:myImage];
			break;
		case		audioType:
			for (i = 0; i < 2; i++) {											// 2 audio channels
				if (nil == channel[i]) {
					length[i] = maxBuffer;
					channel[i] = malloc(length[i]*sizeof(float));
					zeroIndex[i] = malloc(length[i]*sizeof(unsigned));
				}
			}
			for (i = 4; i < 8; i++) {											// 4 math channels
				if (nil == channel[i]) {
					length[i] = maxBuffer;
					channel[i] = malloc(length[i]*sizeof(float));
				}
			}
			grabber = [[AudioInput alloc] init];    
			[grabber setupAudioLeft:channel[0] Right:channel[1] Size:maxBuffer];
    
			[grabber start];
			[originalImageView				setGrabber:grabber];

			// fall through!
		case		lecroyType:
		case		albType:
			[originalImageView				enableChannel:3 enabled:(nil != channel[3])];
			[originalImageView				enableChannel:2 enabled:(nil != channel[2])];
			// fall through!
			[originalImageView				enableChannel:1 enabled:(nil != channel[1])];
			[originalImageView				enableChannel:0 enabled:(nil != channel[0])];
			[originalImageView				initFirstDisplay];
			break;
	}

	[[parameters cellWithTag: 0] setStringValue:[self descriptor]];
	[[parameters cellWithTag: 1] setStringValue:[self template]];
	[[parameters cellWithTag: 2] setIntegerValue:[self descLength]];
	[[parameters cellWithTag: 3] setStringValue:[self instrumentName]];
	[[parameters cellWithTag: 4] setStringValue:[NSString stringWithFormat:@"%f V/div", [self verticalGain]]];
	[[parameters cellWithTag: 5] setStringValue:[NSString stringWithFormat:@"%E V", [self verticalOffset]]];
	[[parameters cellWithTag: 6] setStringValue:[NSString stringWithFormat:@"%E s", [self horizontalInterval]]];
	[[parameters cellWithTag: 7] setStringValue:[NSString stringWithFormat:@"%E s", [self horizontalOffset]]];
	[[parameters cellWithTag: 8] setStringValue:[self triggerTime]];
	[[parameters cellWithTag: 9] setStringValue:[NSString stringWithFormat:@"%f s/div", [self timeBase]]];
	[[parameters cellWithTag:10] setStringValue:[self coupling]];
	[[parameters cellWithTag:11] setStringValue:[NSString stringWithFormat:@"%f x",  [self fixedVerticalGain]]];
	[[parameters cellWithTag:12] setStringValue:[self bandwidthLimit]];

	[self addValueToArray:[self descriptor] forName:@"Descriptor" ofType:@"char[16]"];
	[self addValueToArray:[self template] forName:@"Template" ofType:@"char[16]"];
	[self addValueToArray:[NSString stringWithFormat:@"%lu", [self descLength]] forName:@"Descriptor Length" ofType:@"long"];
	[self addValueToArray:[self instrumentName] forName:@"Instrument Name" ofType:@"char16"];
	[self addValueToArray:[NSString stringWithFormat:@"%f V/div", [self verticalGain]] forName:@"Vertical Gain" ofType:@"float"];
	[self addValueToArray:[NSString stringWithFormat:@"%E V", [self verticalOffset]] forName:@"Vertical Offest" ofType:@"float"];
	[self addValueToArray:[NSString stringWithFormat:@"%E s", [self horizontalInterval]] forName:@"Horizontal Interval" ofType:@"float"];
	[self addValueToArray:[NSString stringWithFormat:@"%E s", [self horizontalOffset]] forName:@"Horizontal Offset" ofType:@"float"];
	[self addValueToArray:[self triggerTime] forName:@"Trigger Time" ofType:@"timeStamp"];
	[self addValueToArray:[NSString stringWithFormat:@"%f s/div", [self timeBase]] forName:@"Time Base" ofType:@"word"];
	[self addValueToArray:[self coupling] forName:@"Vertical Coupling" ofType:@"word"];
	[self addValueToArray:[NSString stringWithFormat:@"%f x",  [self fixedVerticalGain]] forName:@"Fixed Gain incl. Atten." ofType:@"word"];
	[self addValueToArray:[self bandwidthLimit] forName:@"Bandwidth Limit" ofType:@"word"];
}



- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    return nil;
}



- (void)loadBinaryHeader:(NSData *)data
{
	NSRange				snRange = NSMakeRange(0, 11);							// range for SN suppression
	NSRange				descRange = NSMakeRange(11, sizeof(myWaveDescriptor));	// range for header
	char				serialNumber[11];
	
	[data getBytes:(void*)(&serialNumber) range:snRange];						// last file loaded overwrites the header!!!
	[data getBytes:(void*)(&myWaveDescriptor) range:descRange];					// last file loaded overwrites the header!!!
	if (0 != myWaveDescriptor.commOrder) {										// if != 0 intel low endian otherwise big endian
		[self WaveDescriptorReverse];
	}
}


union intToFloat {
    uint32_t i;
    float fp;
};

+(float)floatAtOffset:(NSUInteger)offset inData:(NSData*)data {
    assert([data length] >= offset + sizeof(float));
    union intToFloat convert;
    
    const uint32_t* bytes = [data bytes] + offset;
    convert.i = CFSwapInt32BigToHost(*bytes);
    
    const float value = convert.fp;
    
    return value;
}

- (void)loadBinaryData:(NSData *)myData  length:(unsigned long)myLength of:(unsigned)channelNumber
{
	NSRange				myRange;												// range to get the bytes
	char				*charBuffer;											// byte buffer
	Boolean				positiveSign;
	unsigned			lastZeroPosition;
	int					k;
	
	length[channelNumber]		= myLength-(sizeof(myWaveDescriptor)+11);		// file length without header
	channel[channelNumber]		= malloc(length[channelNumber]*sizeof(float));
	zeroIndex[channelNumber]	= malloc(length[channelNumber]*sizeof(unsigned));
	charBuffer = malloc(length[channelNumber]);												
	myRange = NSMakeRange(sizeof(myWaveDescriptor)+11, length[channelNumber]);	// start after header
	[myData getBytes:charBuffer range:myRange];                                 // 
	positiveSign = 0 < charBuffer[0];
	lastZeroPosition = 0;
	
	//length[channelNumber] /=2;
	for (k = 0; k < length[channelNumber]; k++) {
		channel[channelNumber][k] = charBuffer[k]/128.0;						// copy data into correct format (scaling for +/-1 Volt!!!)
#ifdef SCHLECHT
		if ((0 < charBuffer[k]) != positiveSign) {
			positiveSign = 0 < charBuffer[k];
			lastZeroPosition ++;												// next index for zero cross detection
			zeroPosition[channelNumber][lastZeroPosition] = k;					// just the index in the array+...
		}
		zeroIndex[channelNumber][k]= lastZeroPosition;
#else
		channel[4][k] += charBuffer[k]/512.0;
#endif
	}
    
    
	free(charBuffer);
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
	Boolean				fileTypeRecognized = NO;								// returns YES
	
	//NSLog([data MIMEType]);
		
    if ([aType isEqualToString:@"JPEG"]			||
		[aType isEqualToString:@"JPG"]			||
		[aType isEqualToString:@"OS-Type-JPEG"]	)  {
		myFileType = pictureType;
		myImage = [[NSImage alloc] initWithData:data];		
        fileTypeRecognized = YES;
	} else {
	/* ([aType isEqualToString:@"LeCroyA"] || [aType isEqualToString:@"LeCroyB"] ||
		[aType isEqualToString:@"LeCroyC"] || [aType isEqualToString:@"LeCroyD"] ||
		[aType isEqualToString:@"LeCroyE"] || [aType isEqualToString:@"LeCroyT"]) */

		NSString		*pathName = [self fileName];
		NSMutableArray	*pathComponents = (NSMutableArray*)[pathName pathComponents];
		NSUInteger		lastIndex = [pathComponents count]-1;
		NSMutableString	*fileName = [NSMutableString stringWithString:[pathComponents objectAtIndex:lastIndex]];
		NSCharacterSet	*pointSet = [NSCharacterSet characterSetWithCharactersInString:@"."];

		NSRange			pointRange = [fileName rangeOfCharacterFromSet:pointSet];
		
		pointRange.location--;
		pointRange.length = 1;
		
		int				i;
		unsigned long	maxLength = 0;
		NSData			*myData[4];
		for (i = 0; i < 4; i++) {															// load up to 4 channels
			NSString		*channelString = [NSString  stringWithFormat:@"%d", i+1];		// produce channel number string
			[fileName replaceCharactersInRange:pointRange withString:channelString];		// filenames like SC1.000, SC2.000, SC3.000, SC4.000
			[pathComponents replaceObjectAtIndex:lastIndex withObject:fileName];			// 
			NSString		*newAbsPathName = [NSString pathWithComponents:pathComponents];	// compose filenames from components
			myData[i] = [NSData dataWithContentsOfFile:newAbsPathName];						// load the data
			
			if (0 != [myData[i] bytes]) {													// empty if file does not exists
				[self loadBinaryHeader:myData[i]];											// range for header suppression
				fileTypeRecognized = YES;
				if (maxLength < [myData[i] length]) {
					maxLength = [myData[i] length];
				}
			}
		}
		maxLength = maxLength-(sizeof(myWaveDescriptor)+11);
		// avoid overflow!
		if (maxLength > 0x080000) {
			maxLength = 0x080000;
		}
		for (i = 0; i < 4; i++) {												// load up to 4 channels
			channel[i+4]	= malloc(maxLength*sizeof(float));					// allocate array for all zero positions
			if (0 != [myData[i] bytes]) {										// empty if file does not exists
				[self loadBinaryData:myData[i] length:[myData[i] length] of:i];	// load the data without header
			}
		}

		if (!fileTypeRecognized) {												// file loading above did not succeed load...
			[self loadBinaryHeader:data];										// range for header suppression
			[self loadBinaryData:data length:[data length] of:0];
		}
		if ([aType isEqualToString:@"alb"]) {
			myFileType = albType;
		} else {
			myFileType = lecroyType;
		}

        fileTypeRecognized = YES;
    }
	return fileTypeRecognized;
}

- (BOOL)			myType
{
	return	YES;																// we use this to identify my type of documents
}

- (MyImageView*)	originalImageView
{
	return	originalImageView;
}


- (WaveDescriptor*) header
{
	return  &myWaveDescriptor;
}

- (NSString*)		descriptor
{
	return [NSString stringWithCString:myWaveDescriptor.descriptor encoding:NSASCIIStringEncoding];
}

- (NSString*)		template
{
	return [NSString stringWithCString:myWaveDescriptor.template encoding:NSASCIIStringEncoding];
}

- (unsigned long)	descLength {
	return myWaveDescriptor.waveDescriptorLength;
}

- (NSString*)	instrumentName
{
	return [NSString stringWithCString:myWaveDescriptor.instrumentName encoding:NSASCIIStringEncoding];
}

- (double)	verticalGain
{
	return myWaveDescriptor.verticalGain;
}

- (double)	verticalOffset
{
	return myWaveDescriptor.verticalOffset;
}

- (double)	horizontalInterval
{
	return myWaveDescriptor.horizInterval;
}

- (double)	horizontalOffset
{
	return myWaveDescriptor.horizOffset;
}

- (NSString*)	triggerTime
{
	return [NSString stringWithFormat:@"%2d.%02d.%04d %2d:%02d:%f",	myWaveDescriptor.triggerTime.days,
																	myWaveDescriptor.triggerTime.months,
																	myWaveDescriptor.triggerTime.years,
																	myWaveDescriptor.triggerTime.hours,
																	myWaveDescriptor.triggerTime.minutes,
																	myWaveDescriptor.triggerTime.seconds];
}

- (double)	timeBase
{
	unsigned	digit = myWaveDescriptor.timeBase % 3;
	unsigned	base  = myWaveDescriptor.timeBase / 3;
	double		value = 0;
	switch (digit) {
		case 0: 
			value = 1E-9;
			break;
		case 1:
			value = 2E-9;
			break;
		case 2:
			value = 5E-9;
			break;
	}
	value = value * pow(10, base);
	return value;
}

- (NSString*)	coupling
{
	switch(myWaveDescriptor.verticalCoupling) {
		case 0: 
			return @"DC 50 Ohm";
		case 1:
			return @"ground";
		case 2:
			return @"DC 1 MOhm";
		case 3:
			return @"ground";
		case 4:
			return @"AC 1 MOhm";
			
	}
	return @"invalid";
}

- (double)	fixedVerticalGain
{
	unsigned	digit = myWaveDescriptor.fixedVerticalGain % 3;
	unsigned	base  = myWaveDescriptor.fixedVerticalGain / 3;
	double		value = 0;
	switch (digit) {
		case 0: 
			value = 1E-6;
			break;
		case 1:
			value = 2E-6;
			break;
		case 2:
			value = 5E-6;
			break;
	}
	value = value * pow(10, base);
	return value;
}

- (NSString*)	bandwidthLimit
{
	switch(myWaveDescriptor.bandWidthLimit) {
		case 0: 
			return @"Off";
		case 1:
			return @"On";
	}
	return @"invalid";
}


- (float*)		channel:(NSUInteger)number
{
	return  channel[number];
}


- (NSUInteger*)		zeroIndex:(NSUInteger)number
{
	return  zeroIndex[number];
}


- (NSUInteger)	length:(NSUInteger)number
{
	return  length[number];
}

- (NSUInteger)	shortestLength
{
	unsigned long	i;
	unsigned long	minimum = 0;
	
	for (i = 0; i < 4; i++) {
		if (0 != length[i]) {
			if ((0 == minimum) || (minimum > length[i])) {
				minimum = length[i];											// shortest length != 0
			}
		}
	}
	return	minimum;
}


- (id)tableView:(NSTableView *)theTableView 
	objectValueForTableColumn:(NSTableColumn *)column
    row:(int)rowIndex

{
	return [[myArray objectAtIndex:rowIndex] objectForKey:[column identifier]];
}



- (long)			numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [myArray count];
}


- (AudioInput*)		grabber
{
	return	grabber;
}


- (void)			dealloc 
{
	int			chnl;
	
	[grabber			stop];													// stop grabber
	[originalImageView	setTimerRunning:NO];									// stop timer thread if not stppoed already


	[myImage			release];												// release allocated objects
    [grabber			release];
	for (chnl = 0; chnl < 4; chnl++) {
		if (channel[chnl])		free(channel[chnl]);
		if (channel[chnl+4])	free(channel[chnl+4]);
		if (zeroIndex[chnl])	free(zeroIndex[chnl]);
	}
	[myArray	release];
	[myTriggerTransformer release];
    [super dealloc];
}



@end
