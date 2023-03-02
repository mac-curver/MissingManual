//
//  UserDefaultExtension.h
//  GradientTestApplication
//
//  Created by LegoEsprit on 05.06.21.
//  Copyright © 2021 legoesprit. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults(UserDefaultsExtension)

enum RGBName: NSInteger {
      Red
    , Green
    , Blue
    , Alpha
    , N_RGBNames
};


- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey;
- (NSColor *)colorForKey:(NSString *)aKey;
- (NSColor *)colorForKey:(NSString *)aKey default:(NSColor *)defaultColor;

- (void)setPoint:(NSPoint)point forKey:(NSString *)aKey;
- (NSPoint)pointForKey:(NSString *)aKey;
- (NSPoint)pointForKey:(NSString *)aKey default:(NSPoint)defaultPoint;


@end


NS_ASSUME_NONNULL_END
