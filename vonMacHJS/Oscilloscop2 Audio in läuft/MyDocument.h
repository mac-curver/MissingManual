//
//  MyDocument.h
//  Oscilloscop2
//
//  Created by Heinz-Jšrg on Sun Feb 22 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface MyDocument : NSDocument
{
	char						*myBuffer;
	char						myHeader[357];
	unsigned					myLength;
}

- (char*)		buffer;
- (char*)		header;
- (unsigned)	length;

@end
