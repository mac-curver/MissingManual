//
//  MyCursor.h
//  BodeDiagram
//
//  Created by Heinz-J�rg on Sat Apr 19 2003.
//  Copyright (c) 2003 Heinz-J�rg SCHR�DER. All rights reserved.
//

//#import 	<Foundation/Foundation.h> // is not enough!!!
#import 	<Cocoa/Cocoa.h>


@interface MyCursor : NSCursor {	
}


+ (NSCursor *)	plusCursor;
+ (NSCursor *)	minusCursor;
+ (NSCursor *)	handCursor;
+ (NSCursor *)	handClosedCursor;
+ (NSCursor *)	zoomTopLeftCursor;
+ (NSCursor *)	zoomTopRightCursor;
+ (NSCursor *)	zoomBottomLeftCursor;
+ (NSCursor *)	zoomBottomRightCursor;

@end
