note

	description: "Node of a parsed expression tree representing an index range. "

class DG_RANGE_EXPRESSION

inherit

	DG_EXPRESSION
		rename
			make as make_single,
			type as item_type,
			append_arguments as append_indices
		redefine
			parent,
			is_single,
			is_range,
			item_type,
			as_any,
			compute_qualified,
			append_indices,
			append_placeholder
		end

create

	make

feature {NONE} -- Initialization 

	make (p: attached like parent; c: INTEGER)
		do
			make_single (c)
			parent := p.bottom
			parent.set_down (Current)
			set_entity (range_entity)
		ensure
			parent_set: parent = p
		end

feature -- Access 

	parent: DG_EXPRESSION
	
	capacity: NATURAL

	lower_limit: NATURAL

	upper_limit: NATURAL

	at_index: NATURAL

	valid_index (i: NATURAL; ds: IS_STACK_FRAME; values: DG_VALUE_STACK): BOOLEAN
		do
			Result := 0 <= i and then i < capacity
			if Result and then is_selective
				and then attached arg as a and then attached a.down as ad
			 then
				move_to_index (i)
				ad.compute_one (ds, values)
				Result := values.top.as_boolean
				values.pop (1)
			end
		end

feature -- Status 

	is_single: BOOLEAN = False

	is_range: BOOLEAN = True

	is_selective: BOOLEAN
		note
			return: "Are valid indices selected by predicate?"
		do
			if attached arg as a then
				Result := a.entity = if_entity
			end
		end

	item_type: detachable IS_TYPE

	array_type: detachable IS_SPECIAL_TYPE
			-- Type of the underlying SPECIAL object. 

	array_location: POINTER
		do
			Result := parent.address
		end

	as_any: detachable ANY
		local
			t: like item_type
		do
			t := item_type
			Result := Precursor
			item_type := t
		end

feature -- Status setting 

	move_to_index (i: NATURAL)
		require
			valid_index: i < capacity
		do
			if attached array_type as at then
				offset := at.item_offset (i.to_integer_32)
				at_index := i
				adjust_address
			end
		end

feature -- Basic operation 

	compute_qualified (ds: IS_STACK_FRAME; values: DG_VALUE_STACK; left: BOOLEAN)
		do
			if left then
				Precursor (ds, values, left)
			else
				values.put (Current)
				if attached {like array_type} parent.type as at
					and then attached parent.as_any as pref
					and then attached arg as a
				 then
					in_object := pref
					if attached a.entity as ae then
						array_type := at
						item_type := at.generic_at (0)
						capacity := debuggee.special_capacity (pref, at)
						if ae = all_entity or else ae = if_entity then
							lower_limit := 0
							upper_limit := capacity - 1
							adjust_address
						else
							lower_limit := compute_index (ds, values, a, 0, capacity - 1)
							if attached a.next as s then 
								if s.entity = count_entity and then attached s.arg as sa then
									upper_limit := lower_limit - 1
										+ compute_index (ds, values, sa, 1, capacity - lower_limit)
								else
									upper_limit := compute_index (ds, values, s, lower_limit, capacity - 1)
								end
							end
						end
						move_to_index (lower_limit)
					end
				end
			end
		end

feature {DG_EXPRESSION} -- Output 

	append_indices (s: STRING; stop_at_error: BOOLEAN): BOOLEAN
		local
			n: like next
		do
			if attached arg as a then
				s.extend (' ')
				s.extend ('[')
				s.extend ('[')
				Result := a.append_checked_out (s, stop_at_error, Void)
				if Result then
					if attached a.next as an then
						if an.entity = count_entity then
							s.extend (' ')
							s.extend ('`')
							n := an.arg
						else
							s.extend (',')
							s.extend (' ')
							n := an
						end
						check
							attached n
						end
						Result := n.append_checked_out (s, stop_at_error, Void)
					end
				end
				if Result then
					s.extend (']')
					s.extend (']')
				end
			end
		end

	append_placeholder (s: STRING)
		do
			if fast_name [1] = '!' then
				s.append_natural_32 (at_index)
			else
				Precursor (s)
			end
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
