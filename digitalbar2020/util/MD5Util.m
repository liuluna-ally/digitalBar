//
//  MD5Util.m
//  digitalbar2020
//
//  Created by user on 2020/11/10.
//

#import "MD5Util.h"
#import <CommonCrypto/CommonDigest.h>
@implementation MD5Util
#define CC_MD5_DIGEST_LENGTH 16
+ (NSString *)getmd5WithString:(NSString *)string{
    const char* original_str=[string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02X", digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
    return [outPutStr uppercaseString];
}
@end
