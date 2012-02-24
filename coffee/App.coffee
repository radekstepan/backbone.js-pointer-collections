# App
# ----------
window.App =

    Models: {}
    Views: {}

    initialize: ->

        # Tags and their View.
        tags = [
            {"name": "php", "category": "languages"},
            {"name": "ux", "category": "design"},
            {"name": "mongo-db", "category": "databases"},
            {"name": "hci", "category": "design"},
            {"name": "silverstripe", "category": "frameworks"},
            {"name": "python", "category": "languages"}
        ]
        App.Models.Tags = new Tags(tags)
        new App.Views.TagsView(model: App.Models.Tags)

        # TagsCategories.
        categories = [
            {"name": "databases"},
            {"name": "design"},
            {"name": "frameworks"},
            {"name": "languages"}
        ]
        App.Models.TagsCategories = new TagsCategories(categories)
        new App.Views.TagsCategoriesView(model: App.Models.TagsCategories)


# Tag Model
# ----------
class window.Tag extends Backbone.Model


# Tags Collection
# ---------------
class window.Tags extends Backbone.Collection
    
    model: Tag


# Tags View
# ----------
class App.Views.TagsView extends Backbone.View

    el: "table#tags"

    initialize: (opts) ->
        @models = opts.model.models
        @render()

    render: ->
        for tag in @models
            $(@el).append(
                $('<tr/>')
                .append($('<td/>', { 'text': tag.cid }))
                .append($('<td/>', { 'text': tag.get("name") }))
                .append($('<td/>', { 'text': tag.get("category") }))
            )


# Pointer Model
# ----------
class window.PointerModel extends Backbone.Model

    # Override get to fetch the actual object and its attribute.
    get: (attribute) => @getObject().get(attribute)

    # Fetch the actual object.
    getObject: => @collection.ref.getByCid(@attributes["cid"])


# Pointer Collection
# ----------
class window.PointerCollection extends Backbone.Collection

    model: PointerModel

    initialize: (opts) ->
        # Save the actual reference.
        @ref = opts.ref
        # Reset whatever was saved.
        @reset()


# TagCategory Model
# ----------
class window.TagCategory extends Backbone.Model

    initialize: ->
        # Refer to a PointerCollection in tags to App.Models.Tags
        @attributes["tags"] = new PointerCollection({"ref": App.Models.Tags})

        # Fill it up.
        for tag in App.Models.Tags.models
            if tag.get("category") is @get("name")
                @attributes["tags"].add("cid": tag.cid)


# TagsCategories Collection
# ---------------
class window.TagsCategories extends Backbone.Collection
    
    model: TagCategory


# Tags of TagsCategories View
# ----------
class App.Views.TagsCategoriesTagsView extends Backbone.View

    tagName: "ul"

    initialize: (opts) ->
        @tags = opts.model.models

    render: ->
        for tag in @tags
            $(@el).append($('<li/>', { 'text': tag.get("name") }))
        @


# TagsCategories View
# ----------
class App.Views.TagsCategoriesView extends Backbone.View

    el: "table#tags-categories"

    initialize: (opts) ->
        @categories = opts.model.models
        @render()

    render: ->
        for category in @categories
            $(@el).append(
                $('<tr/>')
                .append($('<td/>', { 'text': category.cid }))
                .append($('<td/>', { 'text': category.get("name") }))
                .append($('<td/>', { 'html':
                    new App.Views.TagsCategoriesTagsView(model: category.get("tags")).render().el
                }))
            )


# Initialize the app when DOM is ready.
$ -> App.initialize()