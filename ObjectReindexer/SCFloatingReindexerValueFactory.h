//
//  SCFloatingReindexerValueFactory.h
//  StoryCollections
//
//  Created by Richard Venable on 9/16/13.
//  Copyright (c) 2013 Epicfox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCObjectReindexer.h"

@interface SCFloatingReindexerValueFactory : NSObject <SCObjectReindexerValueFactory>

@property (nonatomic, readonly) double firstIndex;
@property (nonatomic, readonly) double initialInterval;

- (id)initWithFirstIndex:(double)firstIndex initialInterval:(double)initialInterval;

@end
