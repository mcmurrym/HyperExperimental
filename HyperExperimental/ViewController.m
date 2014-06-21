//
//  ViewController.m
//  HyperExperimental
//
//  Created by Matt McMurry on 6/17/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "ViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "HyperTableViewController.h"
#import "WebViewController.h"

NSString * const CellIdentifier = @"CELL";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *hyper;
@property (nonatomic, strong) NSArray *keyOrder;

@end

@implementation ViewController

- (id)initWithHyperObject:(NSMutableDictionary *)hyperObject {
    self = [super init];
    
    self.hyper = hyperObject;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];

    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView constrainHeightToView:self.view predicate:nil];
    [self.tableView constrainWidthToView:self.view predicate:nil];
    [self.tableView alignCenterWithView:self.view];

    self.title = self.hyper[HyperDictionaryKeyHref];
    
    NSString *loading = [NSString stringWithFormat:@"Loading: %@", self.hyper[HyperDictionaryKeyHref]];
    
    [SVProgressHUD showWithStatus:loading];
    
    __block WebViewController *wvc;
    __block HyperTableViewController *hyperVc;
    
    [self.hyper GET:^(NSMutableDictionary *dictionary, BOOL succeded, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if ([dictionary isExternalResource]) {
            NSString *urlString = dictionary[HyperDictionaryKeyURL];
            
            if (wvc) {
                [wvc reloadWithURL:urlString];
            } else {
                wvc = [[WebViewController alloc] initWithURL:urlString];
                wvc.view.frame = self.view.frame;
                [self addChildViewController:wvc];
                [self.view addSubview:wvc.view];
            }
            
            
        } else if ([dictionary isCollection]) {
            
            if (hyperVc) {
                [hyperVc reloadData];
            } else {
                hyperVc = [[HyperTableViewController alloc] initWithHyperCollection:dictionary];
                hyperVc.view.frame = self.view.frame;
                [self addChildViewController:hyperVc];
                [self.view addSubview:hyperVc.view];
            }
            
        } else {
            self.keyOrder = dictionary.allKeys;
            [self.tableView reloadData];
        }
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.keyOrder.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    }
    
    id object = self.hyper[self.keyOrder[indexPath.row]];
    
    cell.textLabel.text = self.keyOrder[indexPath.row];
    
    if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = [object description];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = self.hyper[self.keyOrder[indexPath.row]];

    if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictionary = (NSMutableDictionary *)object;
        
        ViewController *vc = [[ViewController alloc] initWithHyperObject:dictionary];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
@end
