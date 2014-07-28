note

	description:
		"[ 
		 Sortable and searchable sets of objects having types 
		 descenting from IS_NAME. 
		 ]"
		 
class IS_SPARSE_ARRAY [D_ -> detachable IS_NAME]

inherit

	IS_ARRAY [D_]
		redefine
			make_1,
			make_2
		end
	
create

	make_1,
	make_2,
	make

feature {} -- Initialization

	make (n: INTEGER; p: D_)
		note
			action: "Create `Current' with initial capacity `n'."
		require
			valid_size: 0 <= n
		do
			pattern := p
			if n > 0 then
				create data.make_filled (p, n)
			else
				data := Void
			end
		ensure
			capacity_set: capacity = n
			empty: count = 0
		end

	make_1 (d: D_)
		do
			pattern := d
			Precursor (d)
		end
	
	make_2 (d0, d1: D_)
		do
			pattern := d0
			Precursor (d0, d1)
		end
	
feature -- Access

	pattern: D_
			--
	
feature -- Status setting 

	force (d: D_; i: INTEGER)
		require
			valid_index: 0 <= i
		local
			m: INTEGER
		do
			m := count.max (i + 1)
			if m > capacity then
				resize_with_pattern (2 * m + 1, pattern)
			end
			check attached data end
			count := m
			data.put (d, i)
		ensure
			count_adjusted: count > i
			item_set: item (i) = d
		end

	resize (n: INTEGER)
		note
			action: "Adjust capacity to hold at least `n' elements."
		require
			not_negative: 0 <= n
		do
			resize_with_pattern (n, pattern)
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
