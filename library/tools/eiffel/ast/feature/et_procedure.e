indexing

	description:

		"Eiffel procedures"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_PROCEDURE

inherit

	ET_ROUTINE

feature -- Access

	type: ET_TYPE is
			-- Return type;
			-- Void for procedures
		do
			-- Result := Void
		ensure then
			procedure: Result = Void
		end

	signature: ET_SIGNATURE is
			-- Signature of current procedure
			-- (Create a new object at each call.)
		do
			create Result.make (arguments, Void)
		end

feature -- Conversion

	undefined_feature (a_name: like name): ET_DEFERRED_PROCEDURE is
			-- Undefined version of current feature
		do
			create Result.make (a_name, arguments, obsolete_message, preconditions,
				postconditions, clients, current_class)
			Result.set_is_keyword (is_keyword)
			Result.set_end_keyword (end_keyword)
			Result.set_semicolon (semicolon)
			Result.set_feature_clause (feature_clause)
			Result.set_implementation_class (implementation_class)
			if seeds /= Void then
				Result.set_seeds (seeds)
			else
				Result.set_first_seed (first_seed)
			end
			if precursors /= Void then
				Result.set_precursors (precursors)
			else
				Result.set_first_precursor (first_precursor)
			end
		end

feature -- System

	add_to_system is
			-- Recursively add to system classes that
			-- appear in current feature.
		do
			if arguments /= Void then
				arguments.add_to_system
			end
		end

feature -- Type processing

	has_formal_parameters (actual_parameters: ET_ACTUAL_PARAMETER_LIST): BOOLEAN is
			-- Does current feature contain formal generic parameter
			-- types whose corresponding actual parameter in
			-- `actual_parameters' is different from the formal
			-- parameter?
		do
			if arguments /= Void then
				Result := arguments.has_formal_parameters (actual_parameters)
			end
		end

	resolve_formal_parameters (actual_parameters: ET_ACTUAL_PARAMETER_LIST) is
			-- Replace in current feature the formal generic parameter
			-- types by those of `actual_parameters' when the 
			-- corresponding actual parameter is different from
			-- the formal parameter.
		do
			if arguments /= Void then
				if arguments.has_formal_parameters (actual_parameters) then
					arguments := arguments.cloned_arguments
					arguments.resolve_formal_parameters (actual_parameters)
				end
			end
		end

	resolve_identifier_types (a_class: ET_CLASS) is
			-- Replace any 'like identifier' types that appear in the
			-- implementation of current feature in class `a_class' by
			-- the corresponding 'like feature' or 'like argument'.
			-- Also resolve 'BIT identifier' types and check validity
			-- of arguments' name. Set `a_class.has_flatten_error' to
			-- true if an error occurs.
		do
			if arguments /= Void then
				arguments.resolve_identifier_types (Current, a_class)
			end
		end

end
