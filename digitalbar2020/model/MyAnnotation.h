//
//  MyAnnotation.h
//  lancome
//
//  Created by diam on 2020/12/30.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyAnnotation : NSObject <MKAnnotation>
//重写三个属性
//坐标
@property (nonatomic) CLLocationCoordinate2D coordinate;

//标题
@property (nonatomic,copy) NSString *title;
//子标题
@property (nonatomic,copy) NSString *subtitle;
//自定义大头针
//显示图片
@property(nonatomic,strong) UIImage *image;


@end

NS_ASSUME_NONNULL_END
