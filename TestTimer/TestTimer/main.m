//
//  main.m
//  TestTimer
//
//  Created by Heinz-Jörg on 15.04.21.
//  Copyright © 2021 Heinz-Jörg. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    
    double y = 0.0;
 
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        NSLog(@"%f", NSProcessInfo.processInfo.systemUptime);
        double start = NSProcessInfo.processInfo.systemUptime;
        
        for (int i = 0; i < 100; i++) {
            NSLog(@"%f %f", NSProcessInfo.processInfo.systemUptime-start, y);
            float f = i*0.1;
            y = f;

        }
        
        
        NSLog(@"Finished, World!");

    }
    return 0;
}
