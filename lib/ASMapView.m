//
//  ASMapView.m
//  ASMapView
//
//  Created by Hasan on 6/4/14.
//  Copyright (c) 2014 AssembleLabs. All rights reserved.
//

#import "ASMapView.h"

typedef enum {
    ASMapViewTouchStateNormal,
    ASMapViewTouchStateZoomMode
} ASMapViewTouchState;

/*
 This indicates the amount of change in views display points via touch that
 triggers a zoom change
 */
NSInteger const kASMapViewTouchSensitivity = 4;
/*
 The base zoom factor is multiplied via velocity^2 to get the zoom factor
 */
double const kASMapViewBaseZoom = 2;

@interface ASMapView() <UIGestureRecognizerDelegate>

/**
 The location of a touch began event, used to check if a 2nd touch is receieved at the same location.
 */
@property (nonatomic, assign) CGPoint zoomTouchLocation;
/**
 The state of the view and if it should response to zoom panning
 */
@property (nonatomic, assign) ASMapViewTouchState zoomTouchState;

//@property (nonatomic, assign) NSInteger zoomMoveTouchCount;

-(void) applyZoom:(BOOL)increaseZoom;

@end

@implementation ASMapView

-(void) layoutSubviews
{
    static dispatch_once_t onceToken = 0;
    __weak typeof(self) weakMe = self;
    dispatch_once(&onceToken, ^{
        [weakMe setZoomTouchLocation:CGPointMake(FLT_MAX, FLT_MAX)];
    });
}

/*
#pragma mark touch handling

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 0) {
        return;
    }
    
    UITouch* touch = [[touches allObjects] firstObject];
    CGPoint newLocation = [touch locationInView:self];
    
    if (self.zoomTouchLocation.x == FLT_MAX && self.zoomTouchLocation.y == FLT_MAX) {
        [self setZoomTouchLocation:newLocation];
        [self setZoomTouchState:ASMapViewTouchStateNormal];
    }
    else {
        if (self.zoomTouchLocation.x == newLocation.x && self.zoomTouchLocation.y == newLocation.y) {
            [self setZoomTouchState:ASMapViewTouchStateZoomMode];
        }
        else {
            [self setZoomTouchState:ASMapViewTouchStateNormal];
        }
        
        [self setZoomTouchLocation:CGPointMake(FLT_MAX, FLT_MAX)];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 0) {
        return;
    }
    
    UITouch* touch = [[touches allObjects] firstObject];
    CGPoint prevLocation = [touch previousLocationInView:self];
    CGPoint newLocation = [touch locationInView:self];
    CGFloat deltaYPoint = newLocation.y - prevLocation.y;
    
    if (abs(deltaYPoint) > kASMapViewTouchSensitivity) {
        if (deltaYPoint < 0) {
            [self zoomOut];
        }
        else {
            [self zoomIn];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setZoomTouchState:ASMapViewTouchStateNormal];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setZoomTouchState:ASMapViewTouchStateNormal];
}
 */

#pragma mark - Zoom controls

-(void) zoomIn
{
    [self applyZoom:YES];
}

-(void) zoomOut
{
    [self applyZoom:NO];
}

-(void) applyZoom:(BOOL)increaseZoom
{
    CGFloat currentWidth = [self bounds].size.width;
    CGFloat currentHeight = [self bounds].size.height;
    
    MKCoordinateRegion currentRegion = [self region];
    double latitudePerPoint = currentRegion.span.latitudeDelta / currentWidth;
    double longitudePerPoint = currentRegion.span.longitudeDelta / currentHeight;
    
    //quad the zoom at each level
    double zoomFactor = kASMapViewBaseZoom;
    
    double newLatitudePerPoint;
    double newLongitudePerPoint;
    
    if (increaseZoom) {
        newLatitudePerPoint = latitudePerPoint / zoomFactor;
        newLongitudePerPoint = longitudePerPoint / zoomFactor;
    } else {
        newLatitudePerPoint = latitudePerPoint * zoomFactor;
        newLongitudePerPoint = longitudePerPoint * zoomFactor;
    }
    
    CLLocationDegrees newLatitudeDelta = newLatitudePerPoint * currentWidth;
    CLLocationDegrees newLongitudeDelta = newLongitudePerPoint * currentHeight;
    
    if (newLatitudeDelta <= 90 && newLongitudeDelta <= 90) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = self.centerCoordinate;
        mapRegion.span.latitudeDelta = newLatitudeDelta;
        mapRegion.span.longitudeDelta = newLongitudeDelta;
        [self setRegion:mapRegion animated:NO];
    }
}

#pragma mark utility methods for map annotations

/**
 Determine the centroid of the set of the points provided
 */
-(CLLocationCoordinate2D) centerOfCoordinatesIn:(CLLocationCoordinate2D*)coordinates count:(NSInteger)count
{
    double xCenter = 0;
    double yCenter = 0;
    double zCenter = 0;
    
    for (int i=0; i < count; i++) {
        
        //convert to radians
        CLLocationCoordinate2D coord = coordinates[i];
        double latRadians = [self degreesToRadians:coord.latitude];
        double lngRadians = [self degreesToRadians:coord.longitude];
        
        //convert to cartesian (x,y,z) coordinates
        double x = cos(latRadians) * cos(lngRadians);
        double y = cos(latRadians) * sin(lngRadians);
        double z = sin(latRadians);
        
        xCenter = xCenter + x;
        yCenter = yCenter + y;
        zCenter = zCenter + z;
    }
    
    //combined weighted cartesian coordinate
    xCenter = xCenter / count;
    yCenter = yCenter / count;
    zCenter = zCenter / count;
    
    double lngCenterRadians = atan2(yCenter, xCenter);
    double hyp = sqrt(pow(xCenter, 2) + pow(yCenter, 2));
    double latCenterRadians = atan2(zCenter, hyp);
    
    double latCenter = [self radiansToDegrees:latCenterRadians];
    double lngCenter = [self radiansToDegrees:lngCenterRadians];
    return CLLocationCoordinate2DMake(latCenter, lngCenter);
}

-(double) degreesToRadians:(CLLocationDegrees)degrees
{
    return (degrees * M_PI)/180.0;
}

-(CLLocationDegrees) radiansToDegrees:(double)radians
{
    return (radians * 180)/M_PI;
}

@end










