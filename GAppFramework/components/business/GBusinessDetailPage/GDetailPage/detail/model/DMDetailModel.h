//
//  DMDetailModel.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/9/11.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYKit/NSObject+YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMDetailModel : NSObject<YYModel>
///> 职位: 标题 
@property (nonatomic, strong) NSString *title;
///> 职位: 变换 
@property (nonatomic, assign) CGFloat titleRelative;
///> 职位: 收藏 
@property (nonatomic, assign) BOOL collect;
///> 职位: 类型 
@property (nonatomic, assign) NSInteger workType;
///> 职位: 岗位类型 
@property (nonatomic, assign) NSInteger jobType;
///> 职位: 预约 
@property (nonatomic, assign) BOOL isInterview;
///> 职位: 预约文案 
@property (nonatomic, strong) NSString *ivBtnTxt;
///> 职位: Code 
@property (nonatomic, assign) NSInteger ivCode;
///> 职位: 能否聊天 
@property (nonatomic, assign) BOOL canChat;
///> 职位: 聊天文案 
@property (nonatomic, strong) NSString *chatTxt;
///> 职位:  
@property (nonatomic, strong) NSString *canApplyTxt;
///> 职位:  
@property (nonatomic, assign) NSInteger canApplyCode;
///> 职位: 
@property (nonatomic, strong) NSString *jobID;
///>  
@property (nonatomic, assign) BOOL done;
@end

@interface DMDetaiUrdParamsModel : NSObject<YYModel>
///> 职位类型 
@property (nonatomic, assign) NSInteger type;
///> 职位: ID 
@property (nonatomic, strong) NSString *jobID;
///>  
@property (nonatomic, strong) NSString *urdData;
///>  
@property (nonatomic, strong) DMDetailModel *detail;
@end

NS_ASSUME_NONNULL_END
