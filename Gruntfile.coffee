module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON('package.json')
        # Compiles all our less -> css.
        recess:
            bootstrap:
                options:
                    compile: true
                files:
                    '.build/css/main.css': ['client/less/main.less']
        # Minified our css.
        cssmin:
            concat:
                options:
                    keepSpecialComments: 0
                files:
                    'server/static/css/main.css': '.build/css/**/*.css'
        # Concats all .tpl.html template files into a single js file (template.js)
        html2js:
            templates:
                options:
                    base: 'client/app/templates'
                    module: 'ngTemplates'
                    rename: (module) ->
                        return module.replace('.tpl', '.template').replace('.html', '')
                src: ['client/app/**/*.tpl.html']
                dest: '.build/js/app/templates.js'
        # Concats and minifies all our js into two files,
        # app.js which all our application specific code.
        # vendor.js which houses all 3rd party libraries (e.g. angularjs)
        concat:
            app_js:
                src: ['.build/js/app/**/*.js']
                dest: 'server/static/js/app.js'
            vendor_js:
                src: ['.build/js/vendor/angular.js', '.build/js/vendor/**/*.js']
                dest: 'server/static/js/vendor.js'
        # Copy our concated files from .build -> the server/static file.
        copy:
            js:
                filter: 'isFile'
                expand: true
                flatten: true
                cwd: 'client/vendor/'
                src: '**/*.js'
                dest: '.build/js/vendor/'
        # Compiles any .coffee files in our app to js in the build folder.
        coffee:
            source:
                expand: true
                cwd: 'client/'
                src: ['app/**/*.coffee']
                dest: '.build/js'
                ext: '.js'
        # Watch our files for any chances and run the approiate task.
        watch:
            coffee:
                files: ['client/app/**/*.coffee']
                tasks: ['coffee:source', 'concat:app_js']
                options:
                    spawn: false
                    livereload: true
            vendor:
                files: ['client/vendor/**/*.js']
                tasks: ['copy:js', 'concat:vendor_js']
                options:
                    spawn: false
                    livereload: true
            less:
                files: ['client/less/**/*.less']
                tasks: ['recess:bootstrap', 'cssmin:concat']
                options:
                    spawn: false
                    livereload: true
            templates:
                files: ['client/app/**/*.tpl.html']
                tasks: ['html2js:templates', 'concat:app_js']
                options:
                    spawn: false
                    livereload: true
    # Load NPM tasks
    grunt.loadNpmTasks('grunt-contrib-sass')
    grunt.loadNpmTasks('grunt-recess')
    grunt.loadNpmTasks('grunt-contrib-watch')
    grunt.loadNpmTasks('grunt-contrib-coffee')
    grunt.loadNpmTasks('grunt-contrib-cssmin')
    grunt.loadNpmTasks('grunt-contrib-concat')
    grunt.loadNpmTasks('grunt-contrib-copy')
    grunt.loadNpmTasks('grunt-html2js')
    grunt.registerTask('build', ['coffee', 'html2js', 'copy', 'concat', 'recess:bootstrap', 'cssmin'])
    grunt.registerTask('default', ['watch'])