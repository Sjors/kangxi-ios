    //
//  main.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 23-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#ifdef DEBUG // https://devforums.apple.com/message/880348#880348
typedef int (*PYStdWriter)(void *, const char *, int);
static PYStdWriter _oldStdWrite;

int __pyStderrWrite(void *inFD, const char *buffer, int size)
{
    if ( strncmp(buffer, "AssertMacros:", 13) == 0 ) {
        return 0;
    }
    return _oldStdWrite(inFD, buffer, size);
}
#endif

int main(int argc, char * argv[])
{
#ifdef DEBUG // https://devforums.apple.com/message/880348#880348
    _oldStdWrite = stderr->_write;
    stderr->_write = __pyStderrWrite;
#endif
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
