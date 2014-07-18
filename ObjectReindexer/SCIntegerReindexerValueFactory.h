//
//  SCIntegerReindexerValueFactory.h
//  StoryCollections
//
//  Created by Richard Venable on 9/16/13.
//  Copyright (c) 2013 Epicfox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCObjectReindexer.h"

@interface SCIntegerReindexerValueFactory : NSObject <SCObjectReindexerValueFactory>

@property (nonatomic, readonly) NSInteger firstIndex;
@property (nonatomic, readonly) NSUInteger interval;

- (id)initWithFirstIndex:(NSInteger)firstIndex interval:(NSUInteger)interval;

@end
