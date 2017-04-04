//
//  ViewController.m
//  ZSPhotoImageController
//
//  Created by 周松 on 17/4/2.
//  Copyright © 2017年 周松. All rights reserved.
//
#import "ViewController.h"
#import "TZImagePickerController.h"
#import "TZAssetModel.h"
#import "TZImageManager.h"
static NSString *resultId = @"CollectionViewCell";
@interface ViewController ()<TZImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,weak) UIButton *addImageButton;
@property (nonatomic,strong) NSArray *pictureArray;//存储选中的图片
@property (nonatomic,weak) UICollectionView *collectionView;//展示选中的图片
@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic,assign) BOOL isAllowCut;//是否允许裁剪
@property (nonatomic,strong) NSMutableArray *selectArray;//裁剪的图片存储
@property (nonatomic,strong) NSArray *assetArray;
@end

@implementation ViewController
#pragma mark --懒加载
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(30, 30, self.view.bounds.size.width - 40 , self.view.bounds.size.width - 40) collectionViewLayout:self.flowLayout];
        [self.view addSubview:collectionView];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        self.flowLayout.minimumInteritemSpacing = 5;
        self.flowLayout.minimumLineSpacing = 5;
        self.flowLayout.itemSize = CGSizeMake((self.view.bounds.size.width - 40 - 10) / 3, (self.view.bounds.size.width - 40 - 10) / 3);
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:resultId];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (NSArray *)pictureArray {
    if (_pictureArray == nil) {
        _pictureArray = [NSArray array];
    }
    return _pictureArray;
}

- (NSMutableArray *)selectArray {
    if (_selectArray == nil) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}

- (UIButton *)addImageButton {
    if (_addImageButton == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:button];
        [button setBackgroundImage:[UIImage imageNamed:@"AlbumAddBtn"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(addImageButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _addImageButton = button;
    }
    return _addImageButton;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.addImageButton.frame = CGRectMake(150, 350, 70, 70);
}
//按钮的点击事件
- (void)addImageButtonClick {
    __weak typeof(self)weakSelf = self;
    
    //不允许裁剪，初始化方法不一样
    if (self.isAllowCut == NO) {
        TZImagePickerController *pickerController = [[TZImagePickerController alloc]initWithMaxImagesCount:9 delegate:self];
        pickerController.naviBgColor = [UIColor greenColor];
        pickerController.needCircleCrop = YES;
        pickerController.circleCropRadius = 100;
        [pickerController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photo, NSArray *assets, BOOL isSelectOriginalPhoto) {
            if (photo.count) {
                weakSelf.pictureArray = photo;
                [weakSelf.collectionView reloadData];
            }
            
        }];

        [self presentViewController:pickerController animated:YES completion:nil];
    } else if (self.isAllowCut == YES) {//允许裁剪
        TZImagePickerController *pickerController = [[TZImagePickerController alloc]initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
        pickerController.allowCrop = YES;
        pickerController.needCircleCrop = YES;
        pickerController.circleCropRadius = 100;
        [pickerController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photo, NSArray * assets, BOOL isSelectOriginalPhoto) {
            self.selectArray= photo.mutableCopy;
            NSLog(@"photo == %@, assets == %@",photo,assets);
            [weakSelf.collectionView reloadData];
        }];
        [self presentViewController:pickerController animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.flowLayout = [[UICollectionViewFlowLayout alloc]init];
    //在这里修改是选取图片还是截图
    self.isAllowCut = YES;
}

#pragma  mark -- UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.isAllowCut == NO) {
        return self.pictureArray.count;
    } else {
        return self.selectArray.count;
    }

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:resultId forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:self.isAllowCut == NO ? self.pictureArray[indexPath.item] : self.selectArray[indexPath.item]];
    imageView.frame = cell.bounds;
    [cell.contentView addSubview:imageView];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
