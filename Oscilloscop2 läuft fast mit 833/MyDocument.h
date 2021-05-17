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
	IBOutlet	MyImageView			*originalImageView;
	IBOutlet	NSMatrix			*parameters;
	IBOutlet	NSTableView			*parameterTable;
            
    TriggerTransformer              *myTriggerTransformer;
    AudioInput						*grabber;
    
    NSMutableArray					*myArray;
	WaveDescriptor					 myWaveDescriptor;
	double							*channel[8];
	NSUInteger						*zeroIndex[4];
	NSImage							*myImage;
	NSUInteger						 length[8];
	NSUInteger						 myFileType;
    NSDictionary                    *kvcDictionary;
}

// Macro bind() produces automatically binding glue code
// =====================================================
// name:		the name of the binding variable without my (My) prefix
//				example: Offset1 instead of myOffset1
// type:		C variable type example:float
// viewItem:	read access to the value in the originalImageView view
// valueItem:	write access to the value in the originalImageView view
// the below macro produces the following codes automatically

// the macro ALL_BINDINGS is called with 2 different definitions of the
// bind macro to either create the files for the header or the
// implementation file respectively. Header definition example:

/*
- (float)			myOffset1
- (void)			setMyOffset1:(float) newValue
*/

#define	lf				"\015\012"
#define MaxNumChannels  8

/*
// Key-Value bindings
#define	ALL_BINDINGS															\
bind(Offset1, double, yOffsetValue:0, setYOffsetValue:newValue channel:0)		\
bind(Offset2, double, yOffsetValue:1, setYOffsetValue:newValue channel:1)		\
bind(Offset3, double, yOffsetValue:2, setYOffsetValue:newValue channel:2)		\
bind(Offset4, double, yOffsetValue:3, setYOffsetValue:newValue channel:3)		\
bind(Offset5, double, yOffsetValue:4, setYOffsetValue:newValue channel:4)		\
bind(Offset6, double, yOffsetValue:5, setYOffsetValue:newValue channel:5)		\
bind(Offset7, double, yOffsetValue:6, setYOffsetValue:newValue channel:6)		\
bind(Offset8, double, yOffsetValue:7, setYOffsetValue:newValue channel:7)		\
\
bind(YScale1, double, yScaleValue:0,  setYScaleValue:newValue channel:0)			\
bind(YScale2, double, yScaleValue:1,  setYScaleValue:newValue channel:1)			\
bind(YScale3, double, yScaleValue:2,  setYScaleValue:newValue channel:2)			\
bind(YScale4, double, yScaleValue:3,  setYScaleValue:newValue channel:3)			\
bind(YScale5, double, yScaleValue:4,  setYScaleValue:newValue channel:4)			\
bind(YScale6, double, yScaleValue:5,  setYScaleValue:newValue channel:5)			\
bind(YScale7, double, yScaleValue:6,  setYScaleValue:newValue channel:6)			\
bind(YScale8, double, yScaleValue:7,  setYScaleValue:newValue channel:7)			\
\
bind(RemanenzValue,	  NSInteger,  remanenzValue,   setRemanenzValue:newValue)	\
bind(TimingValue,	  double,     timingValue,	   setTimingValue:newValue)     \
bind(TriggerMode,	  NSInteger,  triggerMode,	   setTriggerMode:newValue)     \
bind(TriggerPosition, NSInteger,  triggerPosition, setTriggerPosition:newValue)	\
bind(TriggerHoldTime, NSInteger,  triggerHoldTime, setTriggerHoldTime:newValue)	\
bind(TriggerChannel,  NSInteger,  triggerChannel,  setTriggerChannel:newValue)	\
bind(TriggerPolarity, BOOL,       triggerPolarity, setTriggerPolarity:newValue)


#define		bind(name, type, getItem, setItem)									\
- (type)my##name;																\
- (void)setMy##name:(type) newValue;

ALL_BINDINGS
*/

@property(assign) double  myOffset1;
@property(assign) double  myOffset2;
@property(assign) double  myOffset3;
@property(assign) double  myOffset4;
@property(assign) double  myOffset5;
@property(assign) double  myOffset6;
@property(assign) double  myOffset7;
@property(assign) double  myOffset8;


@property(assign) double  myYScale1;
@property(assign) double  myYScale2;
@property(assign) double  myYScale3;
@property(assign) double  myYScale4;
@property(assign) double  myYScale5;
@property(assign) double  myYScale6;
@property(assign) double  myYScale7;
@property(assign) double  myYScale8;

@property(assign) NSInteger myRemanenzValue;
@property(assign) double    myTimingValue;
@property(assign) NSInteger myTriggerMode;
@property(assign) double    myTriggerLevel;
@property(assign) NSInteger myTriggerPosition;
@property(assign) NSInteger myTriggerHoldTime;
@property(assign) NSInteger myTriggerChannel;
@property(assign) BOOL      myTriggerPolarity;
@property(assign) NSInteger myGlyph;


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


- (double*)			channel:(NSUInteger)number;
- (NSUInteger*)		zeroIndex:(NSUInteger)number;
- (NSUInteger)		length:(NSUInteger)number;
- (NSUInteger)		shortestLength;
- (void)			dealloc;

//- (AudioInput*)		grabber;

- (double)          myOffset1;
- (double)          myOffset2;
- (double)          myOffset3;
- (double)          myOffset4;
- (double)          myOffset5;
- (double)          myOffset6;
- (double)          myOffset7;
- (double)          myOffset8;

- (void)            setMyOffset1:(double) newValue;
- (void)            setMyOffset2:(double) newValue;
- (void)            setMyOffset3:(double) newValue;
- (void)            setMyOffset4:(double) newValue;
- (void)            setMyOffset5:(double) newValue;
- (void)            setMyOffset6:(double) newValue;
- (void)            setMyOffset7:(double) newValue;
- (void)            setMyOffset8:(double) newValue;

- (double)          myYScale1;
- (double)          myYScale2;
- (double)          myYScale3;
- (double)          myYScale4;
- (double)          myYScale5;
- (double)          myYScale6;
- (double)          myYScale7;
- (double)          myYScale8;
- (void)            setMyYScale1:(double) newValue;
- (void)            setMyYScale2:(double) newValue;
- (void)            setMyYScale3:(double) newValue;
- (void)            setMyYScale4:(double) newValue;
- (void)            setMyYScale5:(double) newValue;
- (void)            setMyYScale6:(double) newValue;
- (void)            setMyYScale7:(double) newValue;
- (void)            setMyYScale8:(double) newValue;

- (NSInteger)       myRemanenzValue;
- (double)          myTimingValue;
- (NSInteger)       myTriggerMode;
- (double)          myTriggerLevel;
- (NSInteger)       myTriggerPosition;
- (NSInteger)       myTriggerHoldTime;
- (NSInteger)       myTriggerChannel;
- (BOOL)            myTriggerPolarity;


- (void)            setMyRemanenzValue:(NSInteger)remanenz;
- (void)            setMyTimingValue:(double)timing;
- (void)            setMyTriggerMode:(NSInteger)mode;
- (void)            setMyTriggerLevel:(double)level;
- (void)            setMyTriggerPosition:(NSInteger)position;
- (void)            setMyTriggerHoldTime:(NSInteger)hold;
- (void)            setMyTriggerChannel:(NSInteger)channel;
- (void)            setMyTriggerPolarity:(BOOL)polarity;




@end
