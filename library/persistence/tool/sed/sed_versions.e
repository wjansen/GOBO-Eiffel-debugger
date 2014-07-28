note
	description: "Summary description for {SED_STORABLE_VERSIONS}."
	author: ""
	date: "$Date: 2010-02-24 14:17:13 -0800 (Wed, 24 Feb 2010) $"
	revision: "$Revision: 82421 $"

class
	SED_VERSIONS

feature -- Access

	session_version_6_6: NATURAL_32 = 1
			-- Version for SED_SESSION_SERIALIZER.

	basic_version_6_6: NATURAL_32 = 2
			-- Version for SED_BASIC_SERIALIZER.

	recoverable_version_6_6: NATURAL_32 = 3
			-- 6.6 version for SED_RECOVERABLE_SERIALIZER.

feature -- Last revisions

	session_version: NATURAL_32 = 1
			-- Very latest version of session storable

	basic_version: NATURAL_32 = 2
			-- Very latest version of basic storable

	recoverable_version: NATURAL_32 = 3
			-- Very latest version of recoverable storable

note
	library:	"EiffelBase: Library of reusable components for Eiffel."
	copyright:	"Copyright (c) 1984-2008, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"

end
