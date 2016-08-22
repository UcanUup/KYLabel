//
//  KYLabel+Tool.m
//  KYLabel
//
//  Created by Young on 16/5/27.
//  Copyright © 2016年 Young. All rights reserved.
//

#import "KYLabel+Tool.h"

#import <CoreText/CoreText.h>
#import "NSString+KYEmoji.h"

static const CGFloat textRectExtraHeight = 2;


@implementation KYLabel (Tool)

//指定行数所对应的文字显示区域大小，未指定行数时则是所有文字的显示区域大小
- (CGRect)textRectWithAttributedString:(NSAttributedString *)attributedString numberOfLines:(NSInteger)numberOfLines orginalBounds:(CGRect)bounds lineHeight:(CGFloat)lineHeight
{
    //创建绘制区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, bounds);
    
    //获得textFrame
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, [attributedString length]), path, NULL);
    
    //得到指定行数内的所有字符需要的高度
    CGFloat textHeight = 0;
    //CTLineRef的数组，所有字符显示的行对象
    CFArrayRef lines = CTFrameGetLines(textFrame);
    //数组的个数即行数，所有字符显示需要的行数
    CFIndex count = CFArrayGetCount(lines);
    
    //获得字符的合适高度
    if (numberOfLines > 0) {
        //行数为0返回整个区域大小
        if (count == 0) {
            //内存释放
            CFRelease(framesetterRef);
            CFRelease(textFrame);
            CFRelease(path);
            return bounds;
        }
        //判断numberOfLines和默认计算出来的行数的最小值，作为可以显示的行数
        NSInteger lineNum = MIN(numberOfLines, count);
        
        if (lineHeight > 0) {
            //指定行高
            textHeight = lineNum *lineHeight;
        } else {
            //得到可以显示的行数的最后一行
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineNum-1);
            //可以显示的行数的最后一行的range
            CFRange lastLineRange = CTLineGetStringRange(line);
            //获得截断的位置，即最后一个字符后面的位置
            NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
            //把可以显示的行数里的所有字符全都截取下来
            NSAttributedString *maxAttributedString = [[attributedString attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy];
            
            CFRelease(framesetterRef);
            //framesetterRef用来计算size
            framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)maxAttributedString);
            //得到所有截取下来的字符的合适宽高
            CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, maxAttributedString.length), NULL, CGSizeMake(CGRectGetWidth(bounds), MAXFLOAT), NULL);
            //得到截取下来的字符的合适高度
            textHeight = MIN(suggestSize.height + textRectExtraHeight, CGRectGetHeight(bounds));
        }
    } else {
        if (lineHeight > 0) {
            textHeight = count * lineHeight;
        } else {
            //不限制行数则获取所有字符的合适宽高
            //CTFramesetterSuggestFrameSizeWithConstraints是一个获得合适的大小的函数，作用相当于sizeThatFit
            CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, attributedString.length), NULL, CGSizeMake(CGRectGetWidth(bounds), MAXFLOAT), NULL);
            //获取所有字符的合适高度
            textHeight = MIN(suggestSize.height, CGRectGetHeight(bounds));
        }
    }
    
    //内存释放
    CFRelease(framesetterRef);
    CFRelease(textFrame);
    CFRelease(path);
    
    return CGRectMake(0, 0, CGRectGetWidth(bounds), textHeight);
}

