//
//  ADCSafeCollection.h
//  SafeCollection
//
//  Created by Aaron Daub on 3/23/2014.
//
//

#import <Foundation/Foundation.h>

@interface ADCSafeCollection : NSObject

@property (nonatomic, readonly, strong) id collection;

+ (instancetype)safeCollectionWithCollection:(id)collection;

- (instancetype)initWithCollection:(id)collection;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;
- (id)objectAtIndex:(NSUInteger)idx;
- (id)objectForKey:(id<NSCopying>)key;

- (id)copy;
- (id)mutableCopy;

@end
