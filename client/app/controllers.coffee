controllers = app.module('myApp.controllers', [])

controllers.controller('indexCtrl', ($scope) ->
    $scope.value = "It's working!"

)
