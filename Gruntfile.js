/*global module:false*/
module.exports = function(grunt) {

    grunt.initConfig({
        less: {
            development: {
                options: {
                    paths: ["source/client/static/less"]
                },
                files: {
                    "source/client/static/css/app.css": "source/client/static/less/app.less",
                    "source/client/static/css/admin.css": "source/client/static/less/admin.less"
                }
            }
        },
        cssmin: {
            compress: {
                files: {
                    "source/public/css/app.min.css": [
                        "source/client/static/css/bootstrap.min.css", "source/client/static/css/typicons.css",
                        "source/client/static/css/app.css"
                    ],
                    "source/public/css/admin.min.css": [
                        "source/client/static/css/bootstrap.min.css", "source/client/static/css/bootstrap-responsive.min.css",
                        "source/client/static/css/bootstrap-colorpicker.css", "source/client/static/css/admin.css"
                    ]
                }
            }
        },
        coffee : {
            compile: {
                files : {
                    'source/public/js/app.body.js':["source/client/models/*.coffee", "source/client/collections/*.coffee",
                        "source/client/views/**/**.coffee", "source/client/app.coffee"
                    ],
                    'source/public/js/admin.body.js':["source/client/admin.coffee"]
                },
                options: {
                    bare: true
                }
            }
        },
        uglify : {
            head: {
                files : {
                    "source/public/js/app.head.js" :[
                        "source/client/static/js/jquery-1.9.1.min.js", "source/client/static/js/jquery.cookie.js",
                        "source/client/static/js/underscore.js", "source/client/static/js/backbone.js",
                        "source/client/static/js/infiniScroll.js", "source/client/static/js/dot.min.js",
                        "source/client/static/js/swfobject.js"
                    ]
                }
            }
        }
    });


    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-uglify');

    grunt.registerTask('default', ['less', 'cssmin', 'uglify', 'coffee']);
    //grunt.registerTask('default', 'dotjs');

};


