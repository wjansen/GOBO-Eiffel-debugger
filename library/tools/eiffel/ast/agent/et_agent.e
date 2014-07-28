note

	description:

		"Eiffel agents"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2006, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_AGENT

inherit

	ET_EXPRESSION
		redefine
			is_never_void
		end

	HASHABLE

feature -- Access

	agent_keyword: ET_AGENT_KEYWORD
			-- 'agent' keyword

	target: ET_AGENT_TARGET
			-- Target

	arguments: ET_AGENT_ARGUMENT_OPERANDS
			-- Arguments

	closed_operands_tuple: ET_DYNAMIC_TUPLE_TYPE
			-- Tuple type of the closed operands
	
	implicit_result: ET_RESULT
			-- Fictitious node corresponding to the result of the
			-- associated feature when it's a query
		do
		end

feature -- Status report

	is_qualified_call: BOOLEAN
			-- Is current call qualified?
		deferred
		end

	is_procedure: BOOLEAN
			-- Is the associated feature a procedure?
		deferred
		ensure
			definition: Result = (implicit_result = Void)
		end

	is_call_agent: BOOLEAN
			-- Is current agent a call agent?
		do
			Result := False
		end

	is_inline_agent: BOOLEAN
			-- Is current agent an inline agent?
		do
			Result := False
		end

	is_never_void: BOOLEAN = True
			-- Can current expression never be void?

feature -- Setting

	set_agent_keyword (an_agent: like agent_keyword)
			-- Set `agent_keyword' to `an_agent'.
		require
			an_agent_not_void: an_agent /= Void
		do
			agent_keyword := an_agent
		ensure
			agent_keyword_set: agent_keyword = an_agent
		end

	set_arguments (an_arguments: like arguments)
			-- Set `arguments' to `an_arguments'.
		do
			arguments := an_arguments
		ensure
			argumnts_set: arguments = an_arguments
		end

	set_closed_operands_tuple(a_type: ET_DYNAMIC_TYPE)
		require
			a_type_not_void: a_type /= Void
		do
			closed_operands_tuple ?= a_type
		ensure
			closed_operands_tuple_set: closed_operands_tuple = a_type
		end
	
feature -- HASHABLE

	hash_code: INTEGER
		do
			if internal_hash_code = 0 then
				internal_hash_code := 2 * agent_keyword.position.line 
					* agent_keyword.position.column + 1
				if internal_hash_code < 0 then
					internal_hash_code := -internal_hash_code
				end
			end
			Result := internal_hash_code
		end

feature {ET_AGENT_IMPLICIT_CURRENT_TARGET} -- Implicit node positions

	implicit_target_position: ET_AST_NODE
			-- Node used to provide a position to the implicit target if any
		deferred
		ensure
			implicit_target_position_not_void: Result /= Void
		end

feature {ET_AGENT_IMPLICIT_OPEN_ARGUMENT} -- Implicit node positions

	implicit_argument_position: ET_AST_NODE
			-- Node used to provide a position to implicit open arguments if any
		deferred
		ensure
			implicit_argument_position_not_void: Result /= Void
		end

feature {NONE} -- Implementation

	internal_hash_code: INTEGER
		-- Fixed hashcode value 

invariant

	agent_keyword_not_void: agent_keyword /= Void
	target_not_void: target /= Void

end