//根据指定区域得到裁剪后的字符串
- (NSAttributedString *)cutAttributeString:(NSAttributedString *)attributedString numberOfLines:(NSInteger)numberOfLines InRect:(CGRect)textRect attributes:(NSDictionary *)attributes truncatingTail:(BOOL)truncate
{
    NSAttributedString *attrString = attributedString;
    
    //framesetterRef用来计算size
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    //获取所有字符的合适宽高
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, attributedString.length), NULL, CGSizeMake(CGRectGetWidth(textRect), MAXFLOAT), NULL);
    
    if (suggestSize.height > CGRectGetHeight(textRect)) {
        //创建绘制区域
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textRect);
        
        CFRelease(framesetterRef);
        //得到textFrame
        framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
        CTFrameRef textFrame = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, [attributedString length]), path, NULL);
        
        //得到指定行数内的所有字符需要的高度
        //CTLineRef的数组，区域内显示字符的行对象
        CFArrayRef lines = CTFrameGetLines(textFrame);
        //数组的个数即行数，区域内字符显示需要的行数
        CFIndex count = CFArrayGetCount(lines);
        //没有行数则返回
        if (count == 0) {
            //内存释放
            CFRelease(path);
            CFRelease(textFrame);
            CFRelease(framesetterRef);
            return nil;
        }
        
        //取最小的行数
        if (numberOfLines > 0) {
            count = MIN(count, numberOfLines);
        }
        //得到显示区域内的最后一行
        CTLineRef line = CFArrayGetValueAtIndex(lines, count-1);
        //显示区域内的最后一行的range
        CFRange lastLineRange = CTLineGetStringRange(line);
        //显示区域内的最后一行的最后一个字符后面的位置
        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
        //显示区域内的开始到最后一行末尾的字符全都截取下来
        NSMutableAttributedString *cutAttributedString = [[attributedString attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy];
        
        //是否添加省略号
        if (truncate) {
            //显示区域内的最后一行的字符全都截取下来
            NSMutableAttributedString *lastLineAttributeString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
            
            //省略号字符串
            NSString *ellipsisCharacter = @"\u2026";
            NSMutableAttributedString *ellipsisAttributedString = [[NSMutableAttributedString alloc] initWithString:ellipsisCharacter];
            //省略号文字设置
            [ellipsisAttributedString addAttributes:attributes range:NSMakeRange(0, ellipsisAttributedString.length)];
            //最后一行加上省略号
            [lastLineAttributeString appendAttributedString:[ellipsisAttributedString copy]];
            //对最后一行做处理，删除掉末尾的一些字符以显示省略号
            lastLineAttributeString = [self cutSingleLineAttributeString:lastLineAttributeString lineWidth:CGRectGetWidth(textRect)];
            
            //替换最后一行得到有省略号的字符串
            cutAttributedString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(0, lastLineRange.location)] mutableCopy];
            [cutAttributedString appendAttributedString:lastLineAttributeString];
        }
        
        attrString = cutAttributedString;
        
        //内存释放
        CFRelease(path);
        CFRelease(textFrame);
        CFRelease(framesetterRef);
    } else {
        CFRelease(framesetterRef);
    }
    
    return attrString;
}

//对包含省略号的一行字符做处理，如果字符串超出指定宽度，则删除掉末尾的一些字符以显示省略号，否则不做处理
- (NSMutableAttributedString *)cutSingleLineAttributeString:(NSMutableAttributedString *)attributedString lineWidth:(CGFloat)width
{
    //得到最后的文字宽度
    CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGFloat lastLineWidth = (CGFloat)CTLineGetTypographicBounds(truncationToken, nil, nil,nil);
    CFRelease(truncationToken);
    
    //字符的宽度超出了范围则删掉末尾字符
    if (lastLineWidth > width) {
        //Emoji表情占两个字符，因此需要判断
        NSString *lastString = [[attributedString attributedSubstringFromRange:NSMakeRange(attributedString.length - 3, 2)] string];
        //是否包含emoji表情
        BOOL isEmoji = [lastString stringContainsEmoji];
        //减去省略号前一个符号
        [attributedString deleteCharactersInRange:NSMakeRange(attributedString.length - (isEmoji?3:2), isEmoji?2:1)];
        //递归处理，直到够宽为止
        return [self cutSingleLineAttributeString:attributedString lineWidth:width];
    }else{
        //宽度足够则直接返回
        return attributedString;
    }
}

@end
