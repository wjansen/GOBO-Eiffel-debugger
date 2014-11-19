note

	description:
		"[ 
		 Abstract hash table using linear probing. 
		 Keys must be not the default value of the key type. 
		 Hash codes are to be computed by implementing classes. 
		 ]"

deferred class PC_HASH_TABLE [V_, K_ -> attached ANY]

inherit

	PC_TABLE [V_, K_]
		redefine
			copy,
			is_equal
		end

feature {NONE} -- Initialization 

	make (n: INTEGER)
		note
			action: "Create the table with capacity `n'."
		require
			positive: n > 0
		local
			k0: detachable K_
			v0: detachable V_
		do
			create keys.make_filled (k0, n)
			create data.make_filled (v0, n)
			slot := 0
			clash_count := 0
			max_clash_count := n // 3 + 1
		end

feature -- Access 

	valid_key (key: K_): BOOLEAN
		deferred
		end
	
	item alias "[]" (key: K_): attached V_
		do
			set_slot (key)
			check attached data [slot] end
			Result := data [slot]
		end

	key_of_value (v: detachable V_): detachable K_
		local
			k, k0: detachable K_
			h: INTEGER
		do
			slot := 0
			from
				h := keys.count
			until h = 0 loop
				h := h - 1
				k := keys [h]
				if k /= k0 and then data [h] = v then
					Result := k
					slot := h
					h := 0
				end
			end
		end
	
feature -- Status 

	count: INTEGER
			-- Number of elements. 

	has (key: detachable K_): BOOLEAN
		note
			return:
				"[
				 Does the table contain `key'?
				 Caution: the function has side effects on private attributes.
				 ]"
		local
			k0: detachable K_
		do
			if key /= k0 then
				set_slot (key)
				Result := keys[slot] /= k0
			end
		ensure then
			when_found: Result implies keys [slot] = key
		end

feature -- Element change 

	put (value: V_; key: K_)
		do
			if has (key) then
				data [slot] := value
			else
				force (value, key, True)
			end
		end

feature -- Removal 

	remove (key: K_)
		note
			action: "Remove `key' and its value if set."
		local
			k, k0: detachable K_
			v0: detachable V_
			h, h0, cap: INTEGER
		do
			if has (key) then
				cap := keys.count
				from
					k := key
					h0 := slot
					h := (h0 + 1) \\ cap
				until k = k0 loop
					k := keys [h]
					if k /= k0 then
						if hash (k) \\ cap = h then
							k := k0
						else
							keys [h0] := k
							data [h0] := data [h]
							h0 := h
							h := (h + 1) \\ cap
						end
					end
				end
				keys [h0] := k0
				data [h0] := v0
				count := count - 1
			end
		ensure
			removed: not has (key)
		end

	clear
		note
			action: "Remove all elements."
		local
			k0: detachable K_
			v0: detachable V_
		do
			keys.fill_with (k0, 0, keys.count - 1)
			data.fill_with (v0, 0, data.count - 1)
			count := 0
			clash_count := 0
			slot := 0
		end

feature -- Duplication and comparison 

	copy (other: like Current)
		do
			if other /= Current then
				standard_copy (other)
				keys := other.keys.twin
				data := other.data.twin
				slot := other.slot
				clash_count := other.clash_count
				max_clash_count := other.max_clash_count
			end
		end

	is_equal (other: like Current): BOOLEAN
		local
			k, k0: detachable K_
			h: INTEGER
		do
			Result := other = Current
			if not Result then
				from 
					Result := count = other.count
					h := keys.count
				until not Result or else h = 0 loop
					h := h - 1
					k := keys [h]
					if k /= k0 then
						Result := other [k] = data [h]
					end
				end
			end
		end

