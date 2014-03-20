//
//  UIImageView+ADCImageLoading.m
//  Utilities
//
//  Created by Aaron Daub on 12/15/2013.
//  Copyright (c) 2013 Aaron Daub. All rights reserved.
//

#import "UIImageView+ADCImageLoading.h"

@implementation UIImageView (ADCImageLoading)

- (void)IL_setImageFromURL:(NSURL *)URL placeInCache:(BOOL)shouldCache dataToImage:(IL_TransformDataIntoImageBlock)dataToImageBlock processing:(IL_ImageProcessingBlock)processingHandler validity:(IL_ImageValidityPredicateBlock)validityHandler completion:(IL_ImageLoadingCompletionBlock)completionHandler {
    if(!URL){
        [self IL_performCompletionHandler:completionHandler successful:NO imageWasInMemory:NO imageWasOnDisk:NO image:nil];
        return;
    }
    
    
    UIImage* cachedImage = [[[self class] IL_inMemoryCache] objectForKey:URL];
   
    if(cachedImage){
        UIImage* finalizedImage = [self IL_processImage:cachedImage withBlock:processingHandler];
        if([self IL_validateImage:finalizedImage withBlock:validityHandler] && completionHandler){
            [self IL_performCompletionHandler:completionHandler successful:YES imageWasInMemory:YES imageWasOnDisk:NO image:finalizedImage];
        }else if (completionHandler){
            [self IL_performCompletionHandler:completionHandler successful:NO imageWasInMemory:YES imageWasOnDisk:NO image:finalizedImage];
        }
        return;
    }
    
    NSURL* localURL = [self IL_localURLForRemoteURL:URL];

    [[[self class] IL_fileIOQueue] addOperationWithBlock:^{
        NSData* imageData = [NSData dataWithContentsOfURL:localURL];
        if(imageData){
            UIImage* image = [self IL_transformDataIntoImage:imageData block:dataToImageBlock];
            if(image){
                UIImage* finalizedImage = [self IL_processImage:image withBlock:processingHandler];
                if([self IL_validateImage:finalizedImage withBlock:validityHandler] && completionHandler){
                    [self IL_performCompletionHandler:completionHandler successful:YES imageWasInMemory:NO imageWasOnDisk:YES image:finalizedImage];
                }else if(completionHandler){
                      [self IL_performCompletionHandler:completionHandler successful:NO imageWasInMemory:NO imageWasOnDisk:YES image:finalizedImage];
                }
                return;
            }
            
        }else{
            if(URL.isFileURL){
                [self IL_performCompletionHandler:completionHandler successful:NO imageWasInMemory:NO imageWasOnDisk:NO image:nil];
                return;
            }
            
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:URL] queue:[[self class] IL_networkQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if(!connectionError && data){
                    UIImage* image = [self IL_transformDataIntoImage:data block:dataToImageBlock];
                    [self IL_cacheImage:image imageData:data forURL:URL shouldCache:shouldCache];
                    UIImage* finalizedImage = [self IL_processImage:image withBlock:processingHandler];
                    if ([self IL_validateImage:finalizedImage withBlock:validityHandler] && completionHandler) {
                        [self IL_performCompletionHandler:completionHandler successful:YES imageWasInMemory:NO imageWasOnDisk:NO image:finalizedImage];
                    }else if (completionHandler){
                        [self IL_performCompletionHandler:completionHandler successful:NO imageWasInMemory:NO imageWasOnDisk:NO image:finalizedImage];
                    }
                    
                }
            }];
        }
        
    }];
    
    
   
}

#pragma mark - Private Interface

+ (NSCache*)IL_inMemoryCache{
    static NSCache* cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    
    return cache;
}

+ (NSOperationQueue*)IL_networkQueue{
    static NSOperationQueue* networkQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkQueue = [[NSOperationQueue alloc] init];
    });
    
    return networkQueue;
}

+ (NSOperationQueue*)IL_fileIOQueue{
    static NSOperationQueue* fileIOQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileIOQueue = [[NSOperationQueue alloc] init];
    });
    return fileIOQueue;
}

+ (NSURL*)IL_cacheDirectoryURL{
    NSString* cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [NSURL fileURLWithPath:cachePath];
}

- (void)IL_cacheImage:(UIImage*)image imageData:(NSData*)imageData forURL:(NSURL*)URL shouldCache:(BOOL)shouldCache{
    if(shouldCache && URL && image){
        [[[self class] IL_inMemoryCache] setObject:image forKey:URL];
        [[[self class] IL_fileIOQueue] addOperationWithBlock:^{
            if(imageData){
                BOOL cached = [imageData writeToURL:[self IL_localURLForRemoteURL:URL] atomically:YES];
                if(cached){
                    // Debugging hook...
                }
            }
        }];
    }
}

- (void)IL_performCompletionHandler:(IL_ImageLoadingCompletionBlock)completionHandler successful:(BOOL)success imageWasInMemory:(BOOL)imageWasInMemory imageWasOnDisk:(BOOL)imageWasOnDisk image:(UIImage*)image{
    if(success && image){
        [self IL_setImage:image];
    }
    
    if(!completionHandler){
        return;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        completionHandler(success, imageWasInMemory, imageWasOnDisk, image);
    }];
}

- (UIImage*)IL_transformDataIntoImage:(NSData*)data block:(IL_TransformDataIntoImageBlock)dataToImageBlock{
    if(!data){
        return nil;
    }
    
    return (dataToImageBlock) ? dataToImageBlock(data) : [UIImage imageWithData:data];
}

- (UIImage*)IL_processImage:(UIImage*)image withBlock:(IL_ImageProcessingBlock)processingHandler{
   return (processingHandler) ? processingHandler(image) : image;
}

- (NSURL*)IL_localURLForRemoteURL:(NSURL*)remoteURL{
    if(!remoteURL.isFileURL){
        return [[[self class] IL_cacheDirectoryURL] URLByAppendingPathComponent:remoteURL.lastPathComponent];
    }
    return remoteURL;
}

- (BOOL)IL_validateImage:(UIImage*)image withBlock:(IL_ImageValidityPredicateBlock)validityHandler{
    return (!validityHandler || validityHandler(image));
}

- (void)IL_setImage:(UIImage*)image{
    if(image){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.image = image;
        }];
    }
}

@end
