/* NumberEntry */

#import <Cocoa/Cocoa.h>

@interface NumberEntry : NSObject
{
    IBOutlet NSStepper *digit0;
    IBOutlet NSStepper *digit1;
    IBOutlet NSStepper *digit2;
    IBOutlet NSPopUpButton *order;
    IBOutlet NSStepper *scale;
    IBOutlet NSTextField *text;
    IBOutlet NSTextField *test;
}
- (IBAction)changeDigit0:(id)sender;
- (IBAction)changeDigit1:(id)sender;
- (IBAction)changeDigit2:(id)sender;
- (IBAction)changeOrder:(id)sender;
- (IBAction)changeScale:(id)sender;
- (IBAction)changeText:(id)sender;

- (double)doubleValue;
- (void)setDoubleValue:(double)value;
@end
