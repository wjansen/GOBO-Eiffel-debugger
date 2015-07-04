note

	description:
		"[ 
		 Abstract hash table using linear probing. 
		 Keys must be not the default value of the key type. 
		 Hash codes are to be computed by implementing classes. 
		 ]"

deferred class PC_HOPSCOTCH_TABLE [V_ -> detachable ANY, K_ -> attached ANY]

inherit

	PC_TABLE [V_, K_]
		redefine
			copy,
			is_equal
		end

feature {NONE} -- Initialization 

	make (n: INTEGER)
		note
			action: "Create the table with capacity at least `n'."
		require
			positive: n > 0
		local
			k0: detachable K_
			v0: V_
			prim: INTEGER
		do
			prim := primes.higher_prime (n)
			create keys.make_filled (k0, prim)
			create data.make_filled (v0, prim)
			create clashes.make_filled (0, prim)
			count := 0
			slot := -1
			from
				prim := prim - 1
				log2_cap := 0	until prim & 0x08000000 /= 0 loop
				log2_cap := log2_cap + 1
				prim := prim |<< 1
			end
		end

feature -- Access 

	valid_key (key: detachable K_): BOOLEAN
		deferred
		end
	
	key_of_value (v: detachable V_): detachable K_
    local
			k, k0: detachable K_
			i: INTEGER
		do
			from
				i := keys.count
				slot := -1
			until i = 0 loop
				i := i - 1
				k := keys [i]
				if k /= k0 and then data [i] = v then
					Result := k
					slot := i
					i := 0
				end
			end
		end
	
	item alias "[]" (key: K_): V_ assign put
		local
			k0: K_
		do
			if has (key) then
				Result := data[slot]
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
				if slot < 0 or else keys[slot] /= key then
					set_slot (key)
				end
				Result := slot >= 0
			end
		ensure then
			when_found: Result implies slot >= 0 and then keys [slot] = key
		end

feature -- Element change 

	put (value: V_; key: K_)
	  local
			k0: K_
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
			h: INTEGER
		do
			if has (key) then
				h := hash (key)
				hash_del (h, slot - h)
			end
		end

	clear
		note
			action: "Remove all items."
		local
			k0: detachable K_
			v0: V_
		do
			keys.fill_with (k0, 0, keys.count - 1)
			data.fill_with (v0, 0, data.count - 1)
			clashes.fill_with (0, 0, clashes.count - 1)
			count := 0
		end

feature -- Duplication and comparison 

	copy (other: like Current)
		do
			if other /= Current then
				standard_copy (other)
				keys := other.keys.twin
				data := other.data.twin
				clashes := other.clashes.twin
			end
		end

	is_equal (other: like Current): BOOLEAN
		local
			k, k0: detachable K_
			h: INTEGER
		do
			Result := other = Current
			if not Result then
				-- TODO
				from 
					Result := count = other.count
					h := keys.count
				until not Result or else h = 0 loop
					h := h - 1
					k := keys [h]
					if k /= k0 then
						check k /= Void end
						if attached data [h] as dh then
							Result := other [k] = dh
						end
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

	do_values (action: PROCEDURE [ANY, TUPLE [V_]])
		local
			t: detachable TUPLE [v: V_]
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

	do_pairs (action: PROCEDURE [ANY, TUPLE [V_, K_]])
		local
			t: detachable TUPLE [v: V_; k: K_]
			v: V_
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
					check k /= Void end
					v := data [j]
					t := [v, k]
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
					check k /= Void end
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

	data: SPECIAL [V_]

	clashes: SPECIAL [INTEGER]
	
	slot: INTEGER

	force (value: V_; key: K_; growing: BOOLEAN)
		note
			action: "Insert `value' at `key'."
		require
			valid: valid_key (key)
			not_has_key: not has (key)
		do
			from
			until hash_put (value, key) loop
				resize (2*keys.count)
			end
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
			i, old_n: INTEGER
		do
			old_n := keys.count
			if n > old_n then
				old_keys := keys
				old_data := data
				make (n)
				from
					i := 0
				until i = old_n loop
					k := old_keys [i]
					if k /= k0 then
						force (old_data [i], k, False)
					end
					i := i + 1
				end
			end
		ensure
			grown: keys.count >= n
			same_count: count = old count
		end

	primes: PRIMES
		once
			create Result
		end

