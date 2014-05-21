//
//  ADCSafeCollection.m
//  SafeCollection
//
//  Created by Aaron Daub on 3/23/2014.
//
//

#import "ADCSafeCollection.h"

@implementation ADCSafeCollection

+ (instancetype)safeCollectionWithCollection:(id)collection{
    return [[self alloc] initWithCollection:collection];
}

- (instancetype)initWithCollection:(id)collection{
    if([self isObjectACollection:collection]){
        self->_collection = collection;
    }
    
    return self;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx{
    return [self objectAtIndex:idx];
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key{
    return [self objectForKey:key];
}

- (id)objectAtIndex:(NSUInteger)idx{
    if([self.collection isKindOfClass:[NSArray class]]){
        if(idx >= [self.collection count]){
            return nil;
        }
    }
    
    id obj = self.collection[idx];
    return [self stripNSNullObjectsAndWrapCollections:obj];
}

- (id)objectForKey:(id<NSCopying>)key{
    id obj = self.collection[key];
    return [self stripNSNullObjectsAndWrapCollections:obj];
}

- (id)stripNSNullObjectsAndWrapCollections:(id)obj{
    if(obj == [NSNull null]){
        obj = nil;
    }else if([self isObjectACollection:obj]){
        obj = [[self class] safeCollectionWithCollection:obj];
    }
    return obj;
}

- (id)copy{
    if([self.collection respondsToSelector:@selector(copy)]){
        return [self stripNSNullObjectsAndWrapCollections:[self.collection copy]];
    }
    return nil;
}

- (id)mutableCopy{
    if([self.collection respondsToSelector:@selector(mutableCopy)]){
        return [self stripNSNullObjectsAndWrapCollections:[self.collection mutableCopy]];
    }
    return nil;
}

- (NSString*)description{
    return [self.collection description];
}

- (NSString*)debugDescription{
    NSString* debugDescriptionPrefix = [NSString stringWithFormat:@"%@ of %@ \n", [self class], [self.collection class]];
    return [debugDescriptionPrefix stringByAppendingString:[self.collection debugDescription]];
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    if([self.collection respondsToSelector:aSelector]){
        return self.collection;
    }
    return nil;
}

- (void)doesNotRecognizeSelector:(SEL)aSelector{
  if(![self forwardingTargetForSelector:aSelector]){
    return;
  }
  
  [super doesNotRecognizeSelector:aSelector];
}

- (BOOL)isObjectACollection:(id)object{
    return ([object respondsToSelector:@selector(objectAtIndexedSubscript:)] || [object respondsToSelector:@selector(objectForKeyedSubscript:)]);
}



@end
