//
//  MyDocument.h
//  Oscilloscop2
//
//  Created by Heinz-Jšrg on Sun Jun 1 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.
//
//	Version 1.30: 28.12.2004		all double replaced by float!


#import		<Cocoa/Cocoa.h>
#import		<CoreAudio/CoreAudio.h>
#import		"lecroy.h"


@class		AudioInput;
@class		TriggerTransformer;	
@class		ScientificImage;	
@class		MyImageView;									


//@interface MyDocument : NSPersistentDocument   //NSDocument
@interface MyDocument : NSDocument
{
	IBOutlet	MyImageView					*originalImageView;
	IBOutlet	NSMatrix					*parameters;
	IBOutlet	NSTableView					*parameterTable;
	TriggerTransformer						*myTriggerTransformer;
    AudioInput								*grabber;
	
	NSMutableArray							*myArray;
	WaveDescriptor							myWaveDescriptor;
	float									*channel[8];
	NSUInteger								*zeroIndex[4];
	NSImage									*myImage;
	NSUInteger								length[8];
	NSUInteger								myFileType;
}

// Macro bind() produces automatically binding glue code
// =====================================================
// name:		the name of the binding variable without my (My) prefix
//				example: Offset1 instead of myOffset1
// type:		C variable type example:float
// viewItem:	read access to the value in the originalImageView view
// valueItem:	write access to the value in the originalImageView view
// the below macro produces the following codes automatically

// the macro ALL_BINDINGS is called with 2 different definitions of the bind
// macro to either create the files for the header or the implementation file
// respectively. Header definition example:

/*
- (float)			myOffset1
- (void)			setMyOffset1:(float) newValue
*/

#define	lf				"\015\012"


// Key-Value bindings
#define	ALL_BINDINGS															\
bind(Offset1, float, yOffsetValue:0, setYOffsetValue:newValue channel:0)		\
bind(Offset2, float, yOffsetValue:1, setYOffsetValue:newValue channel:1)		\
bind(Offset3, float, yOffsetValue:2, setYOffsetValue:newValue channel:2)		\
bind(Offset4, float, yOffsetValue:3, setYOffsetValue:newValue channel:3)		\
bind(Offset5, float, yOffsetValue:4, setYOffsetValue:newValue channel:4)		\
bind(Offset6, float, yOffsetValue:5, setYOffsetValue:newValue channel:5)		\
bind(Offset7, float, yOffsetValue:6, setYOffsetValue:newValue channel:6)		\
bind(Offset8, float, yOffsetValue:7, setYOffsetValue:newValue channel:7)		\
\
bind(YScale1, float, yScaleValue:0,  setYScaleValue:newValue channel:0)			\
bind(YScale2, float, yScaleValue:1,  setYScaleValue:newValue channel:1)			\
bind(YScale3, float, yScaleValue:2,  setYScaleValue:newValue channel:2)			\
bind(YScale4, float, yScaleValue:3,  setYScaleValue:newValue channel:3)			\
bind(YScale5, float, yScaleValue:4,  setYScaleValue:newValue channel:4)			\
bind(YScale6, float, yScaleValue:5,  setYScaleValue:newValue channel:5)			\
bind(YScale7, float, yScaleValue:6,  setYScaleValue:newValue channel:6)			\
bind(YScale8, float, yScaleValue:7,  setYScaleValue:newValue channel:7)			\
\
bind(RemanenzValue,	  NSInteger,  remanenzValue,   setRemanenzValue:newValue)	\
bind(TimingValue,	  double,     timingValue,	   setTimingValue:newValue)     \
bind(TriggerMode,	  NSInteger,  triggerMode,	   setTriggerMode:newValue)     \
bind(TriggerLevel,	  double,     triggerLevel,	   setTriggerLevel:newValue)	\
bind(TriggerPosition, NSInteger,  triggerPosition, setTriggerPosition:newValue)	\
bind(TriggerHoldTime, NSInteger,  triggerHoldTime, setTriggerHoldTime:newValue)	\
bind(TriggerChannel,  NSInteger,  triggerChannel,  setTriggerChannel:newValue)	\
bind(TriggerPolarity, BOOL,       triggerPolarity, setTriggerPolarity:newValue)


#define		bind(name, type, getItem, setItem)									\
- (type)my##name;																\
- (void)setMy##name:(type) newValue;

ALL_BINDINGS


- (void)			loadBinaryHeader:(NSData *)data;
- (void)			loadBinaryData:(NSData *)myData
                            length:(unsigned long)myLength
                                of:(unsigned)channelNumber;
- (BOOL)			myType;
- (MyImageView*)	originalImageView;

- (WaveDescriptor*)	header;

- (NSString*)		descriptor;
- (NSString*)		template;
- (unsigned long)	descLength;
- (NSString*)		instrumentName;
- (double)			verticalGain;
- (double)			verticalOffset;
- (double)			horizontalInterval;
- (double)			horizontalOffset;
- (NSString*)		triggerTime;
- (double)			timeBase;
- (NSString*)		coupling;
- (double)			fixedVerticalGain;
- (NSString*)		bandwidthLimit;


- (float*)			channel:(NSUInteger)number;
- (NSUInteger*)		zeroIndex:(NSUInteger)number;
- (NSUInteger)		length:(NSUInteger)number;
- (NSUInteger)		shortestLength;
- (void)			dealloc;

- (AudioInput*)		grabber;



@end
