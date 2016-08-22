//
//  KYLabel.m
//  KYLabel
//
//  Created by Young on 16/5/20.
//  Copyright © 2016年 Young. All rights reserved.
//

#import "KYLabel.h"

#import <CoreText/CoreText.h>
#import "KYLabel+Tool.h"

static const CGFloat kPerLineRatio = 1.2f;


@interface KYLabel ()

//显示的文本区域
@property (nonatomic, assign) CGRect textRect;
//文字的属性
@property (nonatomic, strong) NSDictionary<NSString *, id> *textAttributes;

@end


@implementation KYLabel

- (instancetype)init
{
    if (self = [super init]) {
        [self setDefaultValue];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setDefaultValue];
    }
    return self;
}

- (void)setDefaultValue
{
    self.backgroundColor = [UIColor clearColor];
    
    _text = nil;
    _textColor = [UIColor blackColor];
    _font = [UIFont systemFontOfSize:12];
    _numberOfLines = 0;
    _lineSpacing = 4;
    _lineBreakMode = KYLineBreakByWordWrapping;
    _verticalAlignment = KYTextVerticalAlignmentCenter;
    _equalLineHeight = NO;
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //设置文本的显示方式
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_text];
    
    //设置换行排版模式
    CTLineBreakMode lineBreakMode;
    if (KYLineBreakByWordWrapping == _lineBreakMode) {
        lineBreakMode = kCTLineBreakByWordWrapping;
    } else if (KYLineBreakByCharWrapping == _lineBreakMode) {
        lineBreakMode = kCTLineBreakByCharWrapping;
    } else if (KYLineBreakByCharWrappingAndTruncatingTail == _lineBreakMode) {
        lineBreakMode = kCTLineBreakByCharWrapping;
    }
    
    //设置段落排版样式
    CGFloat lineSpace = _lineSpacing;
    CGFloat lineSpaceMax = _lineSpacing;
    CGFloat lineSpaceMin = _lineSpacing;
    const CFIndex numberOfSettings = 4;
    CTParagraphStyleSetting theSettings[] = {
        {kCTParagraphStyleSpecifierLineSpacing,sizeof(CGFloat),&lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&lineSpaceMax},
        {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&lineSpaceMin},
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakMode}
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, numberOfSettings);
    
    //文本属性设置
    self.textAttributes = @{NSParagraphStyleAttributeName : (__bridge id)(theParagraphRef),
                            NSFontAttributeName : _font,
                            NSForegroundColorAttributeName : _textColor};
    [attributedString addAttributes:_textAttributes range:NSMakeRange(0, attributedString.length)];
    
    //指定行高
    CGFloat lineHeight = (_equalLineHeight) ? _font.pointSize*kPerLineRatio+_lineSpacing : 0;
    //指定行数内的所有字符显示需要的frame
    self.textRect = [self textRectWithAttributedString:attributedString numberOfLines:_numberOfLines orginalBounds:self.bounds lineHeight:lineHeight];
    //是否需要省略号
    BOOL truncate = (_lineBreakMode == KYLineBreakByCharWrappingAndTruncatingTail);
    //重新得到需要显示的字符
    attributedString = [[self cutAttributeString:attributedString numberOfLines:_numberOfLines InRect:_textRect attributes:_textAttributes truncatingTail:truncate] mutableCopy];
    
    //调整垂直对齐方式
    CGRect textFrame = _textRect;
    CGFloat orginY = 0;
    if (KYTextVerticalAlignmentTop == _verticalAlignment) {
        //顶部对齐
        orginY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(textFrame));
    } else if (KYTextVerticalAlignmentBottom == _verticalAlignment) {
        //底部对齐
        orginY = 0;
    } else if (KYTextVerticalAlignmentCenter == _verticalAlignment) {
        //居中对齐
        orginY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(textFrame)) / 2;
    }
    textFrame.origin.y = orginY;
    self.textRect = textFrame;
    
    CALayer *textRectLayer = [[CALayer alloc] init];
    textRectLayer.frame = _textRect;
    [self.layer addSublayer:textRectLayer];
    
    //1.得到当前用于绘制画布的上下文，用于后续将内容绘制在画布上。因为Core Text是与Core Graphic配合使用的，绘图的时候需要获得当前的上下文进行绘制
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //2.翻转当前的坐标系（因为对于底层绘制引擎来说，屏幕坐下角为（0，0））
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //3.创建绘制区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, _textRect);
    
    //4.根据AttributedString生成CTFramesetterRef
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, [attributedString length]), path, NULL);
    
    //5.进行绘制
    if (_equalLineHeight) {
        //逐行绘制
        CFArrayRef lines = CTFrameGetLines(frame);
        CFIndex lineCount = CFArrayGetCount(lines);
        CGPoint lineOrigins[lineCount];
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
        
        for (int i = 0; i < lineCount; i++) {
            CGFloat originY;
            if (KYTextVerticalAlignmentTop == _verticalAlignment) {
                originY = CGRectGetHeight(self.bounds) + _lineSpacing;
            } else if (KYTextVerticalAlignmentBottom == _verticalAlignment) {
                originY = CGRectGetHeight(_textRect);
            } else if (KYTextVerticalAlignmentCenter == _verticalAlignment) {
                originY = (CGRectGetHeight(self.bounds) + CGRectGetHeight(_textRect)) / 2  + _lineSpacing / 2;
            }
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            CGPoint lineOrigin = lineOrigins[i];
            lineOrigin.y = originY - (i + 1) * lineHeight - _font.descender;
            CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
            CTLineDraw(line, context);
        }
    } else {
        //全部绘制
        CTFrameDraw(frame, context);
    }
    
    //6.内存管理
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

@end
