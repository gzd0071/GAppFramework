//
//  CarrierTool.h
//  DMLogin
//
//  Created by Non on 2019/9/25.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CarrierType_ChinaMobile,
    CarrierType_ChinaUnicom,
    CarrierType_ChinaTelecom,
    CarrierType_ChinaTietong,
    CarrierType_dualSim_iOS12, // iOS12 上暂时无法判断出双卡设备的流量卡是哪张，故此时需要统一走闪验
    CarrierType_Unkown,
} CarrierType;

NS_ASSUME_NONNULL_BEGIN

@interface CarrierTool : NSObject

+ (CarrierType)getOperatorsType;
    
@end

NS_ASSUME_NONNULL_END