feature -- Traversal 

	new_cursor: PC_HASH_TABLE_CURSOR [V_, K_]
		do
			create Result.make (Current)
		end
	
	do_keys (action: PROCEDURE [ANY, TUPLE [K_]])
		local
			t: detachable TUPLE [k: K_]
			k, k0: detachable K_
			i, j, n: INTEGER
		do
			from
				n := keys.count
			until j = n loop
				k := keys [j]
				j := j + 1
				if k /= k0 and then attached k as k_ then
					t := [k_]
					action.call (t)
					i := j
					j := n
				end
			end
			if i > 0 and then attached t as tk then
				from
				until i = n loop
					k := keys [i]
					if k /= k0 and then attached k as k_ then
						tk.k := k_
						action.call (tk)
					end
					i := i + 1
				end
			end
		end

	do_values (action: PROCEDURE [ANY, TUPLE [attached V_]])
		local
			t: detachable TUPLE [v: attached V_]
			k, k0: detachable K_
			i, j, n: INTEGER
		do
			from
				n := keys.count
			until j = n loop
				k := keys [j]
				j := j + 1
				if k /= k0 and then attached data [j] as v then
					t := [v]
					action.call (t)
					i := j
					j := n
				end
			end
			if i > 0 and then attached t as tv then
				from
				until i = n loop
					if k /= k0 and then attached data [i] as v then
						tv.v := v
						action.call (tv)
					end
					i := i + 1
				end
			end
		end

	do_pairs (action: PROCEDURE [ANY, TUPLE [attached V_, K_]])
		local
			t: detachable TUPLE [v: detachable V_; k: K_]
			k, k0: detachable K_
			i, j, n: INTEGER
		do
			from
				n := keys.count
				i := n
			until j = n loop
				k := keys [j]
				j := j + 1
				if k /= k0 then
					t := [data [j], k]
					action.call (t)
					i := j
					j := n
				end
			end
			from
				check i < n implies t /= Void end
			until i = n loop
				k := keys [i]
				if k /= k0 then
					t.v := data [i]
					t.k := k
					action.call (t)
				end
				i := i + 1
			end
		end
			
feature {NONE} -- Hash function 

	hash (key: K_): INTEGER
		require
			valid: valid_key (key)
		deferred
		end

feature {PC_HASH_TABLE, PC_HASH_TABLE_CURSOR} -- Implementation 

	keys: SPECIAL [detachable K_]

	data: SPECIAL [detachable V_]

	slot: INTEGER

	clash_count: INTEGER

	max_clash_count: INTEGER

	set_slot (key: K_)
		note
			action:
			"[
			 Set `slot' such that `keys[slot]=key' if `key' is in the table, 
			 otherwise, set `slot' to the next free slot at or ofter `hash(key)'.
			 ]"
		require
			valid: valid_key (key)
		local
			k, k0: K_
			h, cap: INTEGER
		do
			if key /= keys[slot] then
				cap := keys.count
				from
					h := hash (key) \\ cap
					k := keys [h]					
				until k = k0 or else k = key loop
					h := (h + 1) \\ cap
					k := keys [h]
				end
				slot := h
			end
		end
			
	force (value: V_; key: K_; growing: BOOLEAN)
		note
			action: "Insert `value' at `key'."
		require
			valid: valid_key (key)
			not_has_key: not has (key)
			slot_set: slot = hash (key) \\ keys.count
		local
			cap: INTEGER
		do
			cap := keys.count
			if growing and then (clash_count > max_clash_count
													 or else count + 1 >= cap) then
				resize (2*cap + 1)
				set_slot (key)
			end
			keys [slot] := key
			data [slot] := value
			count := count + 1
		ensure
			has_key: has (key)
			extended: count = old count + 1
		end

	resize (n: INTEGER)
		require
			not_negative: n >= 0
		local
			old_keys: like keys
			old_data: like data
			k, k0: detachable K_
			h, old_n: INTEGER
		do
			old_n := keys.count
			if n > old_n then
				old_keys := keys
				old_data := data
				make (n)
				from
					h := 0
				until h = old_n loop
					k := old_keys [h]
					if k /= k0 then
						set_slot (k)	-- set `slot' to appropriate free slot
						force (old_data [h], k, False)
					end
					h := h + 1
				end
			end
		ensure
			grown: keys.count >= n
			same_count: count = old count
		end

invariant

	same_capacity: data.count = keys.count
	has_free_slots: count < keys.count
	clash_count_small_enough: clash_count <= max_clash_count
	valid_slot: 0 <= slot and slot < keys.count


note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
