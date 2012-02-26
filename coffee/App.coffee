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
        new App.Views.TagsView(model: App.Models.Tags).render()

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

    defaults:
        "css-class": "label-info"

    # Toggle our CSS Class attribute.
    toggleCSSClass: =>
        @set("css-class": if @get("css-class") is "label-info" then "label-warning" else "label-info" )


# Tags Collection
# ---------------
class window.Tags extends Backbone.Collection
    
    model: Tag

    comparator: (tag) -> tag.get("name")


# Tag View
# ----------
class App.Views.TagView extends Backbone.View

    events:
        "click": "toggleCSSClass"

    initialize: (opts) ->
        # Set the model internally.
        @tag = opts.model
        # Re-render if our Model changes.
        @tag.bind("change", @render, @)

    # Toggle on the Model
    toggleCSSClass: => @tag.toggleCSSClass()

    render: ->
        $(@el).html($('<span/>',
            'class': "label #{@tag.get('css-class')}"
            'text':  @tag.get("name")
            'style': 'margin-right:5px;cursor:pointer'
        )).attr("style": "display:inline-block")
        @


# Tags View
# ----------
class App.Views.TagsView extends Backbone.View

    el: "table#tags"

    initialize: (opts) -> @tags = opts.model.models

    render: ->
        for tag in @tags
            $(@el).append(
                $('<tr/>')
                .append($('<td/>', { 'text': tag.cid }))
                .append($('<td/>', { 'html': new App.Views.TagView(model: tag).render().el }))
                .append($('<td/>', { 'text': tag.get("category") }))
            )


# Pointer Model
# ----------
class window.PointerModel extends Backbone.Model

    # Override get to fetch the actual object and its attribute.
    get: (attribute) => @getObject()?.get(attribute)

    # Fetch the actual object.
    getObject: => @collection.ref.getByCid(@attributes["cid"])


# Pointer Collection
# ----------
class window.PointerCollection extends Backbone.Collection

    model: PointerModel

    initialize: (opts) ->
        # Save the actual reference.
        @ref = opts.ref
        # Use parent's comparator?
        if (@ref.comparator) then @comparator = @ref.comparator
        
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

    initialize: (opts) -> @tags = opts.model.models

    render: ->
        for tag in @tags
            # Just remember to return the actual Tag Object when passing it to a View.
            $(@el).append(new App.Views.TagView(model: tag.getObject()).render().el)
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