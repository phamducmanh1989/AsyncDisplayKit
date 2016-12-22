//
//  PhotoFeedSectionController.m
//  Sample
//
//  Created by Adlai Holler on 12/29/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "PhotoFeedSectionController.h"
#import "PhotoFeedModel.h"
#import "PhotoModel.h"
#import "PhotoCellNode.h"

@interface PhotoFeedSectionController ()
@property (nonatomic, strong) NSString *paginatingSpinner;
@end

@implementation PhotoFeedSectionController

- (instancetype)init
{
  if (self = [super init]) {
    _paginatingSpinner = @"Paginating Spinner";
  }
  return self;
}

- (void)didUpdateToObject:(id)object
{
  _photoFeed = object;
  [self setItems:_photoFeed.photos animated:NO completion:nil];
}

- (ASCellNodeBlock)nodeBlockForItemAtIndex:(NSInteger)index
{
  id object = self.items[index];
  // this will be executed on a background thread - important to make sure it's thread safe
  ASCellNode *(^nodeBlock)() = nil;
  if (object == _paginatingSpinner) {
    nodeBlock = ^{
      ASCellNode *spinnerNode = [[ASCellNode alloc] initWithViewBlock:^{
        UIActivityIndicatorView *v = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [v startAnimating];
        return v;
      }];
      spinnerNode.style.height = ASDimensionMake(100);
      return spinnerNode;
    };
  } else if ([object isKindOfClass:[PhotoModel class]]) {
    PhotoModel *photoModel = object;
    nodeBlock = ^{
      PhotoCellNode *cellNode = [[PhotoCellNode alloc] initWithPhotoObject:photoModel];
      return cellNode;
    };
  }

  return nodeBlock;
}

- (void)beginBatchFetchWithContext:(ASBatchContext *)context
{
  if (self.items.count > 0) {
    NSArray *newItems = [self.items arrayByAddingObject:_paginatingSpinner];
    [self setItems:newItems animated:YES completion:nil];
  }

  [_photoFeed requestPageWithCompletionBlock:^(NSArray *newPhotos){
    [self setItems:_photoFeed.photos animated:YES completion:^{
      [context completeBatchFetching:YES];
    }];
  } numResultsToReturn:20];
}

- (void)didSelectItemAtIndex:(NSInteger)index
{
  // nop
}

- (void)refreshContentWithCompletion:(void(^)())completion
{
  [_photoFeed refreshFeedWithCompletionBlock:^(NSArray *addedItems) {
    [self setItems:_photoFeed.photos animated:YES completion:completion];
  } numResultsToReturn:4];
}

ASIGSectionControllerSizeForItemImplementation;
ASIGSectionControllerCellForIndexImplementation;

@end
