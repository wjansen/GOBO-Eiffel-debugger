indexing

	description:

		"Singleton4"

	library: "Gobo Eiffel Pattern Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class SINGLETON4

inherit

	SHARED_SINGLETON4

creation

	make

feature {NONE} -- Initialization

	make is
			-- Create a singleton object.
		require
			singleton4_not_created: not singleton4_created
		do
			singleton4_cell.put (Current)
		end

invariant

	singleton4_created: singleton4_created
	singleton_pattern: Current = singleton4

end
