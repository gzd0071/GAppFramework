//
//  DMLKeyChain.m
//  DMLogin
//
//  Created by Non on 2019/9/23.
//

#import "DMLKeyChain.h"

@interface DMLKeyChain ()
@property (nonatomic, copy) NSString *currentFileName;
@property (nonatomic, strong) NSMutableArray *currentFileLogArr;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation DMLKeyChain

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword,      (__bridge id)kSecClass,
            service,                                    (__bridge id)kSecAttrService,
            service,                                    (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock,(__bridge id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    return ret;
}

#define LastSaveNameFile @"LastSaveNameFile"
#define LogSaveNameFile @"LogSaveNameFile"
+ (NSString *)lastSaveName {
    return [self load:LastSaveNameFile];
}

+ (instancetype)shareInstance {
    static DMLKeyChain *keyChain;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyChain = DMLKeyChain.new;
        [keyChain updateSaveName_SaveArr];
        
        keyChain.formatter = NSDateFormatter.new;
        keyChain.formatter.dateFormat = @"MMdd_HHmmss:SSS";
    });
    return keyChain;
}

- (id)aInit {
    if ([DMLKeyChain lastSaveName]) {
        NSString *lastFileName = [DMLKeyChain lastSaveName];
        int lastFileIndex = [[lastFileName substringFromIndex:15] intValue];
        self.currentFileName = [NSString stringWithFormat:@"%@%d", LogSaveNameFile, lastFileIndex+1];
    } else {
        self.currentFileName = [NSString stringWithFormat:@"%@%d", LogSaveNameFile, 1];
    }
    self.currentFileLogArr = NSMutableArray.new;
    return nil;
}

- (void)updateSaveName_SaveArr {
    if (self.currentFileName) {
        [DMLKeyChain save:self.currentFileName data:self.currentFileLogArr];
    }
    if ([DMLKeyChain lastSaveName]) {
        NSString *lastFileName = [DMLKeyChain lastSaveName];
        int lastFileIndex = [[lastFileName substringFromIndex:15] intValue];
        self.currentFileName = [NSString stringWithFormat:@"%@%d", LogSaveNameFile, lastFileIndex+1];
        [DMLKeyChain save:LastSaveNameFile data:self.currentFileName];//更新存储的上一次文件名
    } else {
        self.currentFileName = [NSString stringWithFormat:@"%@%d", LogSaveNameFile, 1];
        [DMLKeyChain save:LastSaveNameFile data:self.currentFileName];//更新存储的上一次文件名
    }
    self.currentFileLogArr = NSMutableArray.new;
}

- (void)log:(NSString *)log {
    NSString *withDateLog = [NSString stringWithFormat:@"%@ %@", [self.formatter stringFromDate:[NSDate date]], log];
        
    [self.currentFileLogArr addObject:withDateLog];
    [DMLKeyChain save:self.currentFileName data:self.currentFileLogArr];
    if (self.currentFileLogArr.count > 100) {
        [self updateSaveName_SaveArr];
    }
    
    NSLog(@"%@", withDateLog);
//    for (int i = 1; i < 3; i++) {
//        id load =  [DMLKeyChain load:[NSString stringWithFormat:@"%@%d", LogSaveNameFile, i]];
//        NSLog(@"+_)(* %@", load);
//    }
}

@end
