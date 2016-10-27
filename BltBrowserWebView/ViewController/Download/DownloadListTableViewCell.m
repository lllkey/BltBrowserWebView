//
//  DownloadListTableViewCell.m
//  TSG-Phone
//
//  Created by lsq on 16/9/7.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import "DownloadListTableViewCell.h"
#import "BltDownloadItem+CoreDataProperties.h"
#import "BLTDownloaderManager.h"
#import "Utils.h"

@interface DownloadListTableViewCell()
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *openBtn;
@property (weak, nonatomic) IBOutlet UIButton *delBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnViewConstraint;

@end

@implementation DownloadListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void)updateCellWithDownloadItem:(BltDownloadItem *)downloadItem andTableView:(UITableView*)tableView {
    [_btnView setHidden:YES];
    //    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //    float cellHeight = size.height + 1.0f; // Add 1.0f for the cell separator height
    //    NSLog(@"cellHeight  %f",cellHeight);
    
    BLTURLDownloadStatus status = (BLTURLDownloadStatus)[downloadItem.state integerValue];
    self.titleLabel.text = downloadItem.name;
    if(status == BLTURLDownloadStatusSucceeded){
        self.descLabel.text = [NSString stringWithFormat:@"已下载 大小：%@",[NSString stringByFormattingBytesLength:downloadItem.downloadedSize]];
        [_stopBtn setTitle:@"打开" forState:UIControlStateNormal];
        [_btnView setHidden:NO];
        
    }else if(status == BLTURLDownloadStatusDownloadFailed){
        self.descLabel.text = @"下载失败";
        [_stopBtn setTitle:@"重新开始" forState:UIControlStateNormal];
    }else if(status == BLTURLDownloadStatusWaiting){
        if([[BLTDownloaderManager sharedDownloaderManager]isDownloadingWithURL:downloadItem.downloadURL andName:downloadItem.name]){
            self.descLabel.text = @"等待中";
            [_stopBtn setTitle:@"暂停" forState:UIControlStateNormal];
        }else{
            self.descLabel.text = [NSString stringWithFormat:@"已暂停 大小：%@",[NSString stringByFormattingBytesLength:downloadItem.downloadedSize]];
            [_stopBtn setTitle:@"开始" forState:UIControlStateNormal];
        }
    }else{
        if([[BLTDownloaderManager sharedDownloaderManager]isDownloadingWithURL:downloadItem.downloadURL andName:downloadItem.name]){
            self.descLabel.text = [NSString stringWithFormat:@"正在下载:%@ / %@",[NSString stringByFormattingBytesLength:downloadItem.downloadedSize],downloadItem.totalSize?[NSString stringByFormattingBytesLength:downloadItem.totalSize]:@"未知"];
            [_stopBtn setTitle:@"暂停" forState:UIControlStateNormal];
        }else{
            self.descLabel.text = [NSString stringWithFormat:@"已暂停:%@ / %@",[NSString stringByFormattingBytesLength:downloadItem.downloadedSize],downloadItem.totalSize?[NSString stringByFormattingBytesLength:downloadItem.totalSize]:@"未知"];
            [_stopBtn setTitle:@"开始" forState:UIControlStateNormal];
        }
    }
    if([_btnView isHidden]){
        [_btnViewConstraint setConstant:.0f];
        
    }else{
        [_btnViewConstraint setConstant:40.0f];
    }
    
}
- (IBAction)openClicked:(id)sender {
    self.openClickedBlock(self);
}
- (IBAction)delClicked:(id)sender {
    self.delClickedBlock(self);
}
- (IBAction)stopClicked:(id)sender {
    self.stopClickedBlock(self);
}

@end
