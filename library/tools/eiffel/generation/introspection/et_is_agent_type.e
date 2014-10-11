note

	description: "Compile time description of types in an Eiffel system."

class ET_IS_AGENT_TYPE

inherit

	ET_IS_TYPE
			-- Closed operands and the `last_result' constitute 
			-- the `attributes', now called `fields'. 
		rename
			declare as declare_type
		undefine
			is_subobject,
			is_basic,
			is_separate,
			is_reference,
			is_none,
			is_boolean,
			is_character,
			is_integer,
			is_real,
			is_double,
			is_pointer,
			is_int8,
			is_int16,
			is_int32,
			is_int64,
			is_string,
			is_unicode,
			generic_count,
			hash_code,
			class_name,
			append_name,
			print_name
		redefine
			declare_from_pattern,
			define,
			declare_fields,
			base_class
		end

	IS_AGENT_TYPE
		undefine
			generic_at,
			effector_at,
			field_at,
			constant_at,
			routine_at,
			set_fields,
			is_equal
		redefine
			base,
			declared_type,
			base_class,
			routine,
			in_routine,
			closed_operands_tuple
		end

create 

	declare, declare_from_pattern

feature {} -- Initialization 

	declare (o: like orig_agent; dt: ET_DYNAMIC_TYPE;
					 w: like where; t: like in_type; i: INTEGER;
					 id: INTEGER; s: ET_IS_SYSTEM)
		do
			orig_agent := o
			s.origin_table.force (Current, o)
			ident := id
			flags := Agent_flag | Reference_flag
			s.set_type (Current)			
			s.force_type (dt)
			if attached {like declared_type} s.last_type as d then
				declared_type := d
				d.add_flag (Agent_expression_flag)
			end
			origin := declared_type.origin
			check attached declared_type end
			base_class := declared_type.base_class
			base := declared_type.generic_at (0)
			open_closed_pattern := ocp
			open_operand_count := open_closed_pattern.occurrences (open_operand_indicator)
			closed_operand_count := open_closed_pattern.occurrences (closed_operand_indicator)
			if attached {ET_DYNAMIC_TYPE} o.closed_operands_tuple as ocot then
				s.force_type (ocot)
				if attached {like closed_operands_tuple} s.last_type as cot then
					closed_operands_tuple := cot
				end
			end
			where := w
			s.force_class (w.target_type.base_class)
			home := s.last_class
			in_type := t
			name_id := i
			declare_routine (s)
			routine_name := routine.fast_name
			if s.needs_attributes then
				declare_fields (s)
			end
			if s.needs_routines then
				declare_routines (s)
			end
			fast_name := out
		ensure
			origin_set: orig_agent = o
			declared_type_set: declared_type = d
			where_set: where = w
		end

	declare_from_pattern (o: like origin; p: like Current; s: ET_IS_SYSTEM)
		do
			Precursor (o, p, s)
			flags := Agent_flag | Reference_flag
			s.force_type_from_pattern (base)
			base := s.last_type
			s.force_type_from_pattern (declared_type)
			if attached {like declared_type} s.last_type as last then
				declared_type := last
			end
			s.force_type_from_pattern (closed_operands_tuple)
			if attached {like closed_operands_tuple} s.last_type as last then
				closed_operands_tuple := last
			end
			if s.needs_attributes then
				declare_fields (s)
			end
			if s.needs_routines then
				declare_routines (s)
			end
		end
	
feature -- Initialization 

	define (s: ET_IS_SYSTEM)
		local
			str: READABLE_STRING_8
			f: like field_at
			k: INTEGER
		do
			if not defined then
				Precursor (s)
				base.define (s)
				declared_type.define (s)
				closed_operands_tuple.define (s)
				routine.define (s)
				str := name
			end
		end

feature -- Access 

	orig_agent: ET_AGENT

	base_class: ET_IS_CLASS_TEXT

	base: ET_IS_TYPE
	
	declared_type: ET_IS_NORMAL_TYPE

	closed_operands_tuple: ET_IS_TUPLE_TYPE

	routine: detachable ET_IS_ROUTINE

	in_routine: detachable ET_IS_ROUTINE

	home: ET_IS_CLASS_TEXT
	
	where: ET_DYNAMIC_FEATURE

	in_type: ET_DYNAMIC_TYPE
	
	name_id: INTEGER

feature -- Status setting 

	set_ident (id: like ident)
		require
			when_set: ident > 0 implies id = ident
		do
			ident := id
		ensure
			ident_set: ident = id
		end

