note

	description:
		"[ 
		 Sortable and searchable sets of objects having types 
		 descenting from IS_NAME. 
		 ]"
		 
class IS_SEQUENCE [D_ -> attached IS_NAME]

inherit

	IS_ARRAY [D_]
		redefine
			index_of,
			swap
		end

create

	default_create,
	make_1,
	make_2,
	make,
	make_from_array
	
feature {NONE} -- Initialization 

	make (n: INTEGER; pattern: D_)
		note
			action: "Create `Current' with initial capacity `n'."
			pattern: "Dummy object for filling, may be `Void' if D_ is detachable"
		require
			valid_size: 0 <= n
		do
			if n > 0 then
				create data.make_filled (pattern, n)
			else
				data := Void
			end
		ensure
			capacity_set: capacity = n
			empty: count = 0
		end

feature -- Access 

	comparator: detachable PREDICATE [ANY, TUPLE [D_, D_]]

	is_sorted: BOOLEAN
		do
			Result := count <= 1 or else is_explicitly_sorted
		ensure
			definition: Result = (count <= 1 or else is_explicitly_sorted)
		end

feature -- Status setting 

	add (d: D_)
		do
			resize_with_pattern (count+1, d)
			data.put (d, count)
			count := count + 1
			is_explicitly_sorted := False
		ensure
			added: count = old count + 1
			has_d: has (d)
		end

	swap (i, j: INTEGER)
		do
			if i /= j then
				Precursor (i, j)
				is_explicitly_sorted := False
			end
		end

	clean
		note
			action: "Remove multiple items."
		require
			sorted: is_sorted
		local
			di, dk: detachable D_
			i, k: INTEGER
		do
			if count > 0 then
				from
					k := count - 1
					dk := item (k)
				until k = 0 loop
					di := dk
					k := k - 1
					dk := item (k)
					if dk = di then
						count := count - 1
						from
							i := k
						until i = count loop
							i := i + 1
							data [i-1] := data[i]
						end
					end
				end
			end
		ensure
			still_sorted: is_sorted
		end

	remove (n: INTEGER)
		note
			action: "Remove `n' trailing items."
		require
			not_negative: n >= 0
			small_enough: n <= count
		local
			d: D_
			a: like data
			i, m: INTEGER
		do
			m := count - n
			if n = 0 then
			elseif n = count then
				data := Void
			elseif m < count // 3 then
				d := data [0]
				create a.make_filled (d, n)
				from
					i := m
				until i = 0 loop
					i := i - 1
					a [i] := data [i]
				end
				data := a
			else
				d := data [0]
				from
					i := count
				until i = m loop
					i := i - 1
					data [i] := d
				end
			end
			count := m
		ensure
			removed: count = old count - n
		end

feature -- Searching 

	index_of (d: D_): INTEGER
		note
			action: "Set `slot' if not found (side effect)."
		local
			low_item, middle_item, high_item: D_
			low, middle, high: INTEGER
		do
			Result := count
			inspect count
			when 0 then
				slot := 0
			when 1 then
				middle_item := item (0)
				if d < middle_item then
					slot := 0
				else
					if middle_item < d then
						slot := 1
					else
						Result := 0
					end
				end
			else
				if is_explicitly_sorted then
					slot := Result
					low := 0
					high := count - 1
					if attached comparator as comp then
						high_item := item (high)
						low_item := item (low)
						if comp.item ([high_item, d]) then
							-- `d' is not in the interval
							slot := high
						else
							if comp.item ([d, low_item]) then
								-- `d' is not in the interval
								slot := low
							else
								from
								invariant low <= high 
								until high - low <= 1 loop
									middle := (low + high) // 2
									middle_item := item (middle)
									if comp.item ([d, middle_item]) then
										-- `d' is in the lower half
  										high := middle
										high_item := middle_item
									else
										-- `d' is in the upper half
										low := middle
										low_item := middle_item
									end
								variant high - low
								end
								if comp.item ([d, high_item]) then
									if comp.item ([low_item, d]) then
										-- not found
										slot := low
									else
										Result := low
									end
								else
									Result := high
								end
							end
						end
					else
						high_item := item (high)
						low_item := item (low)
						if d < low_item then
							-- `d' is not in interval
							slot := low
						elseif high_item < d then
							-- `d' is not in interval
							slot := high
						else
							from
							invariant low <= high and then
								not (d < low_item) and not (high_item < d)
							until high - low <= 1 loop
								middle := (low + high) // 2
								middle_item := item (middle)
								if d < middle_item then
									high := middle
									high_item := middle_item
								else
									low := middle
									low_item := middle_item
								end
								variant high - low
							end
							if d < high_item then
								if low_item < d then
									-- not found
									slot := low
								else
									Result := low
								end
							else
								Result := high
							end
						end
					end
				else
					from
						Result := 0
					until Result = count or else d = item (Result) loop
						Result := Result + 1
					end
					slot := count
				end
			end
		end
	
