'use strict'

angular.module 'budgieBackpackersFinalApp'
.constant 'GOOGLEGEOCODE', 
  "APIKEY":"AIzaSyBDi56DVodoH92MNTpQfcPtloDx0y8CgY8"
.controller 'LocationCtrl', ['$scope', '$http', '$location', '$compile', 'socket', 'GOOGLEGEOCODE', 'Auth', ($scope, $http, $location, $compile, socket, GOOGLEGEOCODE, Auth) ->
  $scope.results = ''
  console.log(Auth.getCurrentUser())
  $scope.autherEmail =  Auth.getCurrentUser().email
  console.log($scope.email)
  $http.put('api/locations', {autherEmail: $scope.autherEmail}).success (locations) ->
    # so this will get locations back return the user email
    # nad we can splcie the array up realtive to what the 4scope.email matches
    # however this is very unproductive as we simply wouldn't want to return a whole database back
    # the main thing to solve would be to direct query in databasae, But I dont know how.
    $scope.locations = locations
    console.log($scope.locations)
    socket.syncUpdates 'location', $scope.locations, (event, location, locations) ->
      # This callback is fired after the comments array is updated by the socket listeners
      # sort the array every time its modified
      console.log('location', location)
      console.log('locations', locations)
      return
  $scope.$on '$destroy', ->
    socket.unsyncUpdates 'location'
    return
  $scope.addLocation = -> 
    if $scope.location_form.$valid
      $scope.newLocation = 
        email: $scope.email
        locationName: $scope.locationName
        arrivalDate: formatDate($scope.arrivalDate)
        departureDate: formatDate($scope.departureDate)
        attractionType: $scope.attractionType
        range: $scope.range
      console.log('newLocation', $scope.newLocation)
      console.log($scope.location)
      $http.post('api/locations', content: $scope.newLocation).success((data, status, headers, config) ->
        console.log("thedata", data)
        $scope.results = data
        $location.path('location/show')
        console.log('geocoded location before', data.geocodedLocation[0])
        $scope.geocodeLocation data.geocodedLocation[0]
        # get data
      ).error (data, status, headers, config) ->
        console.log('we have an error')
    else
      $scope.location_form.submitted = true
      console.log('location error')
  # callback so maps is provided
  formatDate = (date) ->
    return (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear()
  $scope.geocodeLocation = (locationName) ->
    console.log('locationName', locationName)

    $scope.lat = locationName.latitude
    $scope.lng = locationName.longitude
    # google.maps.event.addDomListener window, 'load', initialize
    $scope.map =
      center:
        latitude: $scope.lat
        longitude: $scope.lng
      zoom: 12
      # .map-canvas(ui-map='myMap', ui-options='mapOptions')
    # testElement = angular.element('<div class="map-canvas" ui-map="myMap", ui-options="mapOptions"></div>')
    console.log('results ----->', $scope.results.foundHostels)
    $scope.hostels = $scope.results.foundHostels.HotelListResponse.HotelList.HotelSummary
    getMarkerCoords $scope.hostels
    testElement = angular.element('<ui-gmap-google-map id="googleMap" center="map.center" zoom="map.zoom"></ui-gmap-google-map>')
    markers = angular.element('<marker data-ng-repeat="hostel hostels" coords=""></marker>')
    angular.element(document.body).append(testElement)
    $compile(testElement)($scope)
    googleMap = angular.element document.querySelector( '#googleMap' ) 
    console.log(googleMap)
    googleMap.append()
    console.log('HELLO')
  getMarkerCoords = (hostels) ->
    console.log('firing marker coords', hostels)
    markers = []
    i = 0
    while i < hostels.length
      marker = 
        latitude: hostels[i].latitude
        longitude: hostels[i].longitude
      markers.push(marker)
      i += 1
    console.log(markers)
]
.directive 'lowerThan', [ ->

  link = ($scope, $element, $attrs, ctrl) ->
    console.log($scope.departure_date)
    validate = (viewValue) ->
      # doesn't Quite work!
      comparisonModel = $attrs.lowerThan
      if !viewValue or !comparisonModel
        # It's valid because we have nothing to compare against
        ctrl.$setValidity 'lowerThan', true
      # It's valid if model is lower than the model we're comparing against
      console.log(viewValue)
      viewValueDate = new Date(viewValue)
      viewValueMillSec = viewValueDate.getTime()
      console.log("comparison model -->", comparisonModel)
      george = comparisonModel.split("T")
      comparisonDate = new Date(george[0]).getTime()
      comparisonModelDate = new Date(comparisonModel)
      ctrl.$setValidity 'lowerThan', parseInt(viewValue, 10) < parseInt(comparisonDate, 10)
      viewValue

    ctrl.$parsers.unshift validate
    ctrl.$formatters.push validate
    $attrs.$observe 'lowerThan', (comparisonModel) ->
      # Whenever the comparison model changes we'll re-validate
      validate ctrl.$viewValue
    return

  {
    require: 'ngModel'
    link: link
  }
 ]