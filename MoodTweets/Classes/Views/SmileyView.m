//
// Created by Guillaume Lagorce on 01/02/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import "SmileyView.h"

@implementation SmileyView

- (void)setMoodScore:(CGFloat)moodScore
{
    _moodScore = moodScore;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [self drawSmileyInRect:rect withMood:self.moodScore];
}

/**
* Draws a smiley inside the given rectangle. The mood value (0...1) is used
* to make the smiley happy or sad.
*
* @param rect Rectangle to draw the smiley into
* @param mood Happy (= 1) or sad (= 0) or anything in between
*/
- (void)drawSmileyInRect:(CGRect)rect withMood:(float)mood {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
    CGContextScaleCTM(ctx, rect.size.height/8 ,rect.size.height/8); // Hint: Original Coordinate System has a width an height of 8 pixels

    // Eyes:
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(2, 2, 1, 1));
    CGContextFillEllipseInRect(ctx, CGRectMake(5, 2, 1, 1));

    // Lips:
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(1.5, 5.5)];
    [path addQuadCurveToPoint:CGPointMake(6.5, 5.5) controlPoint:CGPointMake(4, 4+mood*4)];

    path.lineWidth = 0.5;
    path.lineCapStyle = kCGLineCapRound;
    [[UIColor whiteColor] setStroke];
    [path stroke];

    CGContextRestoreGState(ctx);
}

@end