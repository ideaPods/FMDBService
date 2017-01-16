//
//  ViewController.m
//  SQLDBDemo
//
//  Created by williamqiu on 17/1/16.
//  Copyright © 2017年 TVM. All rights reserved.
//

#import "ViewController.h"
#import "FMDBService.h"

@interface ViewController ()
@property (nonatomic, strong)FMDBService *dbService;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dbService = [[FMDBService alloc] initWithDBName:@"cachedb"];
    BOOL encrptKeyOK = [self.dbService setKey:@"BHFI30AH390278947A96TT"];
    NSLog(@"\n\ncreate DB(%d):%@\n%@\n\n", encrptKeyOK, self.dbService, [self.dbService getAllPropertysString]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
