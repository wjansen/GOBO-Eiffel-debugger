note

	description:
		"[
		 Element of persistence closure composed of an object ident,
		 its type and (for objects of SPECIAL type) the element count.
		 ]"
		 
expanded class PC_TYPED_IDENT [I_]

feature -- Initialization

	make (i: like ident; t: like type; c: like count)
		do
			ident := i
			type := t
			count := c
		ensure
			ident_set: ident = i
			type_set: type = t
			count_set: count = c
		end
	
feature -- Access

	ident: detachable I_

	type: IS_TYPE

	count: NATURAL
	
end
	
