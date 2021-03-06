//
// Created by akinsella on 26/03/13.
//


#import "XBInfiniteArrayDataSource.h"
#import "XBReloadableArrayDataSource+Protected.h"
#import "XBLogging.h"
#import "XBArrayDataSource+Protected.h"


static dispatch_queue_t reloadable_datasource_merging_queue() {
    static dispatch_queue_t xbtoolkit_reloadable_datasource_merging_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xbtoolkit_reloadable_datasource_merging_queue = dispatch_queue_create("fr.xbtoolkit.datasource.reloadable.merging", DISPATCH_QUEUE_CONCURRENT);
    });

    return xbtoolkit_reloadable_datasource_merging_queue;
}


@interface XBInfiniteArrayDataSource ()

@property (nonatomic, strong) id <XBDataPager> dataPager;

@property (nonatomic, strong) id <XBDataMerger> dataMerger;

@end


@implementation XBInfiniteArrayDataSource

- (instancetype)initWithDataLoader:(id <XBDataLoader>)dataLoader dataMerger:(id <XBDataMerger>)dataMerger dataPager:(id <XBDataPager>)dataPager
{
    self = [super initWithDataLoader:dataLoader];
    if (self) {
        self.dataPager = dataPager;
        self.dataMerger = dataMerger;
    }

    return self;
}

+ (instancetype)dataSourceWithDataLoader:(id <XBDataLoader>)dataLoader dataMerger:(id <XBDataMerger>)dataMerger dataPager:(id <XBDataPager>)dataPager
{
    return [[self alloc] initWithDataLoader:dataLoader dataMerger:dataMerger dataPager:dataPager];
}

- (BOOL)hasMoreData
{
    return [self.dataPager hasMorePages];
}

- (void)loadData:(XBReloadableArrayDataSourceCompletionBlock)completion
{
    [self loadData:completion queue:dispatch_get_main_queue()];
}

- (void)loadData:(XBReloadableArrayDataSourceCompletionBlock)completion queue:(dispatch_queue_t)queue
{
    [self.dataPager resetPageIncrement];
    [self fetchDataFromSource:completion queue:queue];
}

- (void)loadMoreData:(XBReloadableArrayDataSourceCompletionBlock)completion
{
    [self loadMoreData:completion queue:dispatch_get_main_queue()];
}

- (void)loadMoreData:(XBReloadableArrayDataSourceCompletionBlock)completion queue:(dispatch_queue_t)queue
{
    if ([self hasMoreData]) {
        [self.dataPager incrementPage];
        [self fetchDataFromSourceAndMerge:completion queue:queue];
    } else {
        if (completion) {
            completion(nil);
        }
    }
}

- (void)fetchDataFromSource:(XBReloadableArrayDataSourceCompletionBlock)completion queue:(dispatch_queue_t)queue
{
    [self.dataLoader loadDataWithSuccess:^(NSOperation *operation, id jsonFetched) {
        self.error = nil;
        dispatch_async(reloadable_datasource_merging_queue(), ^{
            id mergedObjects = jsonFetched;
            dispatch_async(queue, ^{
                [super processSuccessForResponseObject:mergedObjects completion:^{
                    if (completion) {
                        completion(operation);
                    }
                } queue:queue];
            });
        });
    } failure:^(NSOperation *operation, id responseObject, NSError *error) {
        XBLogWarn(@"Error: %@", error);
        self.error = error;
        if (completion) {
            completion(operation);
        }
    } queue:queue];
}

- (void)fetchDataFromSourceAndMerge:(XBReloadableArrayDataSourceCompletionBlock)completion queue:(dispatch_queue_t)queue
{
    [self.dataLoader loadDataWithSuccess:^(NSOperation *operation, id jsonFetched) {
        self.error = nil;
        dispatch_async(reloadable_datasource_merging_queue(), ^{
            id mergedObjects = self.dataMerger ? [self mergeObjects:jsonFetched] : jsonFetched;
            dispatch_async(queue, ^{
                [super processSuccessForResponseObject:mergedObjects completion:^{
                    if (completion) {
                        completion(operation);
                    }
                } queue:queue];
            });
        });

    } failure:^(NSOperation *operation, id responseObject, NSError *error) {
        XBLogWarn(@"Error: %@", error);
        self.error = error;
        if (completion) {
            completion(operation);
        }
    } queue:queue];
}

- (id)mergeObjects:(id)responseObject
{
    return [self.dataMerger mergeDataOfSource:responseObject withSource:self.sourceArray];
}

@end
