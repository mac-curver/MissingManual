//
//  MyCursor.h
//  BodeDiagram
//
//  Created by LegoEsprit on Sat Apr 19 2003.
//  Copyright (c) 2003 LegoEsprit. All rights reserved.
//

#import 	<Cocoa/Cocoa.h>

// mouse cursor states
typedef enum : NSInteger {
    PlusState,
    HandState,
    ZoomState,
    ZoomTopRightState, ZoomTopLeftState, ZoomBottomRightState, ZoomBottomLeftState,
    HandClosedState,
    MinusState,
    ArrowState,
    LeftState, RightState, TopState, BottomState,
    MagnifyState,
    N_CursorStates
} CursorState;

@interface MyCursor: NSCursor {
    
@public
    CursorState                _currentState;
}

+ (NSCursor *) createCursorFrom:(NSString *)imageName atX:(int)x andY:(int)y;

@property(class, readonly, strong) NSCursor *plusCursor;
@property(class, readonly, strong) NSCursor *minusCursor;
@property(class, readonly, strong) NSCursor *zoomTopLeftCursor;
@property(class, readonly, strong) NSCursor *zoomTopRightCursor;
@property(class, readonly, strong) NSCursor *zoomBottomLeftCursor;
@property(class, readonly, strong) NSCursor *zoomBottomRightCursor;

@property(class, readonly, strong) NSCursor *magnifyCursor;


- (instancetype) initWithState:(CursorState) startingState;

/// Getter for the cursor shape
- (NSCursor *) getMyCursorFromState;
- (void)       setCursorToState:(CursorState)state;


@property(assign) CursorState currentState;


@end
