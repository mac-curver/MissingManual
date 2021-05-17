//
//  MyDocument.m
//  Oscilloscop2
//
//  Created by Heinz-Jšrg on Sun Feb 22 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import		"MyDocument.h"
#import		"NumberEntry.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    return nil;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
	NSRange				myRange;
	const unsigned int  headerSize = 357;
	
	if ([aType isEqualToString:@"LeCroyA"] || 
		[aType isEqualToString:@"LeCroyB"] ||
		[aType isEqualToString:@"LeCroyC"] ||
		[aType isEqualToString:@"LeCroyD"] ||
		[aType isEqualToString:@"LeCroyE"]) {
		
		myLength =		   [data length]-headerSize;
		myBuffer = malloc(myLength);
		myRange = NSMakeRange(0, headerSize);
		[data getBytes:(void*)myHeader range:myRange];
		myRange = NSMakeRange(headerSize, myLength);
		[data getBytes:(void*)myBuffer range:myRange];
		
        return YES;
    } else {
        return NO;
    }
    
	return YES;
}

- (char*)   buffer
{
	return  myBuffer;
}

- (char*)   header;
{
	return  myHeader;
}

- (unsigned)   length
{
	return  myLength;
}

- (void)dealloc 
{
	free(myBuffer);
    [super dealloc];
}



@end
