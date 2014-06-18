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

- (id)initWithLoadedObject:(NSMutableDictionary *)hyperObject {
    self = [super init];
    
    self.hyper = hyperObject;
    self.keyOrder = hyperObject.allKeys;
    
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

    
    self.title = self.hyper[HyperDictionaryKeyHref];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.hyper.count;
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
        
        NSString *loading = [NSString stringWithFormat:@"Loading: %@", dictionary[HyperDictionaryKeyHref]];
        
        [SVProgressHUD showWithStatus:loading];
        
        [dictionary GET:^(NSMutableDictionary *dictionary, BOOL succeded, NSError *error) {
            if (succeded) {
                [SVProgressHUD dismiss];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                if ([dictionary isExternalResource]) {
                    NSString *urlString = dictionary[HyperDictionaryKeyURL];
                    
                    WebViewController *wvc = [[WebViewController alloc] initWithURL:urlString];
                    
                    [self.navigationController pushViewController:wvc animated:YES];
                } else if ([dictionary isCollection]) {
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
@end
