
//
//  DownloadListViewController.m
//  TSG-Phone
//
//  Created by lsq on 16/9/7.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import "DownloadListViewController.h"
#import "BltDownloadItem+CoreDataProperties.h"
#import "BltDownloaderDatabaseManager.h"
#import "DownloadListTableViewCell.h"
#import "BLTDownloaderManager.h"
#import "Utils.h"
#import "DownloaderUtils.h"
#import "QuickLook/QLPreviewController.h"

@interface DownloadListViewController () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (copy, nonatomic) NSString *sectionName;
@property (nonatomic) NSString *userID;

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, retain) NSString *curOpenFilePath;

//@property (nonatomic, retain) NSMutableArray *isExpandArray;
@end

@implementation DownloadListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 110;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"下载管理";
    self.navigationController.toolbarHidden=YES;
    
    [self reloadDownloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error]; // Refetch data
    if (error != nil) {
        // handle error
    }
    
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)reloadDownloadData {
    if (self.fetchedResultsController) {
        self.fetchedResultsController.delegate = nil;
        self.fetchedResultsController = nil;
        [self.fetchedResultsController performFetch:nil];
        [self.tableView reloadData];
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    self.userID = [Config getAccountId];
    
    if (!_fetchedResultsController) {
        NSManagedObjectContext *mainContext = [BltDownloaderDatabaseManager mainManagedObjectContext];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:TableName_Downloader];
        request.sortDescriptors = @[
                                    [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:NO],
                                    ];
//        request.sortDescriptors = @[
//                                    [NSSortDescriptor sortDescriptorWithKey:@"state" ascending:YES],
//                                    [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:NO],
//                                    ];
        
        request.predicate  = [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"userId = %@", self.userID]]];
        //_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:mainContext sectionNameKeyPath:self.sectionName cacheName:nil];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:mainContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        //        self.isExpandArray = [NSMutableArray array];
        //        for(int i = 0;i<[_fetchedResultsController accessibilityElementCount];i++){
        //            [self.isExpandArray addObject:[NSNumber numberWithBool:YES]];
        //        }
    }
    return _fetchedResultsController;
}
-(NSString*)sectionName{
    if(_sectionName == nil){
        _sectionName = @"state";
    }
    return _sectionName;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger numberOfSections = [self.fetchedResultsController.sections count];
    //    tableView.tableFooterView.hidden = [self.fetchedResultsController.fetchedObjects count] == 0;
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
////    if (!self.sectionName) {
////        return 0.0f;
////    }
//    return 50;
//}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([_fetchedResultsController.sections[section].indexTitle isEqualToString:[NSString stringWithFormat:@"%ld",(long)BLTURLDownloadStatusSucceeded]]){
        return @"已下载";
    }else if([_fetchedResultsController.sections[section].indexTitle isEqualToString:[NSString stringWithFormat:@"%ld",(long)BLTURLDownloadStatusPaused]]){
        return @"暂停中";
    }else if([_fetchedResultsController.sections[section].indexTitle isEqualToString:[NSString stringWithFormat:@"%ld",(long)BLTURLDownloadStatusDownloading]]){
        return @"下载中";
    }else if([_fetchedResultsController.sections[section].indexTitle isEqualToString:[NSString stringWithFormat:@"%ld",(long)BLTURLDownloadStatusDownloadFailed]]){
        return @"下载失败";
    }else if([_fetchedResultsController.sections[section].indexTitle isEqualToString:[NSString stringWithFormat:@"%ld",(long)BLTURLDownloadStatusWaiting]]){
        return @"等待中";
    }else if([_fetchedResultsController.sections[section].indexTitle isEqualToString:[NSString stringWithFormat:@"%ld",(long)BLTURLDownloadStatusProcessing]]){
        return @"处理中";
    }
    return _fetchedResultsController.sections[section].indexTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadListTableViewCell" forIndexPath:indexPath];
    BltDownloadItem *downloadItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //    cell.delegate = self;
    [cell updateCellWithDownloadItem:downloadItem andTableView:self.tableView];
    cell.stopClickedBlock = ^(DownloadListTableViewCell *cell){
        BLTURLDownloadStatus status = (BLTURLDownloadStatus)[downloadItem.state integerValue];
        if (status == BLTURLDownloadStatusSucceeded) {
            //            [self performOtherActionForCell:(UITableViewCell <BLTDownloaderTableViewCellProtocol> *)[tableView cellForRowAtIndexPath:indexPath]];
            [self openFile:[DownloaderUtils getPathStrByFileName:downloadItem.name andUserId:[Config getAccountId]]];
        }else if (status == BLTURLDownloadStatusDownloading || status == BLTURLDownloadStatusWaiting) {
            if([[BLTDownloaderManager sharedDownloaderManager]isDownloadingWithURL:downloadItem.downloadURL andName:downloadItem.name]){
                [[BLTDownloaderManager sharedDownloaderManager]pauseWithURL:downloadItem.downloadURL andName:downloadItem.name];
                [self.tableView reloadData];
            }else{
                [[BLTDownloaderManager sharedDownloaderManager]downLoadWithURL:[NSURL URLWithString:downloadItem.downloadURL] andCookie:nil andHeaderFields:nil andName:downloadItem.name progress:nil completion:nil failed:nil];
                [self.tableView reloadData];
            }
        }else if(status == BLTURLDownloadStatusDownloadFailed){
            
            [[BLTDownloaderManager sharedDownloaderManager]downLoadWithURL:[NSURL URLWithString:downloadItem.downloadURL] andCookie:nil andHeaderFields:nil andName:downloadItem.name progress:nil completion:nil failed:nil];
            [self.tableView reloadData];
        }
    };
    cell.delClickedBlock = ^(DownloadListTableViewCell *cell){
//        BltDownloadItem *downloadItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除" message:[NSString stringWithFormat:@"确定删除文件%@？",downloadItem.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            BltDownloaderDatabaseManager *coreDataManager = [[BltDownloaderDatabaseManager alloc] init];
            [coreDataManager deleteDownloadItemWithIdentifier:[NSMutableDictionary dictionaryWithObjectsAndKeys:downloadItem.name,@"name", nil]];
            //            NSLog(@"%@",downloadItem.targetPath);
            [DownloaderUtils deleteFileByPath:[DownloaderUtils getPathStrByFileName:downloadItem.name andUserId:[Config getAccountId]]];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:^{ }];
    };
    cell.openClickedBlock = ^(DownloadListTableViewCell *cell){
//        BltDownloadItem *downloadItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self openDocumentByPath:[DownloaderUtils getPathStrByFileName:downloadItem.name andUserId:[Config getAccountId]]];
    };
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //BltDownloadItem *downloadItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //BLTURLDownloadStatus status = (BLTURLDownloadStatus)[downloadItem.state integerValue];
    //return status != BLTURLDownloadStatusProcessing;
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //        [self deleteDownloadItemAtIndexPath:indexPath];
        BltDownloadItem *downloadItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        BLTURLDownloadStatus status = (BLTURLDownloadStatus)[downloadItem.state integerValue];
        if (status != BLTURLDownloadStatusSucceeded) {
            //取消
            //            downloadItem.state = [NSNumber numberWithInt:BLTURLDownloadStatusDownloadFailed];
        }else{
            //删除
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    BltDownloadItem *downloadItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    BLTURLDownloadStatus status = (BLTURLDownloadStatus)[downloadItem.state integerValue];
    if (status != BLTURLDownloadStatusSucceeded) {
        return NSLocalizedString(@"取消", @"");
    }
    return NSLocalizedString(@"删除", @"");
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //        BltDownloadItem *downloadItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        //        BLTURLDownloadStatus status = (BLTURLDownloadStatus)[downloadItem.state integerValue];
        //        if (status == BLTURLDownloadStatusSucceeded) {
        //            //            [self performOtherActionForCell:(UITableViewCell <BLTDownloaderTableViewCellProtocol> *)[tableView cellForRowAtIndexPath:indexPath]];
        //        }else if (status == BLTURLDownloadStatusDownloading || status == BLTURLDownloadStatusWaiting) {
        //            if([[BLTDownloaderManager sharedDownloaderManager]isDownloadingWithURL:downloadItem.downloadURL andName:downloadItem.name]){
        //                [[BLTDownloaderManager sharedDownloaderManager]pauseWithURL:downloadItem.downloadURL andName:downloadItem.name];
        //                [self.tableView reloadData];
        //            }else{
        //                [[BLTDownloaderManager sharedDownloaderManager]downLoadWithURL:[NSURL URLWithString:downloadItem.downloadURL] andName:downloadItem.name progress:nil completion:nil failed:nil];
        //                [self.tableView reloadData];
        //            }
        //        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSLogD(@"didChangeObject type  %lu",(unsigned long)type);
    //  NSLogD(@"didChangeObject anObject  %@",anObject);
    //  NSLog(@"    didChangeObject type=%d indexPath=%@ newIndexPath=%@", type, indexPath, newIndexPath);
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            NSLogD(@"NSFetchedResultsChangeInsert");
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            NSLogD(@"NSFetchedResultsChangeDelete");
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            //        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //      [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            //            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            
            //       NSLogD(@"NSFetchedResultsChangeMove  indexPath %ld %ld     newIndexPath  %ld %ld",(long)indexPath.section,(long)indexPath.row,(long)newIndexPath.section,(long)newIndexPath.row);
            [self.tableView reloadData];
            //            if(newIndexPath == nil)
            //                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //            else
            //                [self.tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            //
            //            DownloadListTableViewCell *cell = (DownloadListTableViewCell *)[self.tableView cellForRowAtIndexPath:newIndexPath];
            //            [cell updateCellWithDownloadItem:anObject];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            //            if(indexPath.section != indexPath.section){
            //                if(indexPath)
            //                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            //                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //            }
            //         if(indexPath.section != indexPath.section   ||  indexPath.row != indexPath.row){
            //                         [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //                         [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //         }
            
            if(newIndexPath == nil)
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            else
                [self.tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            if(!newIndexPath){
                DownloadListTableViewCell *cell = (DownloadListTableViewCell *)[self.tableView cellForRowAtIndexPath:newIndexPath];
                [cell updateCellWithDownloadItem:anObject andTableView:self.tableView];
            }
            NSLogD(@"NSFetchedResultsChangeUpdate  indexPath %ld %ld     newIndexPath  %ld %ld",(long)indexPath.section,(long)indexPath.row,(long)newIndexPath.section,(long)newIndexPath.row);
            break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSLogD(@"didChangeSection type  %lu     sectionIndex %lu",(unsigned long)type,(unsigned long)sectionIndex);
    switch (type) {
        case NSFetchedResultsChangeDelete: {
            NSLogD(@"NSFetchedResultsChangeDelete");
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeInsert: {
            NSLogD(@"NSFetchedResultsChangeInsert");
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        default:
            break;
    }
}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSLogD(@"controllerWillChangeContent");
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLogD(@"controllerDidChangeContent");
    [self.tableView endUpdates];
}

#pragma mark  -  open in other way
-(void)openDocumentByPath:(NSString*)filePath{
    _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    [_documentInteractionController setDelegate:self];
    //含预览
    [_documentInteractionController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
    //    [_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}
#pragma mark  open delegate
- (UIViewController*)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController*)controller{
    NSLogD(@"documentInteractionControllerViewControllerForPreview");
    return self;
}
- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller{
    NSLogD(@"documentInteractionControllerViewForPreview");
    return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller{
    NSLogD(@"documentInteractionControllerRectForPreview");
    
    return self.view.frame;
}
#pragma mark  -  open in quicklook
-(void)openFile:(NSString*)filePath{
//    [self showAllFilesbyPath:[filePath stringByDeletingLastPathComponent]];
    self.curOpenFilePath = filePath;
    QLPreviewController *myQlPreViewController = [[QLPreviewController alloc]init];
    myQlPreViewController.delegate = self;
    myQlPreViewController.dataSource = self;
    [myQlPreViewController setCurrentPreviewItemIndex:0];
    [self presentViewController:myQlPreViewController animated:YES completion:nil];
}
-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}
-(id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    return [NSURL fileURLWithPath:self.curOpenFilePath];
}
-(void )showAllFilesbyPath:(NSString*)path{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *array = [[NSArray alloc] init];
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        array = [fileManager contentsOfDirectoryAtPath:path error:&error];
        NSLogD(@"路径==%@,array%@",path,array);
}
@end
