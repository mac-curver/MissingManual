//
//  ToneToHertzTransformer.m
//  Frequency Generator
//
//  Created by Heinz-Jšrg Schršder on 15.12.04.
//  Copyright 2004 Heinz-Jšrg Schršder. All rights reserved.
//

#import "ToneToHertzTransformer.h"


@implementation ToneToHertzTransformer

const double	pureTone = 1.059463094359;//pow(2, 1.0/12);

+ (Class)transformedValueClass {
    return [NSNumber class];
}


+ (BOOL)allowsReverseTransformation {
    return YES;   
}


- (id)transformedValue:(id)value {
	double			frequencyTone = 36;											// tone A
	double			frequencyHertz;

    if (value == nil) return nil;

    // Attempt to get a reasonable value from the value object. 
    if ([value respondsToSelector: @selector(floatValue)]) {
		// handles NSString and NSNumber
        frequencyTone = [value floatValue]; 
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format: @"Value (%@) does not respond to -floatValue."
                  , [value class]
         ];
    }

    // convert halftone into Hz
	frequencyHertz = 55*pow(pureTone, frequencyTone);

    return [NSNumber numberWithFloat:frequencyHertz];
}


- (id)reverseTransformedValue:(id)value {
	double			frequencyTone;
	double			frequencyHertz = 440;

    if (value == nil) return nil;

    // Attempt to get a reasonable value from the value object. 
    if ([value respondsToSelector: @selector(floatValue)]) {
		// handles NSString and NSNumber
        frequencyHertz = [value floatValue];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format: @"Value (%@) does not respond to -floatValue."
                  , [value class]
         ];
    }

    // convert Hz into halftone
    frequencyTone = 12*log(frequencyHertz/55)/log(2);

    return [NSNumber numberWithDouble:frequencyTone];
}

@end
