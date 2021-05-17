#import "NumberEntry.h"

@implementation NumberEntry

- (double)doubleValue
{
	double value = [text	doubleValue];
	value *= pow(10,([scale intValue]+12)%3)/100;
	
	return value;
}

- (void)setDoubleValue:(double)value
{
	double  magnitude = log10(value);
	double  mantissa = value/pow(10, magnitude-1);
	int		myScale = (magnitude+12)/3;
	
	[order  selectItemAtIndex:myScale];
	[text	setDoubleValue:mantissa];
	[text	selectText:self];
}


- (IBAction)changeDigit0:(id)sender
{
    double		value;
	int			digit;
	double		increment = pow(10,([scale intValue]+12)%3);
	
	value = [text	doubleValue];
	
	digit = [digit0	intValue];
			[digit0	setIntValue:0];
	value+= digit*increment;
			[text	setDoubleValue:value];
			[text	selectText:sender];
}

- (IBAction)changeDigit1:(id)sender
{
    double		value;
	int			digit;
	double		increment = pow(10,([scale intValue]+12)%3)*10;
	
	value = [text	doubleValue];
	
	digit = [digit1	intValue];
			[digit1	setIntValue:0];
	value+= digit*increment;
			[text	setDoubleValue:value];
			[text	selectText:sender];
}

- (IBAction)changeDigit2:(id)sender
{
    double		value;
	int			digit;
	double		increment = pow(10,([scale intValue]+12)%3)*100;
	
	value = [text	doubleValue];

	digit = [digit2	intValue];
			[digit2	setIntValue:0];
	value+= digit*increment;
			[text	setDoubleValue:value];
			[text	selectText:sender];
}

- (IBAction)changeOrder:(id)sender
{
}

- (IBAction)changeScale:(id)sender
{
	int myScale = ([scale intValue]+12)/3;
	
	[test	setIntValue:[scale intValue]];
	
	[order selectItemAtIndex:myScale];
}

- (IBAction)changeText:(id)sender
{
}

@end
