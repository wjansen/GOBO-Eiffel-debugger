indexing

	description:

		"Eiffel class names"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_CLASS_NAME

inherit

	ET_CLASS_NAME_ITEM
	ET_PRECURSOR_CLASS_NAME
	HASHABLE

feature -- Access

	name: STRING is
			-- Name of class
		deferred
		ensure
			name_not_void: Result /= Void
			name_not_empty: Result.count > 0
		end

	class_name: ET_CLASS_NAME is
			-- Class name
		do
			Result := Current
		end

feature -- Status report

	is_identifier: BOOLEAN is
			-- Is current class name an identifier?
		do
			-- Result := False
		end

feature -- Comparison

	same_class_name (other: ET_CLASS_NAME): BOOLEAN is
			-- Are class name and `other' the same class name?
			-- (case insensitive)
		require
			other_not_void: other /= Void
		deferred
		end

end
