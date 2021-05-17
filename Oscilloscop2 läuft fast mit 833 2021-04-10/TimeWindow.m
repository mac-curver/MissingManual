//
//  TimeWindow.m
//  BodeDiagram
//
//  Created by Heinz-Jšrg on Sun Jun 1 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.

#import		"TimeWindow.h"
#import 	"TimeView.h"

#import 	"myMath.h"


@implementation TimeWindow

- (void)				awakeFromNib
{
	[timeFunction 		removeItemAtIndex:0];							// remove dummy entry from pop-up menu
	[frequencyStepper	setDoubleValue:calculateLog10([frequencyEditField doubleValue])];

	[self 				changeFunction:self];
}


- (BOOL)				acceptsFirstResponder
{
	return YES;
}


- (void)				makeKeyAndOrderFront:(id)sender
{
	NSPopUpButton	*patternPopUp = [self	getPopUpButton];

	NSMenuItem		*myMenuItem = [patternPopUp selectedItem];	
	[timeView		setCurrentPattern:[myMenuItem 	target]];
	[self 			initializePattern];
	[super			makeKeyAndOrderFront:sender];
}


- (IBAction)		changeFunction:(id)sender
{
	[self 				initializePattern];

	[timeView			setNeedsDisplay:YES];
}


- (IBAction)		changeEqualizer:(id)sender
{
	[timeView			setNeedsDisplay:YES];
}


- (IBAction)		changeSlider:(id)sender
{
	double	value = [sender doubleValue]/10000;//[samplingFrequency	doubleValue];
	NSRect	myRect = [timeView windowRect];
	
	myRect.origin.x = value;
	[timeView			setWindowRect:myRect];

	[timeView 			setNeedsDisplay:YES];
}


- (IBAction)		changeFrequency:(id)sender
{	
	[frequencyStepper	setDoubleValue:calculateLog10([frequencyEditField doubleValue])];
	[self 				changeFunction:sender];
}


- (IBAction)		stepperFrequency:(id)sender
{
	float		value = [sender floatValue];
	
	value = pow(10, value);
	[frequencyEditField	setFloatValue:value];
	[self 				changeFunction:sender];
}


- (IBAction)		changeNoise:(id)sender
{	
	[noiseStepper		setDoubleValue:[sender doubleValue]];
	[self 				changeFunction:sender];
}

- (IBAction)		stepperNoise:(id)sender
{	
	[noiseEditField		setDoubleValue:[sender doubleValue]];
	[self 				changeFunction:sender];
}


- (IBAction)		changeAsymmetry:(id)sender
{	
	[asymmetryStepper	setDoubleValue:[sender doubleValue]];
	[self 				changeFunction:sender];
}


- (IBAction)		stepperAsymmetry:(id)sender
{	
	[asymmetryEditField	setDoubleValue:[sender doubleValue]];
	[self 				changeFunction:sender];
}


- (IBAction)		changeEqualizerValue:(id)sender
{	
	[equalizerStepper	setDoubleValue:[sender doubleValue]];
	[self 				changeFunction:sender];
}


- (IBAction)		stepperEqualizerValue:(id)sender
{	
	[equalizerEditField	setDoubleValue:[sender doubleValue]];
	[self 				changeFunction:sender];
}


- (IBAction)		changePersistance:(id)sender
{
	[timeView setTimerRunning:[sender intValue] sender:sender];
	if (0 != [sender intValue]) {
		//[timeView setNeedsDisplay:YES];
	}
}


- (IBAction)		changeOffsetValue:(id)sender
{	
	[offsetStepper		setDoubleValue:[sender doubleValue]];
	[self 				changeFunction:sender];
}


- (IBAction)		stepperOffsetValue:(id)sender
{	
	[offsetEditField	setDoubleValue:[sender doubleValue]];
	[self 				changeFunction:sender];
}


- (IBAction)		changeLimitValue:(id)sender
{
	[limitValueStepper	setDoubleValue:[sender doubleValue]];
	[self 				changeFunction:sender];
}


- (IBAction)		stepperLimitValue:(id)sender
{
	[limitValueEditField	setDoubleValue:[sender doubleValue]];
	[self 					changeFunction:sender];
}


- (IBAction)		changeLimitScale:(id)sender
{
	[limitScaleStepper	setDoubleValue:[sender doubleValue]];
	[self 				changeFunction:sender];
}


- (IBAction)		stepperLimitScale:(id)sender
{
	[limitScaleEditField	setDoubleValue:[sender doubleValue]];
	[self 					changeFunction:sender];
}



- (void)			initializePattern
{
	double	frequency, sf;
	
	frequency	= [frequencyEditField	doubleValue];
	sf			= [samplingFrequency	doubleValue];
}


- (NSPopUpButton *)	getPopUpButton
{
	return	timeFunction;
}


- (double)			getFrequency
{	
	return [frequencyEditField	doubleValue];
}


- (double)			getAsymmetry
{	
	return [asymmetryEditField	doubleValue];
}


- (double)			getOffset
{	
	return [offsetEditField	doubleValue];
}


- (double)			getNoiseLevel
{	
	return [noiseEditField	doubleValue];
}


- (double)			getLimitValue
{	
	return [limitValueEditField	doubleValue];
}


- (double)			getLimitScale
{	
	return [limitScaleEditField	doubleValue];
}


- (TimeView *)		getTimeView
{
	return	timeView;
}


- (void)			setFrequency:(double)hertz
{	
	[frequencyEditField	setDoubleValue:hertz];
}




@end
