import from_json from require "lapis.util"

check_file = (file) ->
	-- open up a feed
	output, err = io.popen "../mtacommunity-cli/mtacommunity-cli check --file=#{file}"

	-- if it failed to open...
	return false, {"Internal error..."} unless output

	-- read all the possible errors...
	errors = {}
	local success
	for line in output\lines! do
		-- did we have a reportable error?
		if line\sub(1, 7) == "error: "
			success = false
			table.insert errors, line\sub 8

		-- are we done? is everything okay?
		elseif line\sub(1, 2) == "ok"
			couldDecode, decoded = pcall from_json, line\sub 3

			if not couldDecode
				errors = {"Internal error. Give the following information to a codemonkey:", decoded, line\sub 3}
			elseif success != false
				success = decoded

			break

		-- we got something else...
		else
			success = false
			errors  = {"Internal error..."}
			break
	
	output\close!
	return success, errors

{:check_file}