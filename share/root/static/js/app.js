
App = Ember.Application.create();

App.Build = Ember.Resource.extend({
    url: '/builds',
    name: 'builds',
    properties: ['target', 'id', 'status', 'type', 'description'],

    validate: function() { }
});

App.buildsController= Ember.ResourceController.create({ type: App.Build });

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

        build.save()
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
    tagName: 'tr',

    doubleClick: function() {
        this.showEdit();
    },

    showEdit: function() {
        this.set('isEditing', true);
    },

    hideEdit: function() {
        this.set('isEditing', false);
    },

    destroyRecord: function() {
        var build = this.get("build");

        build.destroy()
        .done(function() {
            App.buildsController.removeObject(build);
        });
    }
});

Handlebars.registerHelper('submitButton', function(text) {
  return new Handlebars.SafeString('<button type="submit">' + text + '</button>');
});
