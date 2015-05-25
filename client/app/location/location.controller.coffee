'use strict'

angular.module 'budgieBackpackersFinalApp'
.constant 'GOOGLEGEOCODE', 
  "APIKEY":"AIzaSyBDi56DVodoH92MNTpQfcPtloDx0y8CgY8"
.controller 'LocationCtrl', ['$scope', '$http', '$location', '$compile', 'socket', 'GOOGLEGEOCODE', ($scope, $http, $location, $compile, socket, GOOGLEGEOCODE) ->
  $scope.message = 'Hello'
  $http.get('api/locations').success (locations) ->
    $scope.locations = locations
    console.log($scope.locations)
    socket.syncUpdates 'location', $scope.locations, (event, location, locations) ->
      # This callback is fired after the comments array is updated by the socket listeners
      # sort the array every time its modified
      return
  # socket.syncUpdates 'location', $scope.locations, (event, location, locations) ->
  # # This callback is fired after the comments array is updated by the socket listeners
  # # sort the array every time its modified
  #   console.log(locations)
  # $scope.lat = 45
  # $scope.lng = -73
  # $scope.map = 
  #   center: 
  #     latitude: $scope.lat, 
  #     longitude: $scope.lng
  #   zoom: 8
  $scope.lat = 50
  $scope.lng = 37
  $scope.$on '$destroy', ->
    socket.unsyncUpdates 'location'
    return
  $scope.addLocation = -> 
    $scope.newLocation = 
      locationName: $scope.locationName
      arrivalDate: $scope.arrivalDate 
      departureDate: $scope.departureDate
      attractionType: $scope.attractionType
      range: $scope.range
    console.log($scope.location)
    $http.post('api/locations', content: $scope.newLocation).success((data, status, headers, config) ->
      console.log("thedata", data)
      $location.path('location/show')
      console.log('geocoded location before', data.geocodedLocation[0])
      $scope.geocodeLocation data.geocodedLocation[0]
      # get data
    ).error (data, status, headers, config) ->
      console.log('we have an error')
  # callback so maps is provided

  $scope.geocodeLocation = (locationName) ->
    console.log('locationName', locationName)

    $scope.lat = locationName.latitude
    $scope.lng = locationName.longitude
    $scope.map =
      center:
        latitude: $scope.lat
        longitude: $scope.lng
      zoom: 12
      # .map-canvas(ui-map='myMap', ui-options='mapOptions')
    # testElement = angular.element('<div class="map-canvas" ui-map="myMap", ui-options="mapOptions"></div>')
    testElement = angular.element('<ui-gmap-google-map center="map.center" zoom="map.zoom"></ui-gmap-google-map>')
    angular.element(document.body).append(testElement)
    $compile(testElement)($scope)
    console.log('HELLO')
]