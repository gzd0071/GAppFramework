//
//  LoggerBeautiful.m
//  Logger
//
//  Created by iOS_Developer_G on 2019/8/10.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "LoggerBeautiful.h"

@interface NSObject (Logger)
@end
@implementation NSObject (Logger)
///> 将obj转换成json字符串。如果失败则返回nil 
- (NSString *)convertToJsonString {
    //先判断是否能转化为JSON格式
    if (![NSJSONSerialization isValidJSONObject:self])  return nil;
    NSError *error = nil;
    
    NSJSONWritingOptions jsonOptions = NSJSONWritingPrettyPrinted;
    if (@available(iOS 11.0, *)) {
        //11.0之后，可以将JSON按照key排列后输出，看起来会更舒服
        jsonOptions = NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys ;
    }
    //核心代码，字典转化为有格式输出的JSON字符串
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted  error:&error];
    if (error || !jsonData) return nil;
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
@end

@implementation NSDictionary (Logger)
#ifdef DEBUG
//打印到控制台时会调用该方法
- (NSString *)descriptionWithLocale:(id)locale {
    return [self debugDescription];
}
//有些时候不走上面的方法，而是走这个方法
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    return [self debugDescription];
}
//用po打印调试信息时会调用该方法
- (NSString *)debugDescription {
    return [self convertToJsonString];
}
#endif
@end

@implementation NSArray (Logger)
#ifdef DEBUG
//打印到控制台时会调用该方法
- (NSString *)descriptionWithLocale:(id)locale {
    return [self debugDescription];
}
//有些时候不走上面的方法，而是走这个方法
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    return [self debugDescription];
}
//用po打印调试信息时会调用该方法
- (NSString *)debugDescription {
    return [self convertToJsonString];
}
#endif
@end
