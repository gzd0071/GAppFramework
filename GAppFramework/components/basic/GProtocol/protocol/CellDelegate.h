//
//  CellDelegate.h
//  GProtocol
//
//  Created by iOS_Developer_G on 2019/9/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * Cell数据协议
 */
@protocol CellModelDelegate <NSObject>
@required
///> cell 复用标识 
- (NSString *)cellIndentifier;
///> cell 高度 
- (CGFloat)cellHeight;
@end

@interface CellDelegate : NSObject

@end

NS_ASSUME_NONNULL_END
