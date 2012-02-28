App = Ember.Application.create();

App.Build = Ember.Resource.extend({
    resourceUrl: '/builds',
    
    validate: function() {},
    
    startTime: Ember.computed(function() {
        var d = new Date(0);
        d.setUTCSeconds(this.get("start_time"));
        return d.toISOString();
    }),
    stopTime: Ember.computed(function() {
        if( ! this.get("stop_time")) { return }
        var d = new Date(0);
        d.setUTCSeconds(this.get("stop_time"));
        return d.toISOString();
    }),

});

App.buildsController = Ember.ResourceController.create({
    resourceType: App.Build,
    resourceUrl: '/builds',

    findAll: function() {
      var self = this;
      return jQuery.ajax({
        url: this._resourceUrl(),
        dataType: 'json',
        type: 'GET'
      }).done( function(json) {
        json.reverse();
        self.set("content", []);
        self.loadAll(json);
      });
    },

});

App.ListBuildsView = Ember.View.extend({
    templateName: 'list-template',
    buildsBinding: 'App.buildsController',

    showNew: function() {
        this.set('isNewVisible', true);
    },

    hideNew: function() {
        this.set('isNewVisible', false);
    },

    refreshListing: function() {
        App.buildsController.findAll();
    }
});

App.NewBuildView = Ember.View.extend({
    tagName: 'form',
    templateName: 'edit-template',

    init: function() {
        this.set("build", App.Build.create());
        this._super();
    },

    didInsertElement: function() {
        this._super();
        this.$('input:first').focus();
    },

    cancelForm: function() {
        this.get("parentView").hideNew();
    },

    submit: function(event) {
        var self = this;
        var build = this.get("build");

        event.preventDefault();

        build.saveResource()
        .fail(function(e) {
            log(e);
            // App.displayError(e);
        })
        .done(function() {
            App.buildsController.pushObject(build);
            self.get("parentView").hideNew();
        });
    }
});

App.ShowBuildView = Ember.View.extend({
    templateName: 'show-template',
    classNames: ['show-build'],

    doubleClick: function() {
        this.toggleFullView();
    },

    toggleFullView: function() {
        if (this.get('fullView')) {
            this.set('fullView', false);
        } else {
            this.set('fullView', true);
        }
    },

    rebuildBuild: function() {
        var build = this.get("build");
        var newBuild = App.Build.create({target: build.target});
                
        newBuild.saveResource().done(function() {
            App.buildsController.pushObject(build);
        });
    },

    destroyBuild: function() {
        var build = this.get("build");

        build.destroyResource()
        .done(function() {
            App.buildsController.removeObject(build);
        });
    }
});

App.statusView = Ember.View.extend({
    templateName: 'status-template',
    classNames: ['status'],
    
})

Handlebars.registerHelper('submitButton',
function(text) {
    return new Handlebars.SafeString('<button type="submit">' + text + '</button>');
});


Handlebars.registerHelper('log',
function(data) {
    log(data)
});
