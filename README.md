ASMapView
=========

ASMapView is a subclass of MKMapView from iOS Mapkit framework. ASMapView adds the ability to zoom in and out of the map using just one hand. The gesture behavior is as implemented in the Google Maps app. I have used that as a model and implemented it for MapKit. The gesture works by double-tapping on the map and with keeping your finger pressed, panning up to zoom out and panning down to zoom in.

The goal of ASMapView is to be as close to MkMapView as possible and add no new requirements for the developer.

How does it work?
=================
Simple, create an instance of ASMapView just as you would for MkMapView and add it as a subview in your view. You can also use it by dragging the Map view in Interface Builder and set ASMapView as the custom class.

Installation
============

1) Add the MapKit.framework to your project if you haven't already.

2) Copy the ASMapView.h & ASMapView.m files from the /lib folder and include them in your project.

3) Add the map to your view and use it just as you would use MkMapView.

Important
=========
ASMapView is under active development! More features which add to MkMapView are coming soon, so check back. 

Feel free to contact me at hasan@assemblelabs.com if you have any questions of post them here.

Credits
=======
ASMapView is created by Hasan Adil @assemblelabs and is available under the MIT license.




