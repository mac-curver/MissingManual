//
//  UserDefaultExtension.m
//  GradientTestApplication
//
//  Created by LegoEsprit on 05.06.21.
//  Copyright © 2021 legoesprit. All rights reserved.
//

#import "UserDefaultExtension.h"


@implementation NSUserDefaults(UserDefaultsExtension)



- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey {
    //NSData *theData=[NSKeyedArchiver archivedDataWithRootObject:aColor];
    //[self setObject:theData forKey:aKey];
    // Simplified human readable storage
    NSColor *rgbColor = [aColor colorUsingColorSpace:NSColorSpace.genericRGBColorSpace];

    CGFloat components[N_RGBNames];
    [rgbColor getComponents:&components[0]];
    
    [self setDouble:components[Red]   forKey:[NSString stringWithFormat:@"%@.red",   aKey]];
    [self setDouble:components[Green] forKey:[NSString stringWithFormat:@"%@.green", aKey]];
    [self setDouble:components[Blue]  forKey:[NSString stringWithFormat:@"%@.blue",  aKey]];
    [self setDouble:components[Alpha] forKey:[NSString stringWithFormat:@"%@.alpha", aKey]];
    
}

- (NSColor *)colorForKey:(NSString *)aKey {
    // Simplified human readable storage

    CGFloat components[N_RGBNames];
    components[Red]   = [self doubleForKey:[NSString stringWithFormat:@"%@.red",   aKey]];
    components[Green] = [self doubleForKey:[NSString stringWithFormat:@"%@.green", aKey]];
    components[Blue]  = [self doubleForKey:[NSString stringWithFormat:@"%@.blue",  aKey]];
    components[Alpha] = [self doubleForKey:[NSString stringWithFormat:@"%@.alpha", aKey]];
    
    return [NSColor colorWithColorSpace:NSColorSpace.genericRGBColorSpace
                                 components:components count:N_RGBNames
                ];

}

- (NSColor *)colorForKey:(NSString *)aKey default:(NSColor *)defaultColor {
    // Simplified human readable storage
    
    if ([self objectForKey:[NSString stringWithFormat:@"%@.red",   aKey]]) {
        
        CGFloat components[N_RGBNames];
        components[Red]   = [self doubleForKey:[NSString stringWithFormat:@"%@.red",   aKey]];
        components[Green] = [self doubleForKey:[NSString stringWithFormat:@"%@.green", aKey]];
        components[Blue]  = [self doubleForKey:[NSString stringWithFormat:@"%@.blue",  aKey]];
        components[Alpha] = [self doubleForKey:[NSString stringWithFormat:@"%@.alpha", aKey]];
        
        return [NSColor colorWithColorSpace:NSColorSpace.genericRGBColorSpace
                                 components:components count:N_RGBNames
                ];
    }
    else {
        
        return defaultColor;
    }
}



- (void)setPoint:(NSPoint)point forKey:(NSString *)aKey {
    [self setDouble:point.x forKey:[NSString stringWithFormat:@"%@.x", aKey]];
    [self setDouble:point.y forKey:[NSString stringWithFormat:@"%@.y", aKey]];
}

- (NSPoint)pointForKey:(NSString *)aKey {
    NSPoint point;
    point.x = [self doubleForKey:[NSString stringWithFormat:@"%@.x", aKey]];
    point.y = [self doubleForKey:[NSString stringWithFormat:@"%@.y", aKey]];

    return point;
}

- (NSPoint)pointForKey:(NSString *)aKey default:(NSPoint)defaultPoint {
    if ([self objectForKey:[NSString stringWithFormat:@"%@.x", aKey]]) {
        NSPoint point;
        point.x = [self doubleForKey:[NSString stringWithFormat:@"%@.x", aKey]];
        point.y = [self doubleForKey:[NSString stringWithFormat:@"%@.y", aKey]];
        
        return point;
    }
    else {
        return defaultPoint;
    }
    
}


@end
