indexing

	description:

		"Eiffel constrained formal generic parameters"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_CONSTRAINED_FORMAL_PARAMETER

inherit

	ET_FORMAL_PARAMETER
		rename
			make as make_unconstrained
		redefine
			constraint, creation_procedures,
			add_to_system, break, process
		end

creation

	make

feature {NONE} -- Initialization

	make (a_name: like name; a_constraint: like constraint; a_creation: like creation_procedures) is
			-- Create a new constrained formal generic parameter.
		require
			a_name_not_void: a_name /= Void
			a_constraint_not_void: a_constraint /= Void
		do
			arrow_symbol := tokens.arrow_symbol
			constraint := a_constraint
			creation_procedures := a_creation
			make_unconstrained (a_name)
		ensure
			name_set: name = a_name
			constraint_set: constraint = a_constraint
			creation_procedures_set: creation_procedures = a_creation
		end

feature -- Access

	arrow_symbol: ET_SYMBOL
			-- '->' symbol

	constraint: ET_TYPE
			-- Generic constraint

	creation_procedures: ET_CONSTRAINT_CREATOR
			-- Creation procedures expected in `constraint'

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			if creation_procedures /= Void then
				Result := creation_procedures.break
			else
				Result := constraint.break
			end
		end

feature -- Setting

	set_constraint (a_constraint: like constraint) is
			-- Set `a_constraint' to `constraint'.
		require
			a_constraint_not_void: a_constraint /= Void
		do
			constraint := a_constraint
		ensure
			constraint_set: constraint = a_constraint
		end

	set_arrow_symbol (an_arrow: like arrow_symbol) is
			-- Set `arrow_symbol' to `an_arrow'.
		require
			an_arrow_not_void: an_arrow /= Void
		do
			arrow_symbol := an_arrow
		ensure
			arrow_symbol_set: arrow_symbol = an_arrow
		end

feature -- System

	add_to_system is
			-- Recursively add to system classes that
			-- appear in the constraints.
		do
			constraint.add_to_system
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_constrained_formal_parameter (Current)
		end

invariant

	arrow_symbol_not_void: arrow_symbol /= Void
	constraint_not_void: constraint /= Void

end
