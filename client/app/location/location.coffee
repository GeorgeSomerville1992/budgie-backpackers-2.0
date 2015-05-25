'use strict'

angular.module 'budgieBackpackersFinalApp'
.config ($routeProvider) ->
  $routeProvider.when '/location',
    templateUrl: 'app/location/location.html'
    controller: 'LocationCtrl'
  $routeProvider.when '/location/show',
  	templateUrl: 'app/location/location-show.html'
  	controller: 'LocationCtrl'
