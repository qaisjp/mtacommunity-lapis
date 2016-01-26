import Widget from require "lapis.html"
import Resources from require "models"
SearchWidget = require("widgets.search")

class Search extends Widget
	content: =>
		widget SearchWidget onSearchPage: true
		
		div class: "card", ->
			div class: "card-header", ->
				text "Search Results"
				a href: @url_for("search", nil, @params), class: "btn btn-sm btn-primary pull-xs-right", -> i class: "fa fa-link"
			div class: "card-block", ->
				element "table", class: "table table-bordered mta-resources-table", ->
					thead -> tr ->
						th "Name"
						th "Description"
						th "Rating"
					tbody ->
						for resource in *@resourceList
							tr ->
								td ->
									text "#{resource.longname} (#{resource.name}) "
									span class: "label label-info", Resources.types\to_name resource.type
								td resource.description
								td resource.rating