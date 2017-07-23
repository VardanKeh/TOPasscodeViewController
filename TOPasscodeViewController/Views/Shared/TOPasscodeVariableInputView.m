//
//  TOPasscodeVariableInputField.m
//  TOPasscodeViewControllerExample
//
//  Created by Tim Oliver on 7/6/17.
//  Copyright © 2017 Timothy Oliver. All rights reserved.
//

#import "TOPasscodeVariableInputView.h"
#import "TOPasscodeCircleImage.h"

@interface TOPasscodeVariableInputView ()

@property (nonatomic, strong) UIImage *backgroundImage; // The outline image for this view
@property (nonatomic, strong) UIImage *circleImage;     // The circle image representing a single character

@property (nonatomic, strong) NSMutableArray<UIImageView *> *circleViews;

@end

@implementation TOPasscodeVariableInputView

#pragma mark - Class Creation -

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _outlineThickness = 1.0f;
        _outlineCornerRadius = 5.0f;
        _circleDiameter = 11.0f;
        _circleSpacing = 7.0f;
        _outlinePadding = (CGSize){10,10};
        _maximumVisibleLength = 10;
    }

    return self;
}

#pragma mark - View Setup -
- (void)setUpImageForCircleViews
{
    if (self.circleImage != nil) { return; }

    self.circleImage = [TOPasscodeCircleImage circleImageOfSize:_circleDiameter inset:0.0f padding:1.0f antialias:YES];
    for (UIImageView *circleView in self.circleViews) {
        circleView.image = self.circleImage;
        [circleView sizeToFit];
    }
}

- (void)setUpCircleViewsForLength:(NSInteger)length
{
    // Set up the number of circle views if needed
    if (self.circleViews.count == length) { return; }

    if (self.circleViews == nil) {
        self.circleViews = [NSMutableArray arrayWithCapacity:_maximumVisibleLength];
    }

    // Reduce the number of views
    while (self.circleViews.count > length) {
        UIImageView *circleView = self.circleViews.lastObject;
        [circleView removeFromSuperview];
        [self.circleViews removeLastObject];
    }

    // Increase the number of views
    [UIView performWithoutAnimation:^{
        while (self.circleViews.count < length) {
            UIImageView *circleView = [[UIImageView alloc] initWithImage:self.circleImage];
            circleView.alpha = 0.0f;
            [self addSubview:circleView];
            [self.circleViews addObject:circleView];
        }
    }];
}

- (void)setUpBackgroundImage
{
    if (self.backgroundImage != nil) { return; }

    self.backgroundImage = [[self class] backgroundImageWithThickness:_outlineThickness cornerRadius:_outlineCornerRadius];
    self.image = self.backgroundImage;
}

#pragma mark - View Layout -

- (void)sizeToFit
{
    CGRect frame = self.frame;

    // Calculate the width
    frame.size.width = self.outlineThickness * 2.0f;
    frame.size.width += (self.outlinePadding.width * 2.0f);
    frame.size.width += (self.maximumVisibleLength * (self.circleDiameter+2.0f)); // +2 for padding
    frame.size.width += (self.maximumVisibleLength - 1) * self.circleSpacing;

    // Height
    frame.size.height = self.outlineThickness * 2.0f;
    frame.size.height += self.outlinePadding.height * 2.0f;
    frame.size.height += self.circleDiameter;

    self.frame = frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Genearate the background image if we don't have one yet
    [self setUpBackgroundImage];

    // Set up the circle view image
    [self setUpImageForCircleViews];

    // Set up the circle views
    [self setUpCircleViewsForLength:self.maximumVisibleLength];

    // Layout the circle views for the current length
    CGRect frame = CGRectZero;
    frame.size = self.circleImage.size;
    frame.origin.y = CGRectGetMidY(self.bounds) - (frame.size.height * 0.5f);
    frame.origin.x = self.outlinePadding.width + self.outlineThickness;

    for (UIImageView *circleView in self.circleViews) {
        circleView.frame = frame;
        frame.origin.x += frame.size.width + self.circleSpacing;
    }
}

#pragma mark - Accessors -

- (void)setOutlineThickness:(CGFloat)outlineThickness
{
    if (_outlineThickness == outlineThickness) { return; }
    _outlineThickness = outlineThickness;
    self.backgroundImage = nil;
    [self setNeedsLayout];
}

- (void)setOutlineCornerRadius:(CGFloat)outlineCornerRadius
{
    if (_outlineCornerRadius == outlineCornerRadius) { return; }
    _outlineCornerRadius = outlineCornerRadius;
    self.backgroundImage = nil;
    [self setNeedsLayout];
}

- (void)setCircleDiameter:(CGFloat)circleDiameter
{
    if (_circleDiameter == circleDiameter) { return; }
    _circleDiameter = circleDiameter;
    [self setUpImageForCircleViews];
}

- (void)setLength:(NSInteger)length
{
    [self setLength:length animated:NO];
}

- (void)setLength:(NSInteger)length animated:(BOOL)animated
{
    if (length == _length) { return; }

    _length = length;

    void (^animationBlock)() = ^{
        NSInteger i = 0;
        for (UIImageView *circleView in self.circleViews) {
            circleView.alpha = i < length ? 1.0f : 0.0f;
            i++;
        }
    };

    if (!animated) {
        animationBlock();
        return;
    }

    [UIView animateWithDuration:0.4f animations:animationBlock];
}

#pragma mark - Image Creation -

+ (UIImage *)backgroundImageWithThickness:(CGFloat)thickness cornerRadius:(CGFloat)radius
{
    CGFloat inset = thickness / 2.0f;
    CGFloat dimension = (radius * 2.0f) + 2.0f;

    CGRect frame = CGRectZero;
    frame.origin = CGPointMake(inset, inset);
    frame.size = CGSizeMake(dimension, dimension);

    CGSize canvasSize = frame.size;
    canvasSize.width += thickness;
    canvasSize.height += thickness;

    UIGraphicsBeginImageContextWithOptions(canvasSize, NO, 0.0f);
    {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius];
        path.lineWidth = thickness;
        [[UIColor blackColor] setStroke];
        [path stroke];
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIEdgeInsets insets = UIEdgeInsetsMake(radius+1, radius+1, radius+1, radius+1);
    image = [image resizableImageWithCapInsets:insets];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
