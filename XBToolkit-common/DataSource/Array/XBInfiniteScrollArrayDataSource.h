//
// Created by akinsella on 26/03/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "XBInfiniteScrollArrayDataSource.h"
#import "XBReloadableArrayDataSource.h"
#import "XBDataPager.h"
#import "XBDataMerger.h"

@interface XBInfiniteScrollArrayDataSource : XBReloadableArrayDataSource

- (id)initWithDataLoader:(id <XBDataLoader>)dataLoader dataMapper:(id <XBDataMapper>)dataMapper dataMerger:(id <XBDataMerger>)dataMerger dataPager:(id <XBDataPager>)dataPager;

+ (instancetype)dataSourceWithDataLoader:(id <XBDataLoader>)dataLoader dataMapper:(id <XBDataMapper>)dataMapper dataMerger:(id <XBDataMerger>)dataMerger dataPager:(id <XBDataPager>)dataPager;

- (id)mergeRawData:(id)rawData;

- (void)loadMoreDataWithCallback:(void(^)())callback;

- (BOOL)hasMoreData;

@end