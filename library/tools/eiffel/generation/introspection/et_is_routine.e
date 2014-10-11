note

	description:

		"Compile time description of attributes of a type or of arguments."

class ET_IS_ROUTINE

inherit

	IS_ROUTINE
		redefine
			inline_agent,
			type,
			target,
			var_at,
			inline_routine_at,
			text
		end

	ET_IS_ORIGIN [detachable ET_DYNAMIC_FEATURE, IS_ROUTINE]
	
create

	declare

create {ET_IS_AGENT_TYPE}

	declare_anonymous

feature {} -- Initialization 

	declare (o: attached like origin; where: like target; s: ET_IS_SYSTEM)
		note
			action: "Create `Current' according to `o'."
			where: "enclosing type"
			as_create: "make `Current' a creation routine"
		local
			static: ET_FEATURE
			target_class: ET_IS_CLASS_TEXT
			nm: STRING
			i, l, u: INTEGER
		do
			make_origin (o)
			static := o.static_feature
			fast_name := s.internal_name (static.lower_name)
			flags := compute_flags (o.is_creation, s)
			target := where
			if o.is_query then
				s.force_type(o.result_type_set.static_type)
				type := s.last_type
			end
			s.force_class (static.implementation_class)
			in_class := s.last_class
			if attached static.alias_name as anm then
				nm := anm.alias_string.value
				l := nm.index_of ('"', 1)
				if l > 0 then
					-- remove leading alias tag
					l := l + 1
					u := nm.index_of ('"', l) - 1
					nm := nm.substring (l, u)
				end
				alias_name := s.internal_name (nm)
			end
			declare_locals (False, s)
			if attached origin.first_precursor as ofp then
				declare_precursor (ofp, s)
 				if attached origin.other_precursors as oop then
					from
						i := oop.count
					until i = 0 loop
						declare_precursor (oop.item (i), s)
						i := i - 1
					end
				end
			end
			if s.needs_feature_texts then
				s.force_class (o.target_type.base_class)
				target_class := s.last_class
				target_class.force_feature (origin.static_feature, s)
				if attached {like text} target_class.last_feature as x then
					x.make_locals (Current, s)
					text := x
				end
			end
		ensure
			origin_set: origin = o
		end

	declare_anonymous (a: ET_IS_AGENT_TYPE; w: ET_IS_ROUTINE; s: ET_IS_SYSTEM)
		note
			action:
			"[
			 Create `Current' fictitious routine of an inline agent
			 declared in routine `w'.
			 ]"
			a: "origin"
			w: "associated routine"
		local
			static: ET_FEATURE
			nm: STRING
		do
			inline_agent := a
			static := a.where.static_feature
			create nm.make (static.lower_name.count + 3)
			nm.extend ('_')
			nm.append_integer (w.inline_routine_count)
			nm.append (static.lower_name)
			fast_name := s.internal_name (nm)
			flags := Anonymous_routine_flag
			target := w.target
			in_class := w.in_class
			declare_locals (False, s)
			if type /= Void then
					flags := flags | Function_flag
			end
			if s.needs_feature_texts and then
				attached {ET_INTERNAL_ROUTINE_INLINE_AGENT} inline_agent.orig_agent as ia
			 then
				create text.declare_from_agent (ia, Current, in_class, s)
				in_class.add_text (text)
			end
			w.add_inline (Current)
		ensure
			inline_agent_set: inline_agent = a
			target_set: target = r.target
		end

feature -- Initialization 

	define (s: ET_IS_SYSTEM)
		note
			action: "Complete construction of `Current'."
		local
			set: detachable ET_DYNAMIC_TYPE_SET
			i: INTEGER
		do
			if not defined then
				defined := True
				if attached type as t then
					t.define (s)
				end
				target.define (s)
				in_class.define (s)
				from
					i := variable_count
				until i = 0 loop
					i := i - 1
					if attached var_at (i) as l then
						l.define (s)
						if attached l.text as lt then
							lt.define (s)
						end
					end
				end
			end
			if s.needs_typeset and then attached origin as o then
				from
					i := variable_count
				until i = 0 loop
					i := i - 1
					if attached vars [i] as var then
						if attached {ET_OPERAND} var.origin as lo then
							set := o.dynamic_type_set (lo)
							var.set_type_set (s.type_set (var.type, set, var.is_attached))
						end
					end
				end
				if attached result_field as var then
					set := o.result_type_set
					type_set := s.type_set (var.type, set, var.is_attached)
					var.set_type_set (type_set)
				end
				if attached text as x then
					x.define (s)
				end
			end
		end

