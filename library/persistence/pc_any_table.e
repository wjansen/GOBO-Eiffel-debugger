class PC_ANY_TABLE [V_ -> detachable ANY]

inherit

	PC_HASH_TABLE [V_, attached ANY]
	
create

	make

feature -- Access 

	valid_key (key: detachable ANY): BOOLEAN
		do
			Result := key /= Void
		end

	valid_addition_key (key: detachable ANY): BOOLEAN
		do
			Result := attached key as k and then not has (k)
		end

feature -- Hash code 

	hash (key: attached ANY): INTEGER
		do
			Result := ($key).hash_code // 8 
		end

end
