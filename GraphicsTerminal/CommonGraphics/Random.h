//
//  Random.h
//  TestMacGraphics
//
//  Created by Heinz-Jörg on 26.03.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface Random: NSObject

/// \brief Random value between minimum... maximum
/// \param maximum Maximum value
/// \param minimum Minimum value
+ (double) value:(double) maximum from:(double) minimum;

/// \brief Random value between 0 ... maximum
/// \param maximum Maximum value
+ (double) value:(double) maximum;

/// \brief Random value between 0 ... 1
+ (double) value;

@end

NS_ASSUME_NONNULL_END
