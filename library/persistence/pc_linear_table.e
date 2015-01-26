class PC_LINEAR_TABLE [V_]

inherit

	PC_TABLE [V_, NATURAL]

create

	make

feature -- Initialization 

	make (n: INTEGER)
		require
			positive: n > 0
		local
			v0: detachable V_
		do
			last_data := v0
			last_key := 0
			create data.make_filled (v0, n)
			clear
		ensure
			capacity_large_enough: capacity >= n
			empty: is_empty
		end

feature -- Access 

	valid_key (key: NATURAL): BOOLEAN
		do
			Result := key > 0
		end

	item alias "[]" (key: NATURAL): V_ assign put
		local
			i: INTEGER
		do
			if key = last_key then
				Result := last_data
			else
				if key < free_index then
					i := key.to_integer_32
					Result := data [i]
				else	-- should not happen, just to make the routine void safe
				end
			end
		end

	key_of_value (v: V_): NATURAL
		local
			i: INTEGER
		do
			from
				i := free_index.to_integer_32 - 1
			until i = 0 or else data [i] = v loop
				i := i - 1
			end
			Result := i.to_natural_32
		end

feature -- Status 

	count: INTEGER

	capacity: INTEGER
		do
			Result := data.count
		end

	has (key: NATURAL): BOOLEAN
		local
			v0: detachable V_
			i: INTEGER
		do
			last_key := 0
			last_data := v0
			if key < free_index then
				i := key.to_integer_32
				last_key := key
				last_data := data [i]
				Result := last_data /= v0
			else
			end
		end

feature -- Element change 

	put (value: V_; key: NATURAL)
		local
			v0: detachable V_
			i: INTEGER
		do
			i := key.to_integer_32
			if value = v0 then
				if key < free_index and then data [i] /= v0 then
					data [i] := v0
					count := count - 1
				end
			else
				if i >= capacity then
					data := data.aliased_resized_area_with_default
						(v0, 2 * capacity.max (i) + 1)
				end
				if data [i] = v0 then
					count := count + 1
					free_index := free_index.max (key + 1)
				end
				data [i] := value
			end
			last_data := value
			last_key := key
		end

feature -- Removal 

	remove (key: NATURAL)
		local
			v0: detachable V_
		do
			put (v0, key)
		end
	
	clear
		local
			v0: detachable V_
		do
			data.fill_with (v0, 0, capacity - 1)
			count := 0
			free_index := 1
		end

feature -- Duplication 

	copy (other: like Current)
		do
			data := other.data.twin
			count := other.count
			free_index := other.free_index
		end

	is_equal (other: like Current): BOOLEAN
		do
			Result := count = other.count and then other.data.is_equal (data)
		end

feature -- Traversal 
	
	new_cursor: PC_LINEAR_TABLE_CURSOR [V_]
		note
			return: "Cursor for traversal over elements different from 0."	
		do
			create result.make (Current)
		end
	
	do_keys (action: PROCEDURE [ANY, TUPLE [NATURAL]])
		local
			v0: detachable V_
			t: TUPLE [n: NATURAL]
			i, n: NATURAL
		do
			from
				i := 1
				n := free_index
				t := [n]
			until i = n loop
				if data [i.to_integer_32] /= v0 then
					t.n := i
					action.call (t)
				end
				i := i + 1
			end
		end

	do_values (action: PROCEDURE [ANY, TUPLE [attached V_]])
		local
			t: detachable TUPLE [v: attached V_]
			v, v0: V_
			i, j, n: INTEGER
		do
			from
				j := 1
				n := free_index.to_integer_32
			until j = n loop
				v := data [j]
				j := j + 1
				if v /= v0 then
					t := [v]
					action.call (t)
					i := j
					j := n
				end
			end
			if i > 0 and then attached t as tv then
				from
				until i = n loop
					v := data [i]
					if v /= v0 then
						tv.v := v
						action.call (tv)
					end
					i := i + 1
				end
			end
		end

	do_pairs (action: PROCEDURE [ANY, TUPLE [attached V_, NATURAL]])
		local
			t: detachable TUPLE [v: attached V_; k: NATURAL]
			v, v0: detachable V_
			i, j, n: INTEGER
		do
			from
				j := 1
				n := free_index.to_integer_32 
			until j = n loop
				v := data [j]
				if v /= v0 then
					t := [v, j.to_natural_32]
					action.call (t)
					i := j + 1
					j := n
				else
					j := j + 1
				end
			end
			if i > 0 and then attached t as tvk then
				from
				until i = n loop
					v := data [i]
					if v /= v0 then
						t.v := v
						t.k := i.to_natural_32
						action.call (t)
					end
					i := i + 1
				end
			end
		end
	
feature {PC_LINEAR_TABLE} -- Implementation 

	data: SPECIAL [V_]

	last_key: NATURAL

	last_data: V_
	
	free_index: NATURAL
	
invariant

	capacity_large_enough: capacity >= count
	free_index_posotive: free_index > 0
	free_index_small_enough: free_index <= capacity
	item0_not_used: data [0] = TYPE[V_].default
	
end
