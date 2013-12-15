//
//  UIImageView+ADCImageLoading.h
//  Utilities
//
//  Created by Aaron Daub on 12/15/2013.
//  Copyright (c) 2013 Aaron Daub. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^IL_ImageLoadingCompletionBlock)(BOOL successful, BOOL imageWasInMemory, BOOL imageWasOnDisk, UIImage* image);
typedef UIImage*(^IL_TransformDataIntoImageBlock)(NSData* data);
typedef BOOL(^IL_ImageValidityPredicateBlock)(UIImage* image);
typedef UIImage*(^IL_ImageProcessingBlock)(UIImage* image);

@interface UIImageView (ADCImageLoading)


/**
 * -IL_setImageFromURL:placeInCache:dataToImage:processing:validity:completion pulls data from a URL, transforms that data
 * into an image, processes that image, validates the processed image and then calls back on the main queue alerting you to
 * whether or not this process succeeded. If the process is successful, this method will call -setImage: on the main queue with
 * product of this pipeline.
 *
 * @param URL - this is the URL from which the image will be pulled. If the URL is a fileURL we'll check the in-memory cache and the caches directory (the caches URL ++ the last path component of this parameter). We won't go out to the network unless the URL is not a fileURL.
 
 * @param shouldCache - if this is YES we will cache the unprocessed image in an in-memory NSCache as well as in the on-disk caches directory. If this is NO we won't cache the image anywhere.
 
 * @param dataToImage - this is a block that is passed an NSData* and returns a UIImage*, if no block is supplied we get a UIImage* from calling -[UIImage imageWithData:].
 
 * @param validity - this is a block that is passed the processed image and returns a BOOL indicating whether this image is acceptable and still relevant. If no block is specified we will assume any non-nil UIImage* is valid. If shouldCache is YES we will cache the image even if this block will return NO.
 
 * @param completion - this is a block that will be called on the main queue with four parameters that indicate whether this operation was successful, and if applicable, where the resulting image came from as well as that image itself.
 *
 */
- (void)IL_setImageFromURL:(NSURL*)URL placeInCache:(BOOL)shouldCache dataToImage:(IL_TransformDataIntoImageBlock)dataToImageBlock processing:(IL_ImageProcessingBlock)processingHandler validity:(IL_ImageValidityPredicateBlock)validityHandler completion:(IL_ImageLoadingCompletionBlock)completionHandler;

@end