feature -- Sorting 

	default_sort
		note
			action:
			"[
			 Sort items according to D_'s `<' function.
			 Resets `internal_hash_code' if not yet sorted.
			 ]"
		do
			if not is_sorted then
				default_heap_sort
				is_explicitly_sorted := True
				clean
			end
		ensure
			sorted: is_sorted
		end

	sort (comp: attached like comparator)
		note
			action:
				"[
				 Sort items and clean the set.
				 Resets `internal_hash_code' if not yet sorted.
				 ]"
			comp: "comparator to use"
		do
			if not is_sorted or else comparator /= comp then
				comparator := comp
				heap_sort (comp)
				is_explicitly_sorted := True
				clean
			end
		ensure
			sorted: is_sorted
			comparator_set: comparator = comp
		end

feature {IS_SEQUENCE} -- Implementation 

	is_explicitly_sorted: BOOLEAN

feature {NONE} -- Implementation 

	default_heap_sort
		local
			d, d1, temp: D_
			parent, child, child_1, i, n: INTEGER
		do
			from
				n := count
				i := n // 2
			until n = 0 loop
				if i > 0 then
					i := i - 1
					temp := data [i]
				else
					n := n - 1
					temp := data [n]
					if n > 0 then
						data [n] := data [0]
					end
				end
				if n > 0 then
					from
						parent := i
						child := i*2 + 1
					until child >= n loop
						d := data [child]
						child_1 := child + 1
						if child_1 < n then 
							d1 := data [child_1]
							if d < d1 then
								child := child_1
								d := d1
							end
						end
						if temp < d then
							data [parent] := d
							parent := child
							child := parent*2 + 1
						else
							child := n
						end
					end
					data [parent] := temp
				end
			end
		end
	
	heap_sort  (comp: attached like comparator)
		local
			d, d1, temp: D_
			parent, child, child_1, i, n: INTEGER
		do
			from
				n := count
				i := n // 2
			until n = 0 loop
				if i > 0 then
					i := i - 1
					temp := data [i]
				else
					n := n - 1
					temp := data [n]
					if n > 0 then
						data [n] := data [0]
					end
				end
				if n > 0 then
					from
						parent := i
						child := i*2 + 1
					until child >= n loop
						d := data [child]
						child_1 := child + 1
						if child_1 < n then
							d1 := data [child_1]
							if comp.item ([d, d1]) then
								child := child_1
								d := d1
							end
						end
						if comp.item ([temp, d]) then 
							data [parent] := d
							parent := child
							child := parent*2 + 1
						else
							child := n
						end
					end
					data [parent] := temp
				end
			end
		end

	slot: INTEGER
			-- Index to place a not yet contained item;
			-- set by `index_of', `has' and meanignful only if item not found. 
	
invariant

	when_small: count < 2 implies is_sorted
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
