#import <UIKit/UIKit.h>

@interface UIImage (Additions)

- (UIImage *)convertToGrayscale;
- (UIImage *)tintedImageWithColor:(UIColor *)color level:(CGFloat)level;

@end

@interface UIImage (Private)
+ (id)imageNamed:(id)arg1 inBundle:(id)arg2;
@end
