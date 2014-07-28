note

	description:
		"Sets of objects having types descenting from IS_NAME."
		 
class IS_SET [D_ -> attached IS_NAME]

inherit

	IS_SEQUENCE [D_]
		rename
			remove as remove_last_items
		export
			{} sort, default_sort, swap, clean, index_of
		redefine
			make,
			make_1,
			add,
			is_sorted
		end

create

	make_1,
	make
	
feature {} -- Initialization 

	make (n: INTEGER; pattern: D_)
		do
			Precursor (n, pattern)
			is_explicitly_sorted := True
		end

	make_1 (d: D_)
		do
			Precursor (d)
			is_explicitly_sorted := True
		end

feature -- Access 

	is_sorted: BOOLEAN = True

feature -- Status setting 

	add (d: D_)
		local
			di: D_
			i: INTEGER
		do
			if count = 0 then
				make_1 (d)
			elseif not has (d) then
				resize_with_pattern (count+1, d)
				from
					i := count 
					di := data [i-1]
				until i = 0 or else di < d loop
					data [i] := di
					i := i - 1
					if i > 0 then
						di := data [i-1]
					end
				end
				data [i] := d
				count := count + 1
			end
		end

	remove (d: D_)
		note
			action: "Remove `d' if present."
		local
			i: INTEGER
		do
			i := index_of (d)
			if i < count then
				count := count - 1
				from
				until i = count loop
					data [i] := data [i+1]
					i := i + 1
				end
			end
		ensure
			removed: not has (d)
		end

invariant

	is_explicitly_sorted: is_explicitly_sorted = True
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
