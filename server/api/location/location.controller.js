'use strict';

var _ = require('lodash');
var Location = require('./location.model');
var expedia = require('expedia')({apiKey:"yg7cfr2k3xp3t5r22s3mhymd",cid:"55505"}) // just require the name!
var geocoderProvider = 'google';
var httpAdapter = 'http';
var geocoder = require('node-geocoder')(geocoderProvider, httpAdapter);
exports.index = function(req, res) {
  // dont need the load recent in ehere from totorial
  // find commetns for specfic user
  Location.find(function (err, locations) {
    if(err) { return handleError(res, err); }
    return res.json(200, locations);
  });
};

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
  var location = new Location(_.merge({ author: req.user._id }, req.body));
  location.save(function(err, location) {
    // this should really be talking to a external factory.
    if(err) { return handleError(res, err); }
    // a complete list of options is available at http://developer.ean.com/docs/hotel-list/
    var apiKey = "AIzaSyBDi56DVodoH92MNTpQfcPtloDx0y8CgY8"
    var options = {
      "customerSessionId" : "thisisauniqueID",
      "customerIpAddress" : "127.0.0.1",
      "customerUserAgent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko)",
      "HotelListRequest": {
        "city": location.content.locationName,
        "countryCode": "GB",
        "arrivalDate": location.content.arrivalDate,
        "departureDate": location.content.departureDate,
        "numberOfResults": "25"
      } // now working 
    }
    expedia.hotels.list(options, function(err, hostels){
      console.log(hostels)
      console.log(location)
      if(err)throw new Error(err);
      geocoder.geocode(location.content.locationName)
        .then(function(geocode) {
            console.log('GECODE RESPONSE',geocode);
            var userLocation = {userDetails:location, foundHostels:hostels, geocodedLocation: geocode}
            return res.json(201, userLocation);
        })
        .catch(function(err) {
            console.log(err);
        });
    });

  });
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