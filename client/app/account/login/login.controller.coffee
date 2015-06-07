'use strict'

angular.module 'budgieBackpackersFinalApp'
.controller 'LoginCtrl', ($scope, Auth, $location, $window) ->
  $scope.user = {}
  $scope.errors = {}
  $scope.login = (form) ->
    $scope.submitted = true
    console.log('auth', Auth)
    if form.$valid
      # Logged in, redirect to home
      Auth.login
        email: $scope.user.email
        password: $scope.user.password

      .then ->
        $location.path '/location'

      .catch (err) ->
        $scope.errors.other = err.message

  $scope.loginOauth = (provider) ->
    $window.location.href = '/auth/' + provider
