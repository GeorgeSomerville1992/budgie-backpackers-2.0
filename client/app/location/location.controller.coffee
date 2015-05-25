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
    # google.maps.event.addDomListener window, 'load', initialize

    $scope.mapOptions =
      center: new (google.maps.LatLng)($scope.lat, $scope.lng)
      zoom: 15
      mapTypeId: google.maps.MapTypeId.ROADMAP
      # .map-canvas(ui-map='myMap', ui-options='mapOptions')
    testElement = angular.element('<div class="map-canvas" ui-map="myMap", ui-options="mapOptions"></div>')
    angular.element(document.body).append(testElement)
    $compile(testElement)($scope)
    console.log('HELLO')
    # loadScript = ->
    #   script = document.createElement('script')
    #   script.type = 'text/javascript'
    #   script.src = 'https://maps.googleapis.com/maps/api/js?v=3.exp' + '&signed_in=true&callback=initialize'
    #   document.body.appendChild script
    #   return
    # loadScript()
  # uiGmapIsReady.promise().then (maps) ->
  #   map1 = $scope.control.getGMap()
  #   console.log('THE MAP', map1)

    # uiGmapIsReady.promise().then (instances) ->
    #   # instances is an array object
    #   maps = instances[0].map
    #   # if only 1 map it's found at index 0 of array
    #   console.log('the map yeah', maps)
    #   # this function will only be applied on initial map load (once ready)
    #   return
      # uiGmapIsReady.promise(1).then (instances) ->
    #   instances.forEach (inst) ->
    #     console.log('MAP', map)
    #     map = inst.map
    #     uuid = map.uiGmap_id
    #     mapInstanceNumber = inst.instance
    #     # Starts at 1.
    #     return
    #   return

    # maps object
  # uiGmapIsReady.promise().then (instances) ->
  #   # instances is an array object
  #   maps = instances[0].map
  #   console.log('MAPS', maps)
  #   # if only 1 map it's found at index 0 of array
  #   $scope.myOnceOnlyFunction maps
  #   # this function will only be applied on initial map load (once ready)
  #   return
  # $scope.myOnceOnlyFunction = (maps) ->
  #   # this will only be run once on initial load
  #   center = maps.getCenter()
  #   # examples of 'map' manipulation
  #   lat = center.lat()
  #   lng = center.lng()
  #   console.log(maps)
  #   alert 'I\'ll only say this once ! \n Lat : ' + lat + '\n Lng : ' + lng
  #   return
]