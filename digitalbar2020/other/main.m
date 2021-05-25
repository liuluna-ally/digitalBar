//
//  main.m
//  digitalbar2020
//
//  Created by user on 2020/11/8.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MD5Util.h"
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
