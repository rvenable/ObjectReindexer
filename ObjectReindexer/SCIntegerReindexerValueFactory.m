//
//  SCIntegerReindexerValueFactory.m
//  StoryCollections
//
//  Created by Richard Venable on 9/16/13.
//  Copyright (c) 2013 Epicfox. All rights reserved.
//

#import "SCIntegerReindexerValueFactory.h"

@implementation SCIntegerReindexerValueFactory

- (id)initWithFirstIndex:(NSInteger)firstIndex interval:(NSUInteger)interval
{
	self = [super init];
	if (self) {
		_firstIndex = firstIndex;
		_interval = interval;
	}
	return self;
}

- (id)objectReindexerOriginalIndexValue:(SCObjectReindexer *)objectReindexer
{
	return [NSNumber numberWithInteger:self.firstIndex];
}

- (id)objectReindexer:(SCObjectReindexer *)objectReindexer nextFixedIntervalIndexValueAfterIndexValue:(NSNumber *)indexValue
{
	indexValue = [NSNumber numberWithInteger:indexValue.integerValue + self.interval];
	return indexValue;
}

- (id)objectReindexer:(SCObjectReindexer *)objectReindexer previousFixedIntervalIndexValueBeforeIndexValue:(NSNumber *)indexValue
{
	indexValue = [NSNumber numberWithInteger:indexValue.integerValue - self.interval];
	return indexValue;
}

@end
