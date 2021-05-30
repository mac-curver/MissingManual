//
//  ZoomAnimation.m
//  TestMacGraphics
//
//  Created by LegoEsprit on 22.03.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//

#import "ScientificView.h"
#import "ZoomAnimation.h"

@implementation ZoomAnimation


- (void) setCurrentProgress:(NSAnimationProgress) progress {
    
    // Call super to update the progress value.
    [super setCurrentProgress:progress];
 
    /*
    // Update the window position.
    NSRect theWinFrame = [[NSApp mainWindow] frame];
    NSRect theScreenFrame = [[NSScreen mainScreen] visibleFrame];
    theWinFrame.origin.x = progress *
            (theScreenFrame.size.width - theWinFrame.size.width);
    [[NSApp mainWindow] setFrame:theWinFrame display:YES animate:YES];
    */
    [(ScientificView *)self.delegate doAnimation:progress];
}


@end
