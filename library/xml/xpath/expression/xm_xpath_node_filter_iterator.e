indexing

	description:

		"Objects that filter a node-sequence using a filter expression."

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2005, Colin Adams and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_NODE_FILTER_ITERATOR

inherit

	XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
		redefine
			is_node_iterator, as_node_iterator
		end

	XM_XPATH_TYPE

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

		-- This class is not used where the filter is a constant number.
		-- Instead, use XM_XPATH_POSITION_NODE_ITERATOR, so this class does not
		--  need to do optimization for numeric predicates.

create

	make, make_non_numeric

feature {NONE} -- Initialization

	make (a_base_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]; a_filter: XM_XPATH_EXPRESSION; a_context: XM_XPATH_CONTEXT) is
			-- Establish invariant.
		require
			base_iterator_before: a_base_iterator /= Void and then not a_base_iterator.is_error and then a_base_iterator.before
			filter_not_void: a_filter /= Void
			context_not_void: a_context /= Void
		do
			base_iterator := a_base_iterator
			filter := a_filter
			filter_context := a_context.new_context
			filter_context.set_current_iterator (base_iterator)
		ensure
			base_iterator_set: base_iterator = a_base_iterator
			filter_set: filter = a_filter
		end

	make_non_numeric (a_base_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]; a_filter: XM_XPATH_EXPRESSION; a_context: XM_XPATH_CONTEXT) is
			-- Establish invariant for non-numeric results.
		require
			base_iterator_before: a_base_iterator /= Void and then not a_base_iterator.is_error and then a_base_iterator.before
			filter_not_void: a_filter /= Void
			context_not_void: a_context /= Void
		do
			non_numeric := True
			make (a_base_iterator, a_filter, a_context)
		end
		
feature -- Access
	
	item: XM_XPATH_NODE is
			-- Node at the current position
		do
			Result := current_item
		end

	is_node_iterator: BOOLEAN is
			-- Does `Current' yield a node_sequence?
		do
			Result := True
		end

	as_node_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE] is
			-- `Current' seen as a node iterator
		do
			Result ?= ANY_.to_any (Current)
		end
	
feature -- Status report

	after: BOOLEAN is
			-- Are there any more items in the sequence?
		do
			Result := not before and then current_item = Void
		end

feature -- Cursor movement

	forth is
			-- Move to next position
		do
			index := index + 1
			advance
		end

feature -- Duplication

	another: like Current is
			-- Another iterator that iterates over the same items as the original
		do
			if non_numeric then
				create Result.make (base_iterator.another, filter, filter_context)
			else
				create Result.make_non_numeric (base_iterator.another, filter, filter_context)
			end
		end

feature {NONE} -- Implementation

	non_numeric: BOOLEAN
			-- Is statically known numeric result not possible?

	current_item: like item
			-- Current item

	base_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
			-- The underlying iterator

	filter: XM_XPATH_EXPRESSION
			-- Filter to apply to `base_iterator'

	filter_context: XM_XPATH_CONTEXT
			-- Evaluation context for the filter

	last_match_test: BOOLEAN
			-- Result from `test_match'

	advance is
			-- Move to next matching node.
		local
			next_item: like item
			matched: BOOLEAN
		do
			from
				matched := False
				if base_iterator.before then base_iterator.start end
			until
				is_error or else matched or else base_iterator.after
			loop
				next_item := base_iterator.item
				test_match
				matched := last_match_test
				if not base_iterator.after then base_iterator.forth end
				if base_iterator.is_error then set_last_error (base_iterator.error_value) end
			end

			if is_error then
				create {XM_XPATH_ORPHAN} current_item.make (Text_node, "") -- we need SOMETHING to set an error upon!
				current_item.set_last_error (error_value)
			elseif last_match_test then
				current_item := next_item
			else
				current_item := Void
			end
		end

	test_match is
			-- Test if the context item match the filter predicate?
		require
			filter_not_in_error: not filter.is_error
		local
			l_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
			l_item: XM_XPATH_ITEM
			l_boolean_value: XM_XPATH_BOOLEAN_VALUE
			l_integer_value: XM_XPATH_MACHINE_INTEGER_VALUE
		do
			last_match_test := False
			if non_numeric then
				filter.calculate_effective_boolean_value (filter_context)
				l_boolean_value := filter.last_boolean_value
				if l_boolean_value.is_error then
					set_last_error (l_boolean_value.error_value)
				else
					last_match_test := l_boolean_value.value
				end
			else

				-- This code is carefully designed to avoid reading more items from the
				-- iteration of the filter expression than are absolutely essential.

				filter.create_iterator (filter_context)
				l_iterator := filter.last_iterator
				if not l_iterator.is_error then
					l_iterator.start
					if not l_iterator.after then
						l_item := l_iterator.item
						if l_item.is_node then
							last_match_test := True
						elseif l_item.is_boolean_value then
							if l_item.as_boolean_value.value then	last_match_test := True	else l_iterator.forth; last_match_test := not l_iterator.after end
						elseif l_item.is_machine_integer_value then
							if l_item.as_machine_integer_value.value.to_integer = base_iterator.index then last_match_test := True else l_iterator.forth; last_match_test := not l_iterator.after end
						elseif l_item.is_numeric_value then
							create l_integer_value.make (base_iterator.index)
							last_match_test := l_item.as_numeric_value.same_expression (l_integer_value)
							if not last_match_test then l_iterator.forth; last_match_test := not l_iterator.after end
						else
							if l_item.is_string_value then
								last_match_test := STRING_.same_string (l_item.as_string_value.string_value, "")
								if not last_match_test then l_iterator.forth; last_match_test := not l_iterator.after end
							else
								last_match_test := True
							end
						end
					end
				else

					-- We are in error

					last_match_test := False
					set_last_error (l_iterator.error_value)
				end
			end
		end

invariant

	base_iterator_not_void: base_iterator /= Void
	filter_not_void: filter /= Void
	filter_context_not_void: filter_context /= Void

end