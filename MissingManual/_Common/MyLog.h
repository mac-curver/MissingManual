//
//  MyLog.h
//  TestMacGraphics
//
//  Created by LegoEsprit on 28.03.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//
//  Here we overwrite NSLog with a customized macro using less text
//  This also ensures that debug information is being removed from
//  the released code.
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
