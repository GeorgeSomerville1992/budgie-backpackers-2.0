'use strict'

describe 'Controller: LocationCtrl', ->

  # load the controller's module
  beforeEach module 'budgieBackpackersFinalApp'
  LocationCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    LocationCtrl = $controller 'LocationCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