feature -- Access 

	type: detachable ET_IS_TYPE

	target: ET_IS_TYPE

	in_class: ET_IS_CLASS_TEXT
	
	text: detachable ET_IS_ROUTINE_TEXT

	inline_agent: detachable ET_IS_AGENT_TYPE

	var_at (i: INTEGER): detachable ET_IS_LOCAL
		do
			Result := vars [i]
		end

	inline_routine_at (i: INTEGER): ET_IS_ROUTINE
		do
			Result := inline_routines [i]
		end

feature -- Status setting 

	add_inline (r: ET_IS_ROUTINE)
		do
			if attached inline_routines then
			else
				create inline_routines
			end
			inline_routines.add (r)
			if attached text as t and then attached r.text as rt then
				t.add_inline (rt)
			end
		end

	set_wrap (n: INTEGER)
		do
			wrap := n
		ensure
			wrap_set: wrap = n
		end

	build_arguments (s: ET_IS_SYSTEM)
		do
			if argument_count = 0 then
				declare_locals (True, s)
			end
		end
	
feature -- ET_IS_ORIGIN 

	print_name (file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		local
			done: BOOLEAN
		do
			if attached origin as o then
				if is_precursor or else is_inlined or else not o.is_generated then
				elseif o.is_regular then
					g.print_routine_name (o, target.origin, file)
					done := True
				elseif o.is_static then
					g.print_static_routine_name (o, target.origin, file)
					done := True
				elseif o.is_creation then
					g.print_creation_procedure_name (o, target.origin, file)
					done := True
				end
			elseif is_anonymous then
				check inline_agent end
				inline_agent.print_function (file, g)
				done := True
			end
			if not done then
				file.put_character ('0')
			end
		end

feature {} -- Implementation 

	var_buffer: IS_STACK [ET_IS_LOCAL]
		once
			create Result
		end

	declare_locals (always_args: BOOLEAN; s: ET_IS_SYSTEM)
		note
			action: "Create all arguments and local variables."
		local
			closure: ET_CLOSURE
			df: ET_DYNAMIC_FEATURE
			frm: ET_FORMAL_ARGUMENT
			lcl: ET_LOCAL_VARIABLE
			pf, pl: ET_POSITION
			dynamic: detachable ET_DYNAMIC_TYPE
			static_type: ET_TYPE
			res: detachable ET_AST_NODE
			ac: ET_ACROSS_COMPONENT
			id: ET_IDENTIFIER
			pos: ET_POSITION
			ct: detachable ET_IS_SCOPE_VARIABLE
			vt: detachable ET_IS_FEATURE_TEXT
			rt: detachable ET_IS_ROUTINE_TEXT
			var: like var_at
			buffer: like var_buffer
			nm: STRING
			i, k, n0, n, na, e_pos: INTEGER
			once_only: BOOLEAN
		do
			once_only := not s.needs_locals and s.needs_once_values 
			buffer := var_buffer
			n0 := buffer.count
			if attached origin as o then
				df := o
				closure := o.static_feature.implementation_feature
			elseif attached {ET_INLINE_AGENT} inline_agent.orig_agent as ia then
				df := inline_agent.where
				closure := ia
			end
			if s.needs_locals or else always_args then
				-- Build `Current' and arguments.
				nm := s.internal_name (current_name)
				check closure /= Void end
				if uses_current then
					if attached origin as o then
						dynamic := o.target_type
						pos := o.static_feature.position
					else
						dynamic := inline_agent.base.origin
						pos := inline_agent.orig_agent.agent_keyword.position
					end
					if s.needs_feature_texts then
						create vt.declare_simple (current_name, dynamic.base_type,
																			pos, in_class, False, s)
					else
						vt := Void
					end
					create var.declare (Void, nm, dynamic, Current, vt, s)
				else
					-- skip over current item
					var := Void
				end
				buffer.push (var)
				if attached closure.arguments as fs then
					na := fs.count
					from
						i := 0
					until i = na loop
						i := i + 1
						frm := fs.formal_argument (i)
						id := frm.name.identifier
						dynamic := df.dynamic_type_set (id).static_type
						if s.needs_feature_texts then
							create vt.declare_from_declaration
								(frm, id.lower_name, frm.declared_type, in_class, s)
						else
							vt := Void
						end
						create var.declare (id, Void, dynamic, Current, vt, s)
						buffer.push (var)
					end
				end
				argument_count := na + 1
			elseif once_only then
				-- skip over current item
				buffer.push (Void)
			end
			if s.needs_locals or else once_only or else always_args then
				-- Build `Result'.
				nm := s.internal_name (result_name)
				var := Void
				if attached origin as o then
					if attached o.result_type_set as ds then
						res := o.static_feature
						dynamic := ds.static_type
					end
				elseif attached {ET_RESULT} 
					inline_agent.orig_agent.implicit_result as op
				 then
					res := op
					dynamic := df.dynamic_type_set (op).static_type
				else
					-- skip over result item 
					res := Void
				end
				if attached res then
					if s.needs_feature_texts then
						create vt.declare_from_declaration
							(res, nm, dynamic.base_type, in_class, s)
					else
						vt := Void
					end
					create var.declare (res, nm, dynamic, Current, vt, s)
					type := var.type
				end
				buffer.push (var)
				local_count := 1
			end
			if s.needs_locals then
				-- Build local variables, scope variables, and (in future) old values.
				if attached closure.locals as ls then
					from
						n := ls.count
						i := 0
					until i = n loop
						i := i + 1
						dynamic := Void
						lcl := ls.local_variable (i)
						if lcl.is_used then
							id := lcl.name.identifier
							if attached df.dynamic_type_set (id) as dyn then
								dynamic := dyn.static_type
							end
						end
						if dynamic /= Void then
							if s.needs_feature_texts then
								create vt.declare_from_declaration
									(lcl, id.lower_name, lcl.declared_type, in_class, s)
							else
								vt := Void
							end
							create var.declare (lcl.name, Void, dynamic, Current, vt, s)
							buffer.push (var)
							local_count := local_count + 1
						end
					end
				end
				-- Prepare check for scope variables in postcondition:
				if attached closure.postconditions as pc then
					e_pos := pc.position.line
				else
					e_pos := 0
				end
				if attached closure.object_tests as ots then
					from
						n := ots.count
						i := 0
					until i = n loop
						i := i + 1
						if attached {ET_NAMED_OBJECT_TEST} ots.item (i) as ot then
							id := ot.name
							if (e_pos = 0 or else id.position.line < e_pos)
								and then attached ot.first_scope_position
								and then attached df.dynamic_type_set (id) as ds
							 then 
								dynamic := ds.static_type
								if s.needs_feature_texts then
									create vt.declare_from_declaration
										(id, id.lower_name, dynamic.base_type, in_class, s)
									vt.set_positions (ot.attached_keyword, id.last_position)
								else
									vt := Void
								end
								create ct.declare (id, dynamic, True, Current, vt, s)
								ct.set_attached
								pf := ot.first_scope_position
								ct.set_lower_scope_limit (pf.line * 256 + pf.column)
								pl := ot.last_scope_position
								ct.set_upper_scope_limit (pl.line * 256 + pl.column)
								buffer.push (ct)
								scope_var_count := scope_var_count + 1
							end
						end
					end
				end
				if attached closure.across_components as acs then
					from
						n := acs.count
						i := 0
					until i = n loop
						i := i + 1
						ac := acs.item (i)
						id := ac.cursor_name
						if (e_pos = 0 or else id.position.line < e_pos)
							and then attached df.dynamic_type_set (id) as ds
						 then
							dynamic := ds.static_type
							if attached {ET_DECLARED_TYPE} dynamic.base_type as dt then
								if s.needs_feature_texts 
								 then
									create vt.declare_from_declaration
										(id, id.lower_name, dt, in_class, s)
									vt.set_positions (ac.across_keyword, id.last_position)
								else
									vt := Void
								end
								create ct.declare(id, dynamic, False, Current, vt, s)
								if attached {ET_ACROSS_EXPRESSION} ac as ae then
									pf := ae.iteration_conditional.position
									pl := ae.end_keyword.position
								elseif attached {ET_ACROSS_INSTRUCTION} ac as ai then
									pf := ai.new_cursor_expression.last_position
									pl := ai.end_keyword.position
								end
								ct.set_attached
								ct.set_lower_scope_limit (pf.line * 256 + pf.column)
								ct.set_upper_scope_limit (pl.line * 256 + pl.column)
								buffer.push (ct)
								scope_var_count := scope_var_count + 1
							end
						end
					end
					-- no := a_feature.??	-- `old' count 
				end
			end
			n := argument_count + local_count + old_value_count
				+ scope_var_count + temp_var_count
			create vars.make (n, Void)
			from
				n := buffer.count - n0
				i := n
			until i = 0 loop
				i := i - 1
				vars.add (buffer.below_top(i))
			end
			buffer.pop (n)
			check
				buffer.count = n0
			end
		end

	declare_precursor (p: ET_DYNAMIC_PRECURSOR; s: ET_IS_SYSTEM)
		local
			t: ET_IS_TYPE
			r: ET_IS_ROUTINE
		do
			s.force_type (p.parent_type)
			t := s.last_type
			create r.declare (p, t, s)
			t.force_precursor_routine (r)
			s.origin_table.force (r, p)
		end

	compute_flags (as_create: BOOLEAN; s: ET_IS_SYSTEM): INTEGER
		local
			static: ET_FEATURE
			df: ET_DYNAMIC_FEATURE
			nm: READABLE_STRING_8
			op: BOOLEAN
		do
			if attached origin as o then
				df := o
			else
				check inline_agent /= Void end
				df := inline_agent.where
			end
			static := df.static_feature
			if static.is_once then
				Result := Result | Once_flag
			elseif static.is_deferred then
				Result := Result | Deferred_flag
			elseif attached {ET_EXTERNAL_ROUTINE} static then
				Result := Result | External_flag
			else
				Result := Result | Do_flag
			end
			if static.is_function then
				Result := Result | Function_flag
				if attached static.alias_name as anm then
					op := True
					nm := s.internal_name (anm.alias_string.value)
					if nm [1].is_alpha then
						op := STRING_.same_string(nm, once "not")
						op := op or else STRING_.same_string(nm, once "and")
						op := op or else STRING_.same_string(nm, once "and then")
						op := op or else STRING_.same_string(nm, once "or")
						op := op or else STRING_.same_string(nm, once "or else")
						op := op or else STRING_.same_string(nm, once "implies")
					end
					if op then
						Result := Result | Operator_flag
					end
				end
			end
			if attached static.alias_name as asn and then asn.is_bracket then
				Result := Result | Bracket_flag
			end
			if attached {ET_INTERNAL_ROUTINE} static as int
				and then attached int.rescue_clause
			 then
				Result := Result | Rescue_flag
			end
			if as_create then
				Result := Result | Creation_flag
				if static.has_seed (s.origin.current_system.default_create_seed) then
					Result := Result | Default_creation_flag
				end
			end
			if df.is_precursor then
				Result := Result | Precursor_flag
			end
			if df.is_static then
				Result := Result | No_current_flag
			end
--			if not df.side_effect_free then 
--				Result := Result | Side_effect_flag 
--			end 
			if df.is_inlined then
				Result := Result | Inlined_flag
			end
			if df.is_builtin then
				Result := Result | Inlined_flag
				Result := Result | External_flag
			end
		end

	current_name: STRING = "Current"
	
	result_name: STRING = "Result"

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
