//
//  DMDetailModel.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/9/11.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMDetailModel.h"

@implementation DMDetaiUrdParamsModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"type"  : @"template_type",
             @"jobID" : @"job_id"
             };
}
@end


@implementation DMDetailModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"collect"      : @"isCollectedPost",
             @"workType"     : @"work_type",
             @"jobType"      : @"job_type",
             @"canChat"      : @"is_canchat",
             @"chatTxt"      : @"im_button_text_noapply",
             @"templateType" : @"template_type",
             @"isInterview"  : @"interview_info.is_interview",
             @"ivBtnTxt"     : @"interview_info.interview_btn.txt",
             @"ivCode"       : @"interview_info.interview_btn.code",
             @"canApplyTxt"  : @"post_button_status.can_apply_text",
             @"canApplyCode" : @"post_button_status.can_apply",
             @"titleRelative": @"title_relative",
             @"jobID"        : @"post_id"
             };
}

#pragma mark - DMApplyModelDelegate
///=============================================================================
/// @name DMApplyModelDelegate
///=============================================================================

- (NSString *)applyJobId {
    return self.jobID;
}

@end
