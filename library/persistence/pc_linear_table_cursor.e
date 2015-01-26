note

	description: "Class for traversal of a PC_HASH_TABLE."

class PC_LINEAR_TABLE_CURSOR [V_]

inherit

	PC_CURSOR [V_, NATURAL]
		redefine
			make,
			target
		end

create

	make

feature {NONE} -- Initalization

	make (t: like target)
		do
			Precursor (t)
			index := 0
			forth
		end
	
feature -- Access

	target: PC_LINEAR_TABLE [V_]
	
	item: V_
		do
			Result := target [index]
		end

feature -- Status report

	after: BOOLEAN
		do
			Result := index >= target.count.to_natural_32
		end
	
feature -- Cursor movement
	
	forth
		local
			k, k0: V_
		do
			from
			until k /= k0 or else after loop
				index := index + 1
				k := target [index]
			end
		end
	
feature {NONE} -- Implementation

	index: NATURAL
	
end
