note

	description: "Compile time description of types in an Eiffel system."

class ET_IS_EXPANDED_TYPE

inherit

	ET_IS_NORMAL_TYPE
		undefine
			make,
			make_in_system,
			is_subobject
		redefine
			declare, 
			base_class,
			add_operators,
			compute_flags
		end

	IS_EXPANDED_TYPE
		undefine
			generic_at,
			effector_at,
			field_at,
			constant_at,
			routine_at,
			set_fields,
			is_equal
		redefine
			base_class
		end

create 

	declare, declare_from_pattern

feature {} -- Initialization 

	declare (o: like origin; id: INTEGER; s: ET_IS_SYSTEM)
		do
			Precursor (o, id, s)
			inspect id
			when Char8_ident, Int8_ident, Nat8_ident then
				instance_bytes := 1
			when Int16_ident, Nat16_ident then
				instance_bytes := 2
			when Char32_ident, Int32_ident, Nat32_ident, Real32_ident then
				instance_bytes := 4
			when Int64_ident, Nat64_ident, Real64_ident then
				instance_bytes := 8
			else
			end
		end
	
feature -- Access

	base_class: ET_IS_CLASS_TEXT
	
feature {} -- Implementation

	standard_operators: DS_HASH_SET[STRING]
		once
			create Result.make_equal(50)
			Result.put("identity")
			Result.put("opposite")
			Result.put("plus")
			Result.put("minus")
			Result.put("product")
			Result.put("quotient")
			Result.put("integer_quotient")
			Result.put("integer_remainder")
			Result.put("power")
			Result.put("is_less")
			Result.put("is_greater")
			Result.put("is_less_equal")
			Result.put("is_greater_equal")
			Result.put("negated")
			Result.put("conjuncted")
			Result.put("conjuncted_semistrict")
			Result.put("disjuncted")
			Result.put("disjuncted_semistrict")
			Result.put("disjuncted_exclusive")
			Result.put("implication")
		end
	
	add_operators (buffer: like routine_buffer; s: ET_IS_SYSTEM)
		local
			bc: ET_CLASS
			qq: ET_QUERY_LIST
			q: ET_QUERY
			dq: ET_DYNAMIC_FEATURE
			r: ET_IS_ROUTINE
			nm: STRING
			i: INTEGER
		do
			bc := origin.base_class
			from
				qq := bc.queries
				i := qq.count
			until i = 0 loop
				q := qq.item (i)
				nm := s.internal_name(q.lower_name)
				if attached q.alias_name and then standard_operators.has (nm)
					and then not attached routine_by_name(nm, False)
				 then
					dq := origin.dynamic_query (q, s.origin)
					create r.declare (dq, Current, False, s)
					buffer.push (r)
				end
				i := i - 1
			end
		end
	
	compute_flags (id: INTEGER): INTEGER
		do
			Result := Precursor (id)
			if not origin.is_generic then
				Result := Result | Missing_id_flag
			end
			Result := Result | Copy_semantics_flag
		end

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