feature {NONE} -- Hopscotch implementation

	log2_cap: INTEGER

	set_slot (key: K_)
		local
			h, hi, n: INTEGER
			i, l: INTEGER
		do
			n := keys.count
			h := hash (key) \\ n
			l := clashes[h]
			slot := -1
			from
				i := succ (l, 0)
			until i < 0 loop
				hi := (h+i) \\ n
				if keys[hi] = key then
					slot := hi
					i := -1
				else
					i := succ (l, i+1)
				end
			end
		ensure
			when_found: slot >= 0 implies keys [slot] = key
		end
	
	succ (l: INTEGER; i: INTEGER): INTEGER
		require
			valid_clash: 0 < l
		local
			k: INTEGER
		do
			if l & (1 |<< i) /= 0 then
				Result := i
			else
				k := l & (0x7fffffff |<< i)
				if k = 0 then
					Result := -1
				else
					Result := ffs (k)
				end
			end
		end

	move (h: INTEGER; i, j: INTEGER)
		require
			valid_hash: 0 <= h and h < clashes.count
		local
			v, v0: V_
			k, k0: K_
			l, hi, hj, n: INTEGER
			cap: INTEGER
		do
			l := clashes[h]
			l := l & (1 |<< i).bit_not
			l := l | (1 |<< j)
			clashes[h] := l
			n := keys.count
			hi := (h+i) \\ n
			hj := (h+j) \\ n
			k := keys[hi]
			keys[hi] := k0
			keys[hj] := k
			v := data[hi]
			data[hi] := v0
			data[hj] := v
		end

	hash_del (h: INTEGER; i: INTEGER)
		require
			valid_hash: 0 <= h and h < clashes.count
		local
			k0: K_
			v0: V_
			b, j, l, n: INTEGER
		do
			n := keys.count
			j := (h+i) \\ n
			l := clashes[h]
			b := 1 |<< i
			if data[j] = v0 or else l & b = 0 then
			else
				keys[j] := k0
				data[j] := v0
				l := l & b.bit_not  --			unset (clashes[h], i)
				clashes[h] := l
				count := count - 1
			end
			slot := -1
		end

	probe (h: INTEGER): INTEGER
		require
			valid_hash: 0 <= h and h < clashes.count
		local
			k0: K_
			i, n: INTEGER
			found: BOOLEAN
		do
			n := keys.count
			from
			until h+i = n loop
				if keys[h+i] = k0 then
					Result := i
					i := n - h
					found := True
				else
					i := i + 1
				end
			end
			if not found then
				from
					i := 0
				until keys[i] = k0 loop
					i := i + 1
				end
				Result := n - h + i
			end
		end

	ffs(h: INTEGER): INTEGER
		require
			not_zero: h /= 0
		local
			l: INTEGER
		do
			from
				l := h
			until l & 1 /= 0 loop
				Result := Result + 1
				l := l |>> 1
			end
		end
			
	seek (h: INTEGER): INTEGER
		require
			valid_hash: 0 <= h and h < clashes.count
		local
			i, hi, n: INTEGER
		do
			n := keys.count
			from
				i := log2_cap - 1
			until i = 0 loop
				hi := (n+h-i) \\ n
				hi := clashes[hi]
				if hi /= 0 and then ffs (hi) < i then 
					Result := i
					i := 0
				else
					i := i - 1
				end
			end			
		end

	hash_put (value: V_; key: K_): BOOLEAN
		local
			v0: V_
			d, h, hd, i, j, l, n, z: INTEGER
		do
			n := keys.count
			h := hash (key) \\ n
			d := probe (h)
			from
				Result := value /= v0 and count < n
			until not Result or else d < log2_cap loop 
				hd := (h+d) \\ n
				z := seek (hd)
				Result := z /= 0
				if Result then
					j := z
					z := (n+hd-z) \\ n
					i := succ (clashes[z], 0)
					move (z, i, j)
					d := (n+z+i-h) \\ n
				end
			end
			if Result then
				hd := (h+d) \\ n
				keys[hd] := key
				data[hd] := value
				l := clashes[h]
				l := l | (1 |<< d)
				clashes[h] := l
				count := count + 1
				slot := hd
			else
				slot := -1
			end
		ensure
			extended: Result implies count = old count + 1
		end

invariant

	same_capacity: data.count = keys.count and clashes.count = keys.count
	has_free_slots: count < keys.count
	valid_slot: 0 <= slot and slot < keys.count

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
