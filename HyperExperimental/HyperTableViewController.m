//
//  HyperTableViewController.m
//  HyperExperimental
//
//  Created by Matt McMurry on 6/18/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "HyperTableViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ViewController.h"

CGFloat const ThresholdToLoadMore = .85;
NSString * const HypeCollectionCellIdentifier = @"CELL";

@interface HyperTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *hyperCollection;

@end

@implementation HyperTableViewController

- (id)initWithHyperCollection:(NSMutableDictionary *)hyperCollection {
    self = [super init];
    
    self.hyperCollection = hyperCollection;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView constrainHeightToView:self.view predicate:nil];
    [self.tableView constrainWidthToView:self.view predicate:nil];
    [self.tableView alignCenterWithView:self.view];
    
    
    self.title = self.hyperCollection[HyperDictionaryKeyHref];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.hyperCollection[HyperDictionaryKeyCollection] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HypeCollectionCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HypeCollectionCellIdentifier];
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    }
    
    NSArray *objects = self.hyperCollection[HyperDictionaryKeyCollection];
    
    NSMutableDictionary *object = objects[indexPath.row];
    
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = object[HyperDictionaryKeyHref];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *objects = self.hyperCollection[HyperDictionaryKeyCollection];
    
    NSMutableDictionary *object = objects[indexPath.row];
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictionary = (NSMutableDictionary *)object;
        
        NSString *loading = [NSString stringWithFormat:@"Loading: %@", dictionary[HyperDictionaryKeyHref]];
        
        [SVProgressHUD showWithStatus:loading];
        
        [dictionary GET:^(NSMutableDictionary *dictionary, BOOL succeded, NSError *error) {
            if (succeded) {
                [SVProgressHUD dismiss];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                if ([dictionary isCollection]) {
                    HyperTableViewController *hyperVc = [[HyperTableViewController alloc] initWithHyperCollection:dictionary];
                    [self.navigationController pushViewController:hyperVc animated:YES];
                } else {
                    ViewController *vc = [[ViewController alloc] initWithLoadedObject:dictionary];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            } else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentSize.height > scrollView.bounds.size.height) {
        CGFloat height = scrollView.contentSize.height;
        CGFloat yOffset = scrollView.contentOffset.y + scrollView.bounds.size.height;
        
        CGFloat percentageToBottom = yOffset / height;
        
        if (percentageToBottom > ThresholdToLoadMore) {
            [self loadNext];
        }
    }
}

- (void)loadNext {
    if ([self.hyperCollection next]) {
        
        [SVProgressHUD showWithStatus:@"Loading More"];
        
        NSUInteger lastCount = [self.hyperCollection[HyperDictionaryKeyCollection] count];
        [self.hyperCollection GETNext:^(NSMutableDictionary *dictionary, NSUInteger addedCount, BOOL succeded, NSError *error) {
            [SVProgressHUD dismiss];
            if (succeded && addedCount > 0) {
                
                NSMutableArray *indexPaths = [NSMutableArray array];
                
                for (NSUInteger i = 0; i < addedCount; i++) {
                    NSUInteger row = lastCount + i;
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    
                    [indexPaths addObject:indexPath];
                }
                
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }
}
@end
