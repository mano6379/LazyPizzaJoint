//
//  ViewController.m
//  LazyPizzaFinder
//
//  Created by Marion Ano on 3/26/14.
//  Copyright (c) 2014 Marion Ano. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<UITableViewDataSource, UITableViewDataSource, CLLocationManagerDelegate>
{
    //declare NSMutableArray because we will be adding pizza places.
    
    IBOutlet UITableView *myTableView;
    NSArray *pizzaPlaces;
}
@property CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    pizzaPlaces = [NSMutableArray new];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return pizzaPlaces.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PizzaCellReuseID"];
    MKMapItem* pizzaPlace = pizzaPlaces[indexPath.row];
    cell.textLabel.text = pizzaPlace.name;
    int distance = roundf([pizzaPlace.placemark.location distanceFromLocation:self.locationManager.location]);
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Crow's Distance: %i meters", distance];
    
//    NSDictionary* superhero = heroes[indexPath.row];
//    NSURL* url = [NSURL URLWithString:superhero[@"avatar_url"]];
//    
//    cell.textLabel.text = superhero[@"name"];
//    cell.detailTextLabel.text = superhero[@"description"];
    
    
    return cell;

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    for (CLLocation *location in locations)
    {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000)
        {
            [self startReverseGeocode:location];
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

-(void) startReverseGeocode: (CLLocation *) location
{
        CLGeocoder *geocoder = [CLGeocoder new];
    
        //calling a method, passing two parameters, "location" and a "block", "placemarks is an array of places, sometimes there might be more than one place. NSArray placemarks is every single place at that coordinate.
    
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        //CLPlacemark *place = placemarks.firstObject;
        
        //self.myLabel.text = [NSString stringWithFormat:@"%@", placemarks.firstObject];
        [self askAppleForPizza:placemarks.firstObject];
    }];
}

-(void) askAppleForPizza: (CLPlacemark*) placemark
{
    //NSMutableArray *closestPizzaPlaces = [NSMutableArray new];
    
    MKLocalSearchRequest* request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizza";
    request.region = MKCoordinateRegionMake(placemark.location.coordinate, MKCoordinateSpanMake(1,1));
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        //in response is all the data associated with a query, "prison". information we asked for is stored in mapItems. mapItems is a property of MKLocalSearchResponse.
        
        NSArray *mapItems = response.mapItems;
//        int numberOfPizzaPlaces = mapItems.count;
//        NSLog(@"%d",numberOfPizzaPlaces);
        
        //sorting mapItems array to get the four nearest pizza places (which will show up at the beginning of the array)
        
        mapItems = [mapItems sortedArrayUsingComparator:^NSComparisonResult(MKMapItem* obj1, MKMapItem* obj2) {
            float d1 = [obj1.placemark.location distanceFromLocation:self.locationManager.location];
            float d2 = [obj2.placemark.location distanceFromLocation:self.locationManager.location];
            if (d1 < d2)
            {
                return NSOrderedAscending;
            }
            else
            {
                return NSOrderedDescending;
            }
        }];
        for (MKMapItem* mapItem in mapItems) {
            NSLog(@"%f", [mapItem.placemark.location distanceFromLocation:self.locationManager.location]);
        }
        //NSInteger numberOfAvailablePizzePlaces;
        NSRange numberOfAvaiblePizzaPlaces;
        if (mapItems.count >= 4)
        {
            numberOfAvaiblePizzaPlaces = NSMakeRange(0, 4);
            mapItems = [mapItems subarrayWithRange:numberOfAvaiblePizzaPlaces];
        }
        else
        {
            numberOfAvaiblePizzaPlaces = NSMakeRange(0, mapItems.count);
            mapItems = [mapItems subarrayWithRange:numberOfAvaiblePizzaPlaces];
        }
        NSLog(@"Closest Pizza places");
        for (MKMapItem* mapItem in mapItems) {
            NSLog(@"%f", [mapItem.placemark.location distanceFromLocation:self.locationManager.location]);
        }
        pizzaPlaces = mapItems;
        [myTableView reloadData];
        
        //MKMapItem *mapItem = mapItems.firstObject;
        //self.title = [NSString stringWithFormat:@"%@", mapItem.name];
        
        //NSLog(@"%@", mapItem);
        //[self showDirections:mapItem];
        
    }];
}


//CLLocation Class
//measure distance between coordinates
//[ -distanceFromLocation: (starting location)];


//NSArray
//sort array from smallest to biggest
//[ -sortedArrayUsingComparator: (NSComparator)comparator];

//NSComparator
//NSArray *sortedArray = [array sortedArrayUsingComparator: ^(id obj1, id obj2)
//{
//  if ([obj1 integerValue] < [obj2 intergerValue])
//{
//    return (NSComparisonResult)NSOrderedAscending;
//}
//return (NSComparisonResult)NSOrderedSame;
//}












@end
