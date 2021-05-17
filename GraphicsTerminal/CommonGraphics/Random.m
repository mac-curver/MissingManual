//
//  Random.m
//  TestMacGraphics
//
//  Created by Heinz-Jörg on 26.03.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import "Random.h"

@implementation Random


+ (double) value:(double) maximum from:(double) minimum {
    return minimum+(maximum-minimum)*arc4random()/0xffffffff;
}

+ (double) value:(double) maximum {
    return [self value:maximum from:0.0];
}

+ (double) value {
    return [self value:1.0 from:0.0];
}

@end
