//
//  URLConst.h
//  GConst
//
//  Created by iOS_Developer_G on 2019/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: URL Convienent
////////////////////////////////////////////////////////////////////////////////
/// @@class URL便利宏
////////////////////////////////////////////////////////////////////////////////

#define URL_PATH(A, B) [NSString stringWithFormat:@"/api/%@/client%@", A, B]
#define URL_PATH_V2(B) URL_PATH(@"v2", B)
#define URL_PATH_V3(B) URL_PATH(@"v3", B)

#pragma mark - URLS V2
///=============================================================================
/// @name V2 URLS
///=============================================================================


#pragma mark - URLS V3
///=============================================================================
/// @name V3 URLS
///=============================================================================

NS_ASSUME_NONNULL_END
