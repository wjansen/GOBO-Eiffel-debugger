indexing

	description:

		"Tests"

	library: "Gobo Eiffel Test Library"
	copyright: "Copyright (c) 2000-2001, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class TS_TEST

feature -- Access

	name: STRING is
			-- Name
		deferred
		ensure
			name_not_void: Result /= Void
		end

	variables: TS_VARIABLES
			-- Defined variables

feature -- Measurement

	count: INTEGER is
			-- Number of test cases
		deferred
		ensure
			count_positive: Result >= 0
		end

feature -- Execution

	execute (a_summary: TS_SUMMARY) is
			-- Run test and put results in `a_summary'.
		require
			a_summary_not_void: a_summary /= Void
		deferred
		end

invariant

	variables_not_void: variables /= Void

end
