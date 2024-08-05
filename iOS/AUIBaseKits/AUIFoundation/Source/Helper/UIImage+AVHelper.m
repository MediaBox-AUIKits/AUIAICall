//
//  UIImage+APColor.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/2.
//

#import "UIImage+AVHelper.h"

@implementation UIImage (AVHelper)

+ (UIImage *)av_imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)av_imageWithLightNamed:(NSString *)lightNamed withDarkNamed:(NSString *)darkNamed inBundle:(NSBundle *)bundle {
    if (@available(iOS 13.0, *)) {
        
        UIImageAsset* imageAseset = [[UIImageAsset alloc] init];
        UIImage *lightImage = [UIImage imageNamed:lightNamed inBundle:bundle compatibleWithTraitCollection:nil];
        if (lightImage) {
            UITraitCollection *lightImageTrateCollection = [UITraitCollection traitCollectionWithTraitsFromCollections:
                    @[[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight],
                      [UITraitCollection traitCollectionWithDisplayScale:lightImage.scale]]];
            [imageAseset registerImage:lightImage withTraitCollection:lightImageTrateCollection];
        }
        UIImage *darkImage = [UIImage imageNamed:darkNamed inBundle:bundle compatibleWithTraitCollection:nil];
        if (darkImage) {
            UITraitCollection* darkImageTrateCollection = [UITraitCollection traitCollectionWithTraitsFromCollections:
                    @[[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark],
                      [UITraitCollection traitCollectionWithDisplayScale:darkImage.scale]]];
            [imageAseset registerImage:darkImage withTraitCollection:darkImageTrateCollection];
        }
        return [imageAseset imageWithTraitCollection:[UITraitCollection currentTraitCollection]];
        
//
//        UIImage *image = [UIImage imageNamed:darkNamed inBundle:bundle compatibleWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]];
//        [image.imageAsset registerImage:[UIImage imageNamed:lightNamed inBundle:bundle compatibleWithTraitCollection:nil] withTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]];
//        image = [image.imageAsset imageWithTraitCollection:UITraitCollection.currentTraitCollection];
//        return image;
    }
    return [UIImage imageNamed:lightNamed inBundle:bundle compatibleWithTraitCollection:nil];
}

@end
