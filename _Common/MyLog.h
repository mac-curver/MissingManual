//
//  MyLog.h
//  TestMacGraphics
//
//  Created by Heinz-Jörg on 28.03.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//
#ifndef MyLog_h
#define MyLog_h

#ifdef DEBUG
#define NSLog(args...) MyLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
#define NSLog(x...)
#endif


// #import "MyLog.h" must be last -otherwise you get Unknown type name 'NSString' !!!
void MyLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);


#endif /* MyLog_h */
