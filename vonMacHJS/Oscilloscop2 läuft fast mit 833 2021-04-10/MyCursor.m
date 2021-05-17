//
//  MyCursor.m
//  BodeDiagram
//
//  Created by Heinz-Jšrg on Sat Apr 19 2003.
//  Copyright (c) 2003 Heinz-Jšrg SCHR…DER. All rights reserved.
//

#import 	"MyCursor.h"


@implementation MyCursor

+ (void)	newCursor:(NSCursor **)myCursor from:(NSString *)imageName atX:(int)x andY:(int)y
//	Allocates new cursor with image and hot spot if he is not existing, otherwise does nothing
{	
	if (!*myCursor) {
        NSImage *cursorImage = [NSImage imageNamed:imageName];
        *myCursor = [[NSCursor allocWithZone:[self zone]] initWithImage:cursorImage hotSpot:NSMakePoint(x, y)];
    }
}


+ (NSCursor *) plusCursor
{
	static NSCursor	*plusCursor;
	[self newCursor:&plusCursor from:@"crossCursor" atX:7 andY:7];
	return plusCursor;
}

+ (NSCursor *) minusCursor
{
	static NSCursor	*minusCursor;
	[self newCursor:&minusCursor from:@"minusCursor" atX:7 andY:7];
	return minusCursor;
}

+ (NSCursor *) handCursor
{
	static NSCursor	*handCursor;
	[self newCursor:&handCursor from:@"PBXOpenGrabHandCursor" atX:3 andY:2];
	return handCursor;
}

+ (NSCursor *) handClosedCursor
{
	static NSCursor	*handClosedCursor;
	[self newCursor:&handClosedCursor from:@"PBXClosedGrabHandCursor" atX:3 andY:2];
	return handClosedCursor;
}


+ (NSCursor *) zoomTopLeftCursor
{
	static NSCursor	*cursor;
	[self newCursor:&cursor from:@"topleftCursor" atX:1 andY:1];
	return cursor;
}

+ (NSCursor *) zoomTopRightCursor
{
	static NSCursor	*cursor;
	[self newCursor:&cursor from:@"toprightCursor" atX:15 andY:1];
	return cursor;
}

+ (NSCursor *) zoomBottomLeftCursor
{
	static NSCursor	*cursor;
	[self newCursor:&cursor from:@"bottomleftCursor" atX:1 andY:15];
	return cursor;
}

+ (NSCursor *) zoomBottomRightCursor
{
	static NSCursor	*cursor;
	[self newCursor:&cursor from:@"bottomrightCursor" atX:15 andY:15];
	return cursor;
}



@end
