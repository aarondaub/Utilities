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

- (void)IL_setImageFromURL:(NSURL*)URL placeInCache:(BOOL)shouldCache dataToImage:(IL_TransformDataIntoImageBlock)dataToImageBlock processing:(IL_ImageProcessingBlock)processingHandler validity:(IL_ImageValidityPredicateBlock)validityHandler completion:(IL_ImageLoadingCompletionBlock)completionHandler;

@end
