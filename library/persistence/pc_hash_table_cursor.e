note

	description: "Class for traversal of a PC_HASH_TABLE."

class PC_HASH_TABLE_CURSOR [V_, K_]

inherit

	PC_CURSOR [V_, K_]
		redefine
			make
		end

feature {NONE} -- Initalization

	make (t: like target)
		do
			Precursor (t)
			index := -1
			forth
		end
	
feature -- Access

	target: PC_HASH_TABLE_TABLE [V_, K_]
	
	item: V_
		do
			Result := target.data [index]
		end

feature -- Status report

	after: BOOLEAN
		do
			Result := index >= target.keys.count
		end
	
feature -- Cursor movement
	
	forth
		local
			k, k0: detachable K_
		do
			from
			until k /= k0 or else after loop
				index := index + 1
				k := target.keys [index]
			end
		end
	
feature {NONE} -- Implementation

	index: INTEGER
	
end