feature -- Basic operation 

	print_name (f: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
			declared_type.print_name (f, g)
		end

	print_create (f: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
			g.print_agent_creation_name (name_id, where, in_type, f)
		end

	print_function (f: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
			g.print_agent_function_name (name_id, where, in_type, f)
		end

	print_open_operand_name (i: INTEGER; f: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		require
			valid_index: 0 <= i and then i < open_operand_count
		do
			if attached {ET_IDENTIFIER} g.agent_open_operands.item (i + 1) as id then
				f.put_string (id.name)
			else
				f.put_character ('a')
				f.put_integer (i + 1)
			end
		end

feature {} -- Implementation 

	current_id (s: ET_IS_SYSTEM): ET_IDENTIFIER
		once
			create Result.make (s.internal_name ("Current"))
		end

	ocp: STRING
		local
			op: ET_OPERAND
			j, n: INTEGER
		do
			if attached orig_agent.arguments as list then
				from
					n := list.count
					create Result.make (n + 2)
				until j > n loop
					if j = 0 then
						op := orig_agent.target
					else
						op := list.actual_argument (j)
					end
					if op.is_open_operand then
						Result.extend ({IS_AGENT_TYPE}.open_operand_indicator)
					else
						Result.extend ({IS_AGENT_TYPE}.closed_operand_indicator)
					end
					j := j + 1
				end
			else
				create Result.make (2)
				if orig_agent.target.is_open_operand then
					Result.extend ({IS_AGENT_TYPE}.open_operand_indicator)
				else
					Result.extend ({IS_AGENT_TYPE}.closed_operand_indicator)
				end
			end
		end

	declare_routine (s: ET_IS_SYSTEM)
		local
			f: ET_DYNAMIC_FEATURE
		do
			if is_alive then
				if attached {ET_CALL_AGENT} orig_agent as c then
					if orig_agent.is_procedure then
						f := base.origin.seeded_dynamic_procedure (c.name.seed, s.origin)
					else
						f := base.origin.seeded_dynamic_query (c.name.seed, s.origin)
					end
					base.force_routine (f, False, s)
					routine := base.last_routine
				elseif attached {ET_INLINE_AGENT} orig_agent as inline then
					base.force_routine (where, False, s)
					in_routine := base.last_routine
					create routine.declare_anonymous (Current, in_routine, s)
					base.force_anonymous_routine (routine)
				end
				routine.build_arguments (s)
			end
		end
	
	declare_fields (s: ET_IS_SYSTEM)
		local
			buffer: like field_buffer
			ca: attached like field_at
			i, k, n: INTEGER
		do
			buffer := field_buffer
			if attached orig_agent.implicit_result
				and then attached declared_type.field_by_name (last_result_name) as res
			 then
				create ca.declare (res.origin, base, s)
				if attached routine.result_field as rf then
					ca.set_text (rf.text)
				end
				buffer.push (ca)
				n := 1
			end
			if attached closed_operands_tuple as cot then
				from
					i := cot.field_count
					check i = closed_operand_count end
					k := routine.argument_count
					check k = open_operand_count + closed_operand_count end
				until i = 0 loop
					i := i - 1
					from
						ca := Void
					until k = 0 or else attached ca loop
						k := k - 1
						if is_closed_operand (k) then
							ca := cot.fields [i].twin
							if attached routine.arg_at (k) as arg then
								ca.set_name (arg.fast_name)
								ca.set_text (arg.text)
							else
								ca.set_name (arg_name (k, s))
							end
							buffer.push (ca)
							n := n + 1
						end
					end
				end
			end
			from
			until n = 0 loop
				n := n - 1
				ca := buffer.top
				if not attached fields then
					create fields.make (n, ca)
				end
				fields.add (ca)
				buffer.pop (1)
			end
		end

feature {} -- Implementation 

	tmp_str: STRING = "................................................"

	op_name: STRING = "op_"

	last_result_name: STRING = "last_result"
	
	arg_names: ARRAY [READABLE_STRING_8]
		once
			create Result.make (0, 9)
		ensure
			zero_based: Result.lower = 0
		end

	arg_name (i: INTEGER; s: ET_IS_SYSTEM): READABLE_STRING_8
		require
			not_negative: i >= 0
		local
			args: like arg_names
		do
			args := arg_names
			if i <= args.upper then
				Result := args [i]
			end
			if attached Result then
			else
				tmp_str.copy (op_name)
				tmp_str.append_integer (i)
				Result := s.internal_name (tmp_str)
				args.force (Result, i)
			end
		end

invariant

	when_alive: alive implies attached routine 
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
