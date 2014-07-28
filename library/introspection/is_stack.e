note

	description: "Stack of objects having types descenting from IS_NAME."

class IS_STACK [D_ -> IS_NAME]

inherit

	IS_ARRAY [D_]
		export
			{IS_BASE} clear
		end

create

	default_create

feature -- Access 

	is_empty: BOOLEAN
		do
			Result := count = 0
		ensure
			defininition: Result = (count = 0)
		end

	top: D_
		require
			not_empty: not is_empty
		local
			dd: like data
		do
			dd := data
			check attached dd end
			Result := dd [count - 1]
		ensure
			definition: attached data as d_ and then Result = d_ [count - 1]
		end

	below_top (n: INTEGER): D_
		require
			enough_items: n < count
		local
			dd: like data
		do
			dd := data
			check attached dd end
			Result := dd [count - 1 - n]
		ensure
			definition: attached data as d_ and then Result = d_ [count - 1 - n]
		end

feature -- Element change 

	push (d: D_)
		local
			m: INTEGER
		do
			m := count + 1
			if m > capacity then
				resize_with_pattern (2 * m + 1, d)
			end
			if attached data as dd then
				dd.put (d, count)
			end
			count := m
		ensure
			d_is_top: top = d
			pushed: count = old count + 1
		end

	pop (n: INTEGER)
		require
			not_negative: n >= 0
			enough_items: n <= count
		local
			d: D_
			i: INTEGER
		do
			from
				i := n
			until i = 0 loop
				count := count - 1
				data[count] := d
				i := i - 1
			end
			if count = 0 then
				data := Void
			end
		ensure
			popped: count = old count - n
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
