###
Declare the app. A global level module where you can create routes, models, etc.
[] is where you list any other modules for dependency injection.
###
app = angular.module('myApp',
    ['myApp.services', 'ngRoute', 'ngTemplates', 'ngCookies', 'firebase'])

# Configure angular to evaluate square brackets for interpolation.
# In simpler terms, you now use [[ variable ]] instead of {{ variable }}
# This avoids confilcts with jinja.
app.config(($interpolateProvider) ->
    $interpolateProvider.startSymbol('[[')
    $interpolateProvider.endSymbol(']]')
)

app.config(($routeProvider) ->
    $routeProvider
        .when('/',
            controller: 'indexCtrl'
            templateUrl: 'index.template'
            login_required: true
            )
        .when('/recipe',
            controller: 'recipeCtrl',
            templateUrl: 'recipe.template'
            login_required: true
            )
        .when('/login',
            controller: 'loginCtrl',
            templateUrl: 'login.template'
            )
        .when('/logout',
            controller: 'logoutCtrl',
            template: "Bye!"
            )
        .when('')
        .otherwise(
            redirectTo: '/')
)

app.run(($rootScope, $location, User) ->
    # When a new route change starts
    $rootScope.$on("$routeChangeStart", (event, next, current) ->
        # Check if that route requires a login
        if next.login_required
            # If not loged in, redirect to the login page!
            if not User.isAuthenticated()
                $location.path('/login')
    )
)

app.factory('HttpResponseInterceptor', ($q, $location) ->
    responseError: (rejection) ->
        if rejection.status == 401
            $location.path('/login')
        return $q.reject(rejection)
)

app.config(($httpProvider) ->
    $httpProvider.interceptors.push('HttpResponseInterceptor')
)

app.controller('tourCtrl', (Tour, $scope) ->
    $scope.tour = Tour.data
)

app.controller('recipeCtrl', ($scope, angularFire, User, Products) ->
    $scope.recipes = []
    fire = new Firebase("https://groceries-tesco.firebaseio.com/list")
    angularFire(fire, $scope, "recipes")

    $scope.$watch 'searchterm', (query) ->
        if query?.length > 3
            Products.search(query, User.SessionKey()).then((products) ->
                $scope.products = products)
)

app.controller('indexCtrl', (User, Product, Products, Tour, Baskets, $scope) ->
    $scope.products = []
    $scope.basket = {'products': [], 'price': 0}

    $scope.$watch 'searchterm', (query) ->
        if query?.length > 3
            Tour.completedStep(1)
            Products.search(query, User.SessionKey()).then((products) ->
                $scope.products = products)
        else
            $scope.products = []

    $scope.basket = Baskets.getBasket()
    Baskets.refreshBasket(User.SessionKey())

    $scope.addToBasket = (product) ->
        $scope.loading = true
        product.loading = true

        Baskets.addToBasket(product, User.SessionKey()).then ->
            $scope.loading = false
            product.loading = false
            Baskets.refreshBasket(User.SessionKey())

    $scope.removeFromBasket = (product) ->
        $scope.loading = true
        Baskets.removeFromBasket(product, User.SessionKey()).then ->
            $scope.loading = false
            Baskets.refreshBasket(User.SessionKey())

    $scope.selected = -1

    $scope.isSelected = (index) ->
        if index == $scope.selected
            return true
        return false

    $scope.selectNext = ->
        # Check we aren't at the last one.
        if $scope.selected < $scope.products.length
            $scope.selected += 1
            Tour.completedStep(2)

    $scope.selectPrevious = ->
        # Check we are not at the start.
        if $scope.selected != 0
            $scope.selected -= 1
            Tour.completedStep(2)

    $scope.selectedProduct = ->
        return $scope.products[$scope.selected]

    $scope.addSelectedToBasket = ->
        if $scope.selected != -1
            product = $scope.selectedProduct()
            $scope.addToBasket(product)
            Tour.completedStep(4)

    $scope.increaseSelectedQuantity = ->
        $scope.selectedProduct().changeQuantity(1)
        Tour.completedStep(3)

    $scope.decreaseSelectedQuantity = ->
        $scope.selectedProduct().changeQuantity(-1)
        Tour.completedStep(3)
)


app.controller('loginCtrl', ($scope, $http, $location, User) ->
    $scope.loading = false

    $scope.login = ->
        $scope.loading = true
        User.login($scope.email, $scope.password).then(
            ->
                # Sucess!
                $location.path('/')
            , (reason) ->
                # Error
                alert reason
                $scope.loading = false
        )
    )

app.controller('logoutCtrl', (User) ->
    User.logout())


app.directive('scrollIf', ->
    link: (scope, element, attrs) ->
        scope.$watch attrs.scrollIf, (value) ->
            if value
                window.scrollTo(0, element[0].offsetTop - 108)
)

app.directive('keypressOnFocus', ($log, $parse) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
        keys =
            "9": 'tab'
            "37": 'left'
            "38": 'up'
            "39": 'right'
            "40": 'down'
            "13": 'enter'

        focus = false
        element.bind "focus", ->
           focus = true
        element.bind "blur", ->
            focus = false

        element.bind "keydown", (event) ->
            if keys[event.keyCode]
                if focus
                    fn = scope.$eval(attrs.keypressOnFocus)[keys[event.keyCode]]
                    scope.$apply(fn)
                event.preventDefault()
)