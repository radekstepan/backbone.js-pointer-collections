# The WebService root.
flymine = new intermine.Service(root: "www.flymine.org/query")

# Set the query.
query =
    select: ["symbol", "primaryIdentifier"]
    from: "Gene"
    where:
        symbol:
            contains: "ze"
    limit: 10

# Call the service.
flymine.query(query, (q) ->
    q.records (rs) ->
        _(rs).each( (row, index) ->
            $('<tr/>')
                .append($('<td/>', {"text": index + 1}))
                .append($('<td/>', {"text": row["symbol"]}))
                .append($('<td/>', {"text": row["primaryIdentifier"]}))
                .append($('<td/>', {"text": row["objectId"]}))
                .append($('<td/>', {"html": ->
                    flymine.fetchListsContaining("id": row["objectId"], (q) =>
                        if q.length
                            $(@).append $('<span/>', {"class": "label label-success", "text": "Yes"})
                        else
                            $(@).append $('<span/>', {"class": "label", "text": "No"})
                    )
                }))
                .appendTo($("table#ze-genes tbody"))
        )
)