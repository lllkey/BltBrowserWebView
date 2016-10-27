//
//  DownloadListTableViewCell.h
//  TSG-Phone
//
//  Created by lsq on 16/9/7.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BltDownloadItem;

@interface DownloadListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UIView *btnView;

@property (nonatomic) void (^stopClickedBlock)(DownloadListTableViewCell *cell);
@property (nonatomic) void (^openClickedBlock)(DownloadListTableViewCell *cell);
@property (nonatomic) void (^delClickedBlock)(DownloadListTableViewCell *cell);

- (void)updateCellWithDownloadItem:(BltDownloadItem *)downloadItem andTableView:(UITableView*)tableView;

@end
