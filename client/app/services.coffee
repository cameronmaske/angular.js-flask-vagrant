services = angular.module('myApp.services', [])

services.factory('User', ($http, $cookieStore, $q, $rootScope) ->
    SessionKey = null

    SessionKey: ->
        return SessionKey
    isAuthenticated: ->
        cookie = $cookieStore.get('user')
        if cookie or SessionKey
            data = JSON.parse(cookie)
            SessionKey = data.SessionKey
            $rootScope.user = @
            return true
        else
            return false

    login: (email, password) ->
        params = {
            'email': email,
            'password': password
        }
        deferred = $q.defer()

        $http.post('/login', params)
            .success((response) ->
                data = response['data']
                $cookieStore.put('user', JSON.stringify(data))
                SessionKey = data.SessionKey
                deferred.resolve(data))
            .error((response) ->
                deferred.reject(response['error']))
        return deferred.promise
    logout: ->
        $cookieStore.remove('user')
)

services.factory('Tour', ($cookieStore) ->

    class Tour
        constructor: (data) ->
            cookie = $cookieStore.get('tour')
            @data = {step: 1, completed: false}
            if cookie
                @data = JSON.parse(cookie)
        completedStep: (step) ->
            if @data.step == step
                if @data.step == 4
                    @data.completed = true
                else
                    @data.step += 1
                $cookieStore.put('tour', JSON.stringify(@data))
    tour = new Tour()
    return tour
)

services.factory('Product', ($log) ->
    class Product
        constructor: (data) ->
            for key, value of data
                @[key] = value
            @Quantity = 1

        changeQuantity: (value) ->
            if @Quantity <= 1 and value < 0
                return
            else
                @Quantity += value

    return Product
)

services.factory('Products', ($http, $q, Product) ->
    running_queries = []

    search: (query, sessionKey) ->
        deferred = $q.defer()

        for running in running_queries
            running.resolve()

        canceler = $q.defer()
        running_queries.push(canceler)

        data = {
            'query': query
            'sessionkey': sessionKey
        }

        $http({method:'POST', url:'/search', data:data, timeout:canceler.promise})
            .then (response) ->
                products = []
                for product in response['data']['data']['Products']
                    products.push(new Product(product))
                deferred.resolve(products)
        return deferred.promise
)

services.factory('Baskets', ($http, $q) ->
    basket = {
        products: []
        price: 0
    }

    addToBasket: (product, sessionKey) ->
        deferred = $q.defer()
        params = {
            'product_id': product.ProductId,
            'quantity': product.Quantity,
            'sessionkey': sessionKey,
        }

        $http.post('/basket', params).then(
            (response) ->
                deferred.resolve(response)
            (response) ->
                deferred.reject(response)
        )

    removeFromBasket: (product, sessionKey, quantity=-99) ->
        deferred = $q.defer()

        params = {
            'product_id': product.ProductId,
            'quantity': quantity,
            'sessionkey': sessionKey,
        }

        index = basket.products.indexOf product

        if index isnt -1
            basket.products.splice index, 1

        $http.post('/basket', params).then(
            (response) ->
                deferred.resolve(response)
            (response) ->
                deferred.reject(response)
        )

    refreshBasket: (sessionKey) ->
        deferred = $q.defer()

        params =
            'sessionkey': sessionKey,

        $http(
            url: '/basket', method: 'GET', params:params).then(
                (response) ->
                    price = response['data']['data']['BasketGuidePrice']
                    products = response['data']['data']['BasketLines']
                    basket['price'] = price
                    basket['products'] = products
                    deferred.resolve(basket)
                (response) ->
                    deferred.reject(response)
            )

    getBasket: ->
        return basket

)