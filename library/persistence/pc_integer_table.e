class PC_INTEGER_TABLE [TI_]

inherit

	PC_HASH_TABLE [TI_, NATURAL]
	
create

	make

feature -- Access 

	valid_key (key: NATURAL): BOOLEAN
		do
			Result := key /= 0
		end

	valid_addition_key (key: NATURAL): BOOLEAN
		do
			Result := not has (key)
		end

feature -- Hash code 

	hash (key: NATURAL): INTEGER
		do
			Result := key.hash_code
		end

end
