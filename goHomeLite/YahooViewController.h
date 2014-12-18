//
//  YahooViewController.h
//  goHomeLite
//
//  Created by 石井嗣 on 2014/12/17.
//  Copyright (c) 2014年 YuZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YahooViewController : UIViewController<UISearchDisplayDelegate,UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *TableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchField;

@end
