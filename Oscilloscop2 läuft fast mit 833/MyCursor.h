//
//  MyCursor.h
//  BodeDiagram
//
//  Created by Heinz-Jšrg on Sat Apr 19 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.
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
