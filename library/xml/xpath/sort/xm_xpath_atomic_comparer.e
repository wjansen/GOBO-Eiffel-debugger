indexing

	description:

		"Objects that compare two atomic values"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_ATOMIC_COMPARER

inherit

	KL_SHARED_EXCEPTIONS

creation

	make

feature {NONE} -- Initialization

	make (a_collator: ST_COLLATOR) is
			-- Establish invariant.
		require
			collator_not_void: a_collator /= void
		do
			collator := a_collator
		ensure
			collator_set: collator = a_collator
		end

feature -- Access

	collator: ST_COLLATOR
			-- Collator for string comparisons

feature -- Comparison

	three_way_comparison (an_atomic_value, another_atomic_value: XM_XPATH_ATOMIC_VALUE): INTEGER is
			-- Comparison of two atomic values
		require
			first_value_not_void: an_atomic_value /= Void
			second_value_not: another_atomic_value /= Void
			are_comparable (an_atomic_value, another_atomic_value)
		local
			an_untyped_atomic_value: XM_XPATH_UNTYPED_ATOMIC_VALUE
			a_string_value, another_string_value: XM_XPATH_STRING_VALUE
		do
			an_untyped_atomic_value ?= an_atomic_value
			if an_untyped_atomic_value /= void then
				Result := an_untyped_atomic_value.three_way_comparison_using_collator (another_atomic_value, collator)
			else
				an_untyped_atomic_value ?= another_atomic_value
				if an_untyped_atomic_value /= void then
					Result := - an_untyped_atomic_value.three_way_comparison_using_collator (an_atomic_value, collator)
				else
					-- TODO
				end
			end
		ensure
			three_way_comparison: Result >= -1 and Result <= 1
		end

feature -- Status report

	are_comparable (an_atomic_value, another_atomic_value: XM_XPATH_ATOMIC_VALUE): BOOLEAN is
			-- Are `an_atomic_value' and `another_atomic_value' comparable?
		require
			first_value_not_void: an_atomic_value /= Void
			second_value_not: another_atomic_value /= Void
		local
			an_untyped_atomic_value: XM_XPATH_UNTYPED_ATOMIC_VALUE
			a_numeric_value: XM_XPATH_NUMERIC_VALUE
			a_string_value: XM_XPATH_STRING_VALUE
		do
			an_untyped_atomic_value ?= an_atomic_value
			if an_untyped_atomic_value /= Void then
				Result := an_untyped_atomic_value.is_comparable (another_atomic_value)
			else
				a_numeric_value ?= an_atomic_value
				if a_numeric_value /= Void then
					Result := a_numeric_value.is_comparable (another_atomic_value)
				else
					a_string_value ?= an_atomic_value
					if a_string_value /= Void then
						Result := a_string_value.is_comparable (another_atomic_value)
					else
						Exceptions.raise ("Incomplete set of atomic values in {XM_XPATH_ATOMIC_COMPARER}.are_comparable")
					end
				end
			end
		end

invariant

	collator_not_void: collator /= void

end

