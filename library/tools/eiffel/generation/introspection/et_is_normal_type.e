note

	description: "Compile time description of types in an Eiffel system."

class ET_IS_NORMAL_TYPE

inherit

	ET_IS_TYPE
		undefine
			invariant_function,
			is_actionable
		redefine
			declare,
			base_class,
			compute_flags,
			pre_store,
			post_store
		end

	IS_NORMAL_TYPE
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
		note
			action: "Create `Current' according to `o'."
			id: "type ident"
		local
			params: ET_ACTUAL_PARAMETER_LIST
			static: ET_TYPE
			dynamic: ET_DYNAMIC_TYPE
			t: ET_IS_TYPE
			f: ET_IS_FIELD
			i, n: INTEGER
		do
			Precursor (o, id, s)
			s.force_class (o.base_class)
			base_class := s.last_class
			if o.is_generic then
				params := o.base_type.actual_parameters
				from
					n := params.count
					i := 0
				until i = n loop
					i := i + 1
					static := params.type (i)
					dynamic := s.origin.dynamic_type (static, o.base_class)
					check attached dynamic end
					s.force_type (dynamic)
					s.push_type (s.last_type.ident)
				end
				generics := s.extract_types (n, False, True)
			end
			if o.is_alive then
				declare_fields (s)
				declare_routines (s)
			end
			declare_constants (s)
		end

feature -- Access 

	base_class: ET_IS_CLASS_TEXT

feature {} -- PC_ACTIONABLE

	pre_store
		do
			preserve
			if flags & Agent_expression_flag = 0
				and then not base_class.is_debug_enabled 
			 then
				fields := Void
			end
		end
	
	post_store
		do
			restore
		end
	
feature {} -- Implementation 

	declare_constants (s: ET_IS_SYSTEM)
		note
			action: "Create all constant attributes."
		local
			qq: ET_DYNAMIC_FEATURE_LIST
			df: ET_DYNAMIC_FEATURE
			cls: ET_CLASS
			c: ET_IS_CONSTANT
			i, n, na: INTEGER
		do
			if s.needs_constants then
				qq := origin.queries
				from
					i := qq.count
				until i = 0 loop
					df := qq.item (i)
					if df.is_constant_attribute then
						if attached s.constant_by_origin (df) as c_ then
							c := c_
						else
							create c.declare (df, s)
							s.add_constant (c)
						end
						if constants = Void then
							create constants.make_1 (c)
						else
							constants.add (c)
						end
					end
					i := i - 1
				end
			end
		end

	compute_flags (id: INTEGER): INTEGER
		do
			Result := Precursor (id)
			if origin.is_agent_type then
				Result := Result | Agent_expression_flag
			elseif base_class.has_name (once "TYPE") then
				Result := Result | Meta_type_flag
			end
			if base_class.is_actionable then
				Result := Result | Actionable_flag
			end
		end
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
