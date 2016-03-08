db = require "lapis.db"
import Model, enum from require "lapis.db.model"
import Users from require "models"

trueTable = setmetatable {},
    __index: -> true
    __newindex: -> error("attempting to change readonly trueTable", 2)
    
class Resources extends Model
    -- Has created_at and updated_at
    @timestamp: true

    @relations: {
    	{"comments", has_many: "Comments", key: "resource", order: "created_at desc", where: deleted: false}
        {"packages", has_many: "ResourcePackages", key: "resource", order: "created_at desc"}
    }

    @types: enum
    	gamemode: 1
    	script: 2
    	map: 3
    	misc: 4

    url_key: (route_name) => @slug
    url_params: (reg, ...) => "resources.view", { resource_slug: @ }, ...


    -- all authors
    get_authors: (fields = "users.*", include_creator = true, is_confirmed = true) =>
    	Users\select [[
    		-- The columns we're looking through...
    		, resources, resource_admins

    		WHERE
    		(
    		]] .. (
                -- Is the user the creator?
	    		include_creator and "(resources.creator = users.id)" or "0 = 1"
            ) .. [[
	    		OR
	    		(
	    			(resource_admins.user = users.id) -- Make sure they are an admin...
	    			AND (resource_admins.resource = resources.id) -- ... of the correct resource...
	    			AND (resource_admins.user_confirmed = ?) -- but make sure they've confirmed the request!
	    		)
    		)

			-- Make sure we're looking through the right resource
			AND (resources.id = ?)

			-- Prevent duplicates
			GROUP BY users.id
    	]], tostring(is_confirmed), @id, :fields

    is_user_admin: (user, is_confirmed = true) =>
        (db.select [[
            EXISTS(
                SELECT 1 FROM users, resources, resource_admins
                WHERE
                (
                    -- Is the user the creator
                    (resources.creator = users.id)

                    OR
                    (
                        (resource_admins.user = users.id) -- Make sure they are an admin...
                        AND (resource_admins.resource = resources.id) -- ... of the correct resource...
                        AND (resource_admins.user_confirmed = ?) -- but make sure they've confirmed the request!
                    )
                )

                -- Make sure we're looking through the right resource
                AND (resources.id = ?)

                -- And checking the right person
                AND (users.id = ?)
            )]],  tostring(is_confirmed), @id, user.id
        )[1].exists

    get_rights: (user, user_confirmed = true) =>
        return trueTable if @creator == user.id
        import ResourceAdmins from require "models"
        ResourceAdmins\find resource: @id, user: user.id, :user_confirmed