'use strict';

var _ = require('lodash');
var Location = require('./location.model');
var expedia = require('expedia')({apiKey:"yg7cfr2k3xp3t5r22s3mhymd",cid:"55505"}) // just require the name!
var geocoderProvider = 'google';
var httpAdapter = 'http';
var geocoder = require('node-geocoder')(geocoderProvider, httpAdapter);
var foursquare = require('node-foursquare-venues')('PJOVUMNXMNMSCGSYVETRKZ23WN2LUR31M0AD04AMKTJAKI5I', '3GG355R0B5D4KMH1J1UIUFXH2ZZCFH4ISOW5WTNYV11JJTDV', '20120610')
// make array here, push stuff into upon call 
// array will be saved objects. 

exports.index = function(req, res) {
  // dont need the load recent in ehere from totorial
  // find commetns for specfic user
  // Location.find({{email:"admin@admin.com"}})
  console.log('THE REQ', req.body.autherEmail)
  var autherName = req.body.autherEmail
  // console.log('the RES', res)
  Location.loadRecent(autherName,function (err, locations) {
    // console.log('finding locations')
    // console.log(locations)
    console.log('THE LOCATIONS FOUND VA USER ----> ', locations)
    if(err) { return handleError(res, err); }
    return res.json(200, locations);
  });
};
// exports.find = function(req, res) {
//   console.log('THE REQ', req)


// }
// Get a single location
exports.show = function(req, res) {
  Location.findById(req.params.id, function (err, location) {
    if(err) { return handleError(res, err); }
    if(!location) { return res.send(404); }
    return res.json(location);
  });
};

// Creates a new location in the DB.
exports.create = function(req, res) {
  // Location.create(req.body, function(err, location) {
  //   if(err) { return handleError(res, err); }
  //   return res.json(201, location);
  // });
  console.log("REQ USER ID", req.user._id)
  var location = new Location(_.merge({ author: req.user._id }, req.body));
  location.save(function(err, location) {
    // this should really be talking to a external factory.
    console.log("THE LOCATION", location)
    if(err) { return handleError(res, err); }
    // a complete list of options is available at http://developer.ean.com/docs/hotel-list/
    var apiKey = "AIzaSyBDi56DVodoH92MNTpQfcPtloDx0y8CgY8"

    var foursquareSearchParams = {
      "near": location.content.locationName,
      "query": location.content.attractionType,
      "price": 1,
      "venuePhotos": true
    }
    console.log(foursquareSearchParams)
    console.log(foursquare)
    var fourSquareResults = "something"
    foursquare.venues.explore(foursquareSearchParams, function(err, data){
      console.log("firiing callback!!!!!!!", data)
      fourSquareResults = data
      return fourSquareResults
    })
    // angular promises USE and RESOLVE
    console.log("fourSquareResults ------------>", fourSquareResults)
    geocoder.geocode(location.content.locationName).then(function(geocode){
      geocode[0].latitude
      geocode[0].longitude
      var options = {
        "customerSessionId" : "thisisauniqueID",
        "customerIpAddress" : "127.0.0.1",
        "customerUserAgent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko)",
        "HotelListRequest": {
          "latitude": geocode[0].latitude,
          "longitude": geocode[0].longitude,
          "searchRadius": location.content.range,
          "sort":"PRICE",
          "countryCode": "GB",
          "arrivalDate": location.content.arrivalDate,
          "departureDate": location.content.departureDate,
          "numberOfResults": 75
        } // now working 
      }
      expedia.hotels.list(options, function(err, hostels){
        if(err)throw new Error(err);
        var userLocation = {userDetails:location, foundHostels:hostels, geocodedLocation: geocode, foursquare: fourSquareResults, poo: "hello"}
        return res.json(201, userLocation);
      })

    })
    .catch(function(err) {
      console.log(err);
    });
    // expedia.hotels.list(options, function(err, hostels){
    //   console.log(hostels)
    //   console.log(location)
    //   if(err)throw new Error(err);
    //   // move this above, so we can add radius to api search. 
    //   geocoder.geocode(location.content.locationName)
    //     .then(function(geocode) {
    //         console.log('GECODE RESPONSE',geocode);
    //         var userLocation = {userDetails:location, foundHostels:hostels, geocodedLocation: geocode, foursquare: fourSquareResults, poo: "hello"}
    //         console.log(userLocation)
    //         return res.json(201, userLocation);
    //     })
    //     .catch(function(err) {
    //         console.log(err);
    //     });
    // });

  });// location save
};

// Updates an existing location in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  Location.findById(req.params.id, function (err, location) {
    if (err) { return handleError(res, err); }
    if(!location) { return res.send(404); }
    var updated = _.merge(location, req.body);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, location);
    });
  });
};

// Deletes a location from the DB.
exports.destroy = function(req, res) {
  Location.findById(req.params.id, function (err, location) {
    if(err) { return handleError(res, err); }
    if(!location) { return res.send(404); }
    location.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

function handleError(res, err) {
  return res.send(500, err);
}