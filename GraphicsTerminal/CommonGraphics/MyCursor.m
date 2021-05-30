//
//  MyCursor.m
//  BodeDiagram
//
//  Created by LegoEsprit on Sat Apr 19 2003.
//  Copyright (c) 2003 LegoEsprit. All rights reserved.
//

#import 	"MyCursor.h"


@implementation MyCursor

+ (NSCursor *)	createCursorFrom:(NSString *)imageName atX:(int)x andY:(int)y {
//	Allocates new cursor with image and hot spot if he is not existing,
//  otherwise does nothing
    NSImage *cursorImage = [NSImage imageNamed:imageName];
    return [[NSCursor alloc] initWithImage:cursorImage hotSpot:NSMakePoint(x, y)];
}


+ (NSCursor *) plusCursor {
	return [MyCursor createCursorFrom:@"crossCursor" atX:7 andY:7];
}

+ (NSCursor *) minusCursor {
	return [MyCursor createCursorFrom:@"minusCursor" atX:7 andY:7];
}


+ (NSCursor *) zoomTopLeftCursor {
	return [MyCursor createCursorFrom:@"topleftCursor" atX:1 andY:1];
}

+ (NSCursor *) zoomTopRightCursor {
	return [MyCursor createCursorFrom:@"toprightCursor" atX:15 andY:1];
}

+ (NSCursor *) zoomBottomLeftCursor {
	return [MyCursor createCursorFrom:@"bottomleftCursor" atX:1 andY:15];
}

+ (NSCursor *) zoomBottomRightCursor {
	return [MyCursor createCursorFrom:@"bottomrightCursor" atX:15 andY:15];
}

+ (NSCursor *) magnifyCursor {
    return [MyCursor createCursorFrom:@"magnify" atX:7 andY:7];
}


- (instancetype) initWithState:(CursorState) startingState {
    if (self = [super init]) {
        [self setCursorToState:startingState];
    }
    return self;
}

/// Getter for the cursor shape
- (NSCursor *) getMyCursorFromState {
    switch (_currentState) {
        case ArrowState:
            return [NSCursor arrowCursor];
        case HandState:
            return NSCursor.openHandCursor;
        case HandClosedState:
            return NSCursor.closedHandCursor;
        case PlusState:
            return MyCursor.plusCursor;
        case ZoomState:
            return NSCursor.arrowCursor;
        case ZoomTopLeftState:
            return MyCursor.zoomTopLeftCursor;
        case ZoomTopRightState:
            return MyCursor.zoomTopRightCursor;
        case ZoomBottomLeftState:
            return MyCursor.zoomBottomLeftCursor;
        case ZoomBottomRightState:
            return MyCursor.zoomBottomRightCursor;
        case MinusState:
            return MyCursor.minusCursor;
        case LeftState:
            return NSCursor.resizeLeftCursor;
        case RightState:
            return NSCursor.resizeRightCursor;
        case TopState:
            return NSCursor.resizeUpCursor;
        case BottomState:
            return NSCursor.resizeDownCursor;
        case MagnifyState:
            return MyCursor.magnifyCursor;
        default:
            return NULL;
    }
}

- (void) setCursorToState:(CursorState)state {
    _currentState = state;
    [[self getMyCursorFromState] set];
}

@end
