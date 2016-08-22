//
//  KYLabel.h
//  KYLabel
//
//  Created by Young on 16/5/20.
//  Copyright © 2016年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KYLineBreakMode) {
    KYLineBreakByWordWrapping = 0, //换行时保留单词
    KYLineBreakByCharWrapping, //换行时保留字符
    KYLineBreakByCharWrappingAndTruncatingTail //换行时保留字符且末尾添加省略号
};

typedef NS_ENUM(NSInteger, KYTextVerticalAlignment) {
    KYTextVerticalAlignmentTop = 0, //顶部对齐
    KYTextVerticalAlignmentCenter, //居中对齐
    KYTextVerticalAlignmentBottom //底部对齐
};


@interface KYLabel : UIView

@property (nonatomic, copy) NSString *text; //内容
@property (nonatomic, strong) UIColor *textColor; //内容颜色
@property (nonatomic, strong) UIFont *font; //字体大小

@property (nonatomic, assign) CGFloat numberOfLines; //显示的行数
@property (nonatomic, assign) CGFloat lineSpacing; //行间距
@property (nonatomic, assign) KYLineBreakMode lineBreakMode; //换行排版模式
@property (nonatomic, assign) KYTextVerticalAlignment verticalAlignment; //垂直对齐方式
@property (nonatomic, assign) BOOL equalLineHeight; //行是否等高，中英文混排会导致行高不一致

@end
