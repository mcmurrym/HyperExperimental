//
//  ViewController.m
//  HyperExperimental
//
//  Created by Matt McMurry on 6/17/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "ViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

NSString * const CellIdentifier = @"CELL";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *hyper;
@property (nonatomic, strong) NSArray *keyOrder;
@property (nonatomic, strong) NSArray *arrayObject;

@end

@implementation ViewController

- (id)initWithLoadedObject:(NSMutableDictionary *)hyperObject {
    self = [super init];
    
    self.hyper = hyperObject;
    self.keyOrder = hyperObject.allKeys;
    
    return self;
}

- (id)initWithArrayObject:(NSMutableArray *)arrayObject {
    self = [super init];
    
    self.arrayObject = arrayObject;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];

//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
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
    
    if (self.arrayObject.count) {
        return self.arrayObject.count;
    } else {
        return self.hyper.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (self.arrayObject) {
        id object = self.arrayObject[indexPath.row];
        cell.textLabel.text = object[HyperDictionaryKeyHref]?object[HyperDictionaryKeyHref]:[object description];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
    
        id object = self.hyper[self.keyOrder[indexPath.row]];
        
        cell.textLabel.text = self.keyOrder[indexPath.row];
        
        if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = nil;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.detailTextLabel.text = [object description];
        }
        
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object;
    
    if (self.arrayObject) {
        object = self.arrayObject[indexPath.row];
    } else {
        object = self.hyper[self.keyOrder[indexPath.row]];
    }

    if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictionary = (NSMutableDictionary *)object;
        
        NSString *loading = [NSString stringWithFormat:@"Loading: %@", dictionary[HyperDictionaryKeyHref]];
        
        [SVProgressHUD showWithStatus:loading];
        
        [dictionary GET:^(NSMutableDictionary *dictionary, BOOL succeded, NSError *error) {
            if (succeded) {
                [SVProgressHUD dismiss];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                ViewController *vc = [[ViewController alloc] initWithLoadedObject:dictionary];
                
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }];
    } else if ([object isKindOfClass:[NSArray class]]) {
        ViewController *vc = [[ViewController alloc] initWithArrayObject:object];
        vc.title = @"Collection";
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
@end
