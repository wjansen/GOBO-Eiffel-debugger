indexing

	description:

		"Eiffel lists of feature clauses"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_FEATURE_CLAUSE_LIST

inherit

	ET_AST_NODE

	ET_AST_LIST [ET_FEATURE_CLAUSE]

creation

	make, make_with_capacity

feature -- Access

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			if not is_empty then
				Result := first.position
			else
				Result := tokens.null_position
			end
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			if not is_empty then
				Result := last.break
			end
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_feature_clause_list (Current)
		end

feature {NONE} -- Implementation

	fixed_array: KL_FIXED_ARRAY_ROUTINES [ET_FEATURE_CLAUSE] is
			-- Fixed array routines
		once
			create Result
		end

end
