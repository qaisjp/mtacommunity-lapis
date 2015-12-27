import Widget from require "lapis.html"
import Users from require "models"

breadcrumb = class extends Widget
	content: =>
		li class: "active", "Users"

main = class MTAAdminBans extends Widget
	@include require "widgets.utils"
	content: =>
		paginated = Users\paginated "order by created_at desc",
			per_page: 2
		
		pages = paginated\num_pages!
		p "page #{@page} of #{pages}"

		element "table", class: "table table-hover table-bordered table-condensed table-href", ->
			thead ->
				tr ->
					th "#"
					th "Username"
					th "Creation Date"
					th "Tools"
			tbody ->
				for user in *paginated\get_page @page
					tr ["date-href"]: (@url_for "user_profile", username: user.username), ->
						td scope: "row", user.id
						td user.username
						td user.created_at
						td -> form class: "mta-inline-form", method: "POST", action: @url_for("admin.become"), ->
							@write_csrf_input!
							input type: "hidden", name: "user_id", value: user.id, ["aria-hidden"]: "true"
							button type: "submit", class: "btn btn-default btn-xs", ->
								i class: "fa fa-eye"
								text " become"

		@write_pagination_nav "admin.users", pages, @page

{:main, :breadcrumb}