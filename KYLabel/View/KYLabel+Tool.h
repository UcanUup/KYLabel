//
//  KYLabel+Tool.h
//  KYLabel
//
//  Created by Young on 16/5/27.
//  Copyright © 2016年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KYLabel.h"

@interface KYLabel (Tool)

/**
 *  指定一个显示区域和需要显示的行数，返回该行数对应的显示区域范围，如果行数未指定则返回原来的范围。
 *
 *  @param attributedString 属性字符串
 *  @param numberOfLines    需要显示的行数
 *  @param bounds           原始的显示区域
 *  @param lineHeight       指定行高，即每行高度一致，0为不限制
 *
 *  @return 指定行数对应的显示范围
 */
- (CGRect)textRectWithAttributedString:(NSAttributedString *)attributedString numberOfLines:(NSInteger)numberOfLines orginalBounds:(CGRect)bounds lineHeight:(CGFloat)lineHeight;

//根据指定区域得到裁剪后的字符串
/**
 *  指定一个显示范围，然后对字符串进行截取，如果字符串超过了范围则添加省略号。得到的字符串可以适应显示区域。
 *
 *  @param attributedString 属性字符串
 *  @param numberOfLines    需要显示的行数
 *  @param textRect         指定的显示范围
 *  @param attributes       省略号的文字设置
 *  @param truncate         是否添加省略号
 *
 *  @return 截取后的可以包含省略号（如果文字超过了范围）的字符串
 */
- (NSAttributedString *)cutAttributeString:(NSAttributedString *)attributedString numberOfLines:(NSInteger)numberOfLines InRect:(CGRect)textRect attributes:(NSDictionary *)attributes truncatingTail:(BOOL)truncate;

@end
