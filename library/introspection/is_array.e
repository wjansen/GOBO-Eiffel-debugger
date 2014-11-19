note

	description: "Simple arrays of objects having types descenting from IS_NAME."

deferred class IS_ARRAY [D_ -> detachable IS_NAME]

inherit

	HASHABLE
		redefine
			copy,
			is_equal,
			hash_code
		end

feature {NONE} -- Initialization 

	make_1 (d: D_)
		do
			create data.make_filled (d, 1)
			count := 1
		ensure
			count_set: count = 1
			has_item: item (0) = d
		end

	make_2 (d0, d1: D_)
		do
			create data.make_filled (d0, 2)
			if attached data as dd then
				dd.put (d1, 1)
			end
			count := 2
		ensure
			count_set: count = 2
			has_item_0: item (0) = d0
			has_item_1: item (1) = d1
		end

feature -- Initialization 

	make_from_array (n: INTEGER; a: IS_ARRAY[D_]; start: INTEGER)
		note
			action: "Create object filled by entries of `a'."
		require
			n_not_negative: 0 <= n 
			a_not_void: attached a
			start_valid: 0 <= start and start + n <= a.count
		do
			if n > count then
				if attached a.data as ad then
					create data.make_filled (a [start], n)
					data.copy_data (ad, start, 0, n)
				end
			end
			count := n
		ensure
			count_set: count = n
		end
	
feature -- Access 

	count: INTEGER

	capacity: INTEGER
		do
			if attached data as dt then
				Result := dt.count
			end
		end

	valid_index (i: INTEGER): BOOLEAN
		do
			Result := 0 <= i and then i < count
		ensure
			in_range: Result = (0 <= i and then i < count)
		end

	item alias "[]" (i: INTEGER): D_
		require
			valid_index: valid_index (i)
		local
			dd: like data
		do
			dd := data
			check attached dd end
			Result := dd [i]
		end

feature -- Searching 

	has (d: D_): BOOLEAN
		note
			return: "Does `Current' contain `d'?"
		do
			if count > 0 then
				Result := index_of (d) < count
			end
		end

	index_of (d: D_): INTEGER
		note
			return: "Index of `d' in `Current' if `d' is an element, `count' else."
		do
			from
			until Result = count or else item (Result) = d loop
				Result := Result + 1
			end
		end

feature -- Duplication 

	copy (other: like Current)
		do
			if other /= Current then
				standard_copy (other)
				copy_contents (other)
			end
		ensure then
			equal_areas: attached data as dd and then attached other.data as odd 
			and then dd.is_equal (odd)
		end

	copy_contents (other: IS_ARRAY [D_])
		local
			d0: D_
			n: INTEGER
		do
			n := other.count
			if attached other.data as odd then
				d0 := odd [0]
				if attached data as dd then
					resize_with_pattern (n, d0)
				else
					create data.make_filled (d0, n)
				end
				if attached data as dd then
					dd.copy_data (odd, 0, 0, n)
				end
			else
				data := Void
			end
			count := n
		end
	
feature -- Comparison 

	is_equal (other: like Current): BOOLEAN
		note
			return: "Is array made of the same items as `other'?"
		do
			if other = Current then
				Result := True
			else
				Result := has_same_contents (other)
			end
		end

	has_same_contents (other: IS_ARRAY [D_]): BOOLEAN
		note
			return: "Does `Current' have the same data (count, values, arrangement)?"
		do
			Result := count = other.count
			if Result and count > 0 then
				Result := attached data as dd
				and then attached other.data as odd
				and then dd.same_items (odd, 0, 0, count)
			end
		end
	
feature -- HASHABLE 

	hash_code: INTEGER
		do
			if internal_hash_code = 0 then
				internal_hash_code := ($Current).to_integer_32 // 8 + count + 1
			end
			Result := internal_hash_code
		end

feature -- Status setting 

	swap (i, j: INTEGER)
		require
			valid_i: valid_index (i)
			valid_j: valid_index (j)
		local
			di: D_
		do
			if attached data as dd then
				if i /= j then
					di := dd [i]
					dd.put (dd [j], i)
					dd.put (di, j)
				end
			end
		end

	clear
		do
			data := Void
			count := 0
		ensure
			empty: count = 0
		end

feature {IS_ARRAY, IS_BASE} -- Implementation 

	data: detachable SPECIAL [D_]

feature {NONE} -- Implementation 

	internal_hash_code: like hash_code

	resize_with_pattern (n: INTEGER; pattern: D_)
		note
			action: "Adjust capacity to hold at least `n' elements."
			pattern: "Dummy object for filling, may be `Void' if D_ is detachable"
		require
			not_negative: 0 <= n
		do
			if n <= count then
			elseif n > capacity then
				if attached data as dt then
					data := dt.aliased_resized_area_with_default (pattern, n)
				else
					create data.make_filled (pattern, n)
				end
			end
		ensure
			same_count: count = old count
			capacity_enlared: capacity >= n.max (count)
		end

invariant

	capacity_big_enough: capacity >= count
	when_no_data: not attached data implies count = 0
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
