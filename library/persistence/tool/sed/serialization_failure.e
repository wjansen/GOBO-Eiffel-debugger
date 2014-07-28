note
	description: "[
			Exception for retrieval error, 
			may be raised by `retrieved' in `IO_MEDIUM'.
		]"
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2006, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2008-12-29 12:27:11 -0800 (Mon, 29 Dec 2008) $"
	revision: "$Revision: 76420 $"

class
	SERIALIZATION_FAILURE

inherit
	EXCEPTION
		redefine
			internal_meaning,
			code
		end

feature -- Access

	frozen code: INTEGER
			-- Exception code
		do
			Result := {EXCEP_CONST}.serialization_exception
		end

feature {NONE} -- Accesss

	frozen internal_meaning: STRING = "Serialization failed."

end
