indexing

	description:

		"Error: Missing }"

	library: "Gobo Eiffel Lexical Library"
	copyright: "Copyright (c) 1999, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class LX_MISSING_BRACKET_ERROR

inherit

	UT_ERROR

creation

	make

feature {NONE} -- Initialization

	make (filename: STRING; line: INTEGER) is
			-- Create a new error reporting a missing }.
		require
			filename_not_void: filename /= Void
		do
			create parameters.make (1, 2)
			parameters.put (filename, 1)
			parameters.put (line.out, 2)
		end

feature -- Access

	default_template: STRING is "%"$1%", line $2: missing }"
			-- Default template used to built the error message

	code: STRING is "LX0012"
			-- Error code

invariant

	-- dollar0: $0 = program name
	-- dollar1: $1 = filename
	-- dollar2: $2 = line number

end
