/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import <objc/runtime.h>
static const void *delegateCacheKey = &delegateCacheKey;

@implementation UIImageView (WebCache)
@dynamic delegateCache;

- (id<UIImageViewWebCacheDelegate>)delegateCache
{
    return objc_getAssociatedObject(self, delegateCacheKey);
}

- (void)setDelegateCache:(id<UIImageViewWebCacheDelegate>)delegate{
    objc_setAssociatedObject(self, delegateCacheKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0];
}


- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    self.image = placeholder;

    if (url)
    {
        [manager downloadWithURL:url delegate:self options:options];
    }
}

- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    self.image = image;
    if (self.delegateCache && [self.delegateCache respondsToSelector:@selector(imageView:didSetWithImage:)]) {
        [self.delegateCache imageView:self didSetWithImage:image];
    }
}

@end
