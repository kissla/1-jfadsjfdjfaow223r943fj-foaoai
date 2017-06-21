/*
 File: MapQueryViewController.h
 Abstract: Controls the map view and manages the reverse geocoder to get the current address.
 Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "AppDelegate.h"
#import "SVGeocoder.h"
#import "WildcardGestureRecognizer.h"
#import "Location.h"
#import "DataAccess.h"
#import "AnnotationQueryDetailViewController.h"
#import "Constants.h"
#import "PropertyAnnotation.h"
#import "UIBarButtonItemExtension.h"
//#import "NSStringExtensions.h"


@interface MapQueryViewController : UIViewController 
<MKMapViewDelegate, MKReverseGeocoderDelegate, UISearchBarDelegate, UINavigationBarDelegate, SVGeocoderDelegate, UIActionSheetDelegate>
{
    
    DataAccess              * dataController;
    
    CGFloat                   initialScreenHeight;
    
    //NSString                * myAddress;
    //NSString                * myZip;
    //NSString                * myCongressCode;
    //NSString                * myState;
    
    MKMapView               * myMapView;
    
    UIView                  * myToolBarView;
    UIToolbar               * myToolBar;
    UIBarButtonItem         * locateMe;
    UIBarButtonItem         * USAButton;
    UIBarButtonItem         * mapResetBtn;
    UIBarButtonItem         * satelliteOnButton;
    UIBarButtonItem         * satelliteOffButton;
    UISearchBar             * mySearchBar;
    
    WildcardGestureRecognizer       * tapInterceptor;
    
    MKReverseGeocoder       * reverseGeocoder;
    
    CGFloat                   navigationBarHeight;
}

@property (nonatomic, retain) DataAccess        * dataController;
//@property (nonatomic, retain) NSString          * myAddress;
//@property (nonatomic, retain) NSString          * myCongressCode;
//@property (nonatomic, retain) NSString          * myState;
//@property (nonatomic, retain) NSString          * myZip;
@property (nonatomic, retain) MKMapView         * myMapView;
@property (nonatomic, retain) UIView            * myToolBarView;
@property (nonatomic, retain) UIToolbar         * myToolBar;
@property (nonatomic, retain) UIBarButtonItem   * locateMe;
@property (nonatomic, retain) UIBarButtonItem   * USAButton;
@property (nonatomic, retain) UIBarButtonItem   * mapResetBtn;
@property (nonatomic, retain) UIBarButtonItem   * satelliteOnButton;
@property (nonatomic, retain) UIBarButtonItem   * satelliteOffButton;
@property (nonatomic, retain) UISearchBar       * mySearchBar;
@property (nonatomic, retain) MKReverseGeocoder * reverseGeocoder;
@property (nonatomic, retain) WildcardGestureRecognizer         * tapInterceptor;



// ok
-(void) toggleView: (id) sender;
-(void) gotoLatitude: (NSNumber *)latitude Longitude: (NSNumber *) longitude;  // moved to DataAccess

-(void) reOrient;
-(void) showUSA;

-(void) reverseGeocodeUserCurrentLocation;
-(void) geocode;

-(void) drawMap;

- (NSString *) getStateNameOfTag: (int) tagOfState;
- (BOOL) groupPinsByState;

//- (NSString *) dataFilePath;
//-(void) propertyActionAll:     (id)sender;
//-(void) propertyActionCongress:(id)sender;
//-(BOOL) checkForValue:(NSString *)myString;
//-(void) propertyAction:        (id)sender;

@end


