note

	description: "Node of a parse expression tree for use by the debugger."

class DG_EXPRESSION

inherit

	IS_ENTITY
		rename
			as_any as pointer_to_any,
			as_pointer as any_to_pointer,
			location as offset,
			runtime_system as debuggee
		undefine
			debuggee
		redefine
			fast_name,
			copy,
			is_equal,
			out
		select
			out
		end

	DG_C_VALUE
		rename
			clear as clear_value,
			out as c_out
		undefine
			default_create
		redefine
			copy,
			is_equal
		end

create

	make,
	make_as_down,
	make_with_down,
	make_as_all,
	make_from_feature,
	make_from_type

feature {} -- Initialization 

	make (c: INTEGER)
		do
			fast_name := no_name
			arg := Void
			next := Void
			down := Void
			is_manifest := False
			entity := Void
			column := c
			default_create
		ensure then
			cleared: not attached entity
		end

	make_as_down (p: attached like parent; c: INTEGER)
		do
			make (c)
			p.bottom.set_down (Current)
		ensure
			parent_set: parent = p
		end

	make_with_down (d: like down; c: INTEGER)
		do
			make (c)
			set_down (d)
		ensure
			down_set: down = d
		end

	make_as_all (d: INTEGER; c: INTEGER)
		require
			d_not_negative: d >= 0
		do
			make (c)
			set_entity (all_entity)
			set_name (d.out)
		ensure
			depth_set: entity = all_entity and then fast_name.to_integer = d
		end

	make_from_feature (cls: IS_CLASS_TEXT; f: IS_FEATURE_TEXT; c: INTEGER)
		local
			e: like entity
			const: IS_CONSTANT [ANY]
			call: IS_ONCE_CALL
			nm: STRING
			i: INTEGER
		do
			fast_name := cls.fast_name
			entity := constant_entity
			is_manifest := True
			nm := f.fast_name from
				i := debuggee.constant_count
			until attached e or else i = 0 loop
				i := i - 1
				const := debuggee.constant_at (i)
				if const.home = cls and then const.has_name (nm) then
					e := const
				end
			end
			from
				i := debuggee.once_count
			until attached e or else i = 0 loop
				i := i - 1
				call := debuggee.once_at (i)
				if call.home = cls and then call.is_function
					and then call.has_name (nm)
				 then
					e := call
				end
			end
			if attached e then
			else
				raise_with_code (0, once "Feature is neither a once function nor a constant.")
			end
			column := c
			create down.make_as_down (Current, column)
			down.set_entity (e)
			down.set_name (nm)
		ensure
			has_down: attached down
		end

	make_from_type (t: attached like type; ex: detachable DG_EXPRESSION; c: INTEGER)
		require
			is_normal_type: t.is_normal
			has_default_creation: t.is_subobject or else attached t.default_creation
		local
			d: like down
			r: detachable IS_ROUTINE
		do
			make (c)
			set_entity (create_entity)
			fast_name := t.ident.out
			type := t
			if attached ex as e then
				set_arg (e)
			else
				r := t.default_creation
				if attached r then
					create d.make (c)
					d.set_name (r.fast_name)
					set_arg (d)
				else
					msg_at.set_item (column)
					raise_with_code (0, once "Type has no default creation procedure.")
				end
			end
		ensure
			has_down: attached down
			down_set: attached ex as e implies down = e
		end

feature -- Access 

	fast_name: STRING_8

	down: detachable DG_EXPRESSION
			-- Feature of `Current' (added by a dot). 

	bottom: attached like down
		note
			return: "Last element of a `down' chain."
		do
			from
				Result := Current
			until not attached Result.down as d loop
				Result := d
			end
		end

	arg: detachable DG_EXPRESSION
			-- First element in the argument list of `Current' 
			-- (added by parantheses). 

	arg_count: INTEGER
		note
			return: "Number of arguments adjoint to `Current',"
		local
			pt: detachable DG_EXPRESSION
		do
			from
				pt := arg
			until not attached pt loop
				Result := Result + 1
				pt := pt.next
			end
		ensure
			not_negative: Result >= 0
		end

	next: detachable DG_EXPRESSION
			-- Next element of an argument list (added by a comma). 

	last: like next
		note
			return: "Last element of a `next' chain."
		do
			from
				Result := Current
			until not attached Result as r or else not attached r.next as rn loop
				Result := rn
			end
		end

	up_frame_count: INTEGER

	parent: detachable DG_EXPRESSION
			-- Parent node in expression tree. 

	detail: detachable DG_EXPRESSION
			-- Tree of details (added by braces). 

	detail_depth: INTEGER
		note
			return: "Depth if entity is `all', -1 else."
		require
			detailed: is_detailed
		do
			if attached bottom.detail as d and then d.entity = all_entity then
				Result := d.fast_name.to_integer
			else
				Result := -1
			end
		ensure
			large_enough: -1 <= Result
		end

	entity: detachable IS_ENTITY 
			-- Associated entity after `compute'. 

	column: INTEGER
			-- Start column number in command. 

	in_object: detachable ANY
			-- Enclosing object:
			--   the IS_STACK_FRAME in case of local variables
			--   the object in case of an attribute in a reference type
			--   the closest refenence object or the IS_STACk_FRAME
			--     in case of an attribute in an expanded type
			--   `Void' in case of function results, constants, or once values
	
	address: POINTER
		note
			return:
				"[
				 Address of data: on heap if of reference type,
				 within enclosing object (or on stack) if of expanded type.
				 ]"
		require
			has_result: has_result
		do
			Result := c_ptr
			if Result /= default_pointer and then not type.is_subobject then
				Result := debuggee.dereferenced (Result, type)
			end
		end
	
	is_attached: BOOLEAN
		do
			Result := has_result and then attached ref
		end

feature -- Status 

	is_manifest: BOOLEAN
			-- Is `Current' a manifest constant? 

	is_single: BOOLEAN
		do
			Result := not is_detailed
		end

	is_operator: BOOLEAN
		do
		end

	is_infix: BOOLEAN
		require
			is_operator: is_operator
		do
		end

	is_prefix: BOOLEAN
		require
			is_operator: is_operator
		do
		end

	is_range: BOOLEAN
		do
		end

	is_detailed: BOOLEAN
		do
			Result := attached bottom.detail
		end

	has_result: BOOLEAN

	result_is_void: BOOLEAN
		local
			single: like down
		do
			from
				single := Current
				Result := True
			until not attached single as s loop
				single := s.down
			end
		end

	separator_error: BOOLEAN
			-- Has the expression an error caused by a misplaced 
			-- separator character? 

feature -- Status setting 

	set_name (nm: STRING)
		do
			fast_name := nm.twin
		ensure
			fast_name_set: fast_name.is_equal (nm)
		end

	set_down (d: like down)
		do
			down := d
			if attached d as d_ then
				d_.link (Current)
			end
		ensure
			down_set: down = d
			linked: attached down as d_ implies d_.parent = Current
		end

	set_arg (a: like arg)
		do
			arg := a
			if attached a as a_ then
				a_.link (Current)
			end
		ensure
			arg_set: arg = a
		end

	set_detail (d: like detail)
		local
			b: like bottom
		do
			b := bottom
			if Current = b then
				detail := d
				if attached d as d_ then
					d_.link (Current)
				end
			else
				b.set_detail (d)
			end
		ensure
			detail_set: bottom.detail = d
		end

	set_next (n: like next)
		do
			next := n
			if attached n as n_ then
				n_.link (Current)
			end
		ensure
			next_set: next = n
		end

	set_parent (p: like parent)
		do
			parent := p
		ensure
			parent_set: parent = p
		end

	set_entity (e: like entity)
		do
			is_manifest := attached {DG_MANIFEST} e
			entity := e
		ensure
			entity_set: entity = e
		end

	set_manifest (tid: INTEGER; nm: STRING)
		do
			is_manifest := True
			set_name (nm)
			inspect tid
			when Character_ident then
				entity := character_entity
				if fast_name.count > 2 then
						-- remove enclosing apostrophes 
					fast_name.remove (1)
					fast_name.remove (fast_name.count)
				end
			when Integer_ident then
				entity := integer_entity
			when Real64_ident then
				entity := double_entity
			when String8_ident then
				entity := string_entity
			else
			end
		end

	set_up_frame_count (n: INTEGER)
		do
			up_frame_count := n
		ensure
			up_frame_count_set: up_frame_count = n
		end

	invalidate
		do
			if not is_manifest then
				entity := Void
			end
			clear_value
		end

	set_separator_error
		do
			separator_error := True
		end

feature -- Basic operation 

	compute (ds: IS_STACK_FRAME; values: DG_VALUE_STACK)
		note
			action:
				"[
				 Compute value of an expression and put the value's
				 address in top of the cleared `values'.
				 ]"
		do
			compute_one (ds, values)
		ensure
			on_stack: values.count = old values.count + 1
		end

	assign_from (src: DG_EXPRESSION; ds: IS_STACK_FRAME; values: DG_VALUE_STACK)
		note
			action: "Assign value of `src' to field of own result."
		require
			computed: has_result
			src_computed: src.has_result
		local
			lhs, rhs: DG_EXPRESSION
			ts: detachable IS_SEQUENCE [IS_TYPE]
			saved: like Current
			inv: BOOLEAN
		do
			lhs := bottom
			rhs := src.bottom
			if not attached in_object then
				raise_with_code (0, "Target is not assignable.")
			end
			if attached lhs.type as lt and then attached rhs.type as rt then
				if attached lhs.entity as le and then attached le.type_set as lts
					and then lts.count > 0
				 then
					ts := lts
				elseif lhs.entity = bracket_entity
					and then attached lhs.parent as lp and then attached lp.type as pt 
					and then pt.is_special
					and then attached {IS_SPECIAL_TYPE} lp.type as s
					and then attached s.item_0 as i0
					and then attached i0.type_set as lts
					and then lts.count > 0
				 then
					ts := lts
				else
					lhs.raise_with_code (0, Not_assignable)
				end
				if lt.is_basic then
					if not rhs.is_assignable_to (lt) then
						rhs.raise_with_code (0, Not_conforming_types)
					end
				elseif lt.is_subobject then
					if lt /= rt then
						rhs.raise_with_code (0, Not_conforming_types)
					end
				elseif not attached ts as lts or else not lts.has (rt) then
					rhs.raise_with_code (0, Not_conforming_types)
				end
				if attached lhs.parent then
					inv := debuggee.check_invariant (lhs.address, lt)
				end
				if inv then
					saved := twin
				else
					saved := Current
				end
				lhs.copy_value (rhs)
				if inv then
					if not debuggee.check_invariant (lhs.address, lt) then
						check attached saved end
						copy (saved)
						raise_with_code (0, once "Assignment not performed since the class invariant would be violated.")
					end
				else
				end
			end
		end

	set_best_entity (ds: detachable IS_STACK_FRAME; t: detachable IS_TYPE;
									 left, dyn: BOOLEAN)
		note
			action: "Set `entity' best matching to `fast_name'."
		require
			when_left: left implies attached ds
			when_not_attached_ds: not attached ds implies attached t
		local
			td: IS_TYPE
			rd: IS_ROUTINE
			e: IS_ENTITY 
			c: IS_CONSTANT [ANY]
			nm: STRING
			ln, cn: INTEGER
			i, n: INTEGER
			as_create: BOOLEAN
		do
			entities.clear
			if left then
				td := ds.target_type
				rd := ds.routine
				entities.add (void_entity)
				entities.add (true_entity)
				entities.add (false_entity)
				from
					n := rd.argument_count + rd.local_count + rd.old_value_count
					i := 0
				until i = n loop
					if attached rd.var_at (i) as vi then
						entities.add (vi)
					end
					i := i + 1
				end
				from
					n := n + rd.scope_var_count
					ln := ds.line
					cn := ds.column
				until i = n loop
					if attached {IS_SCOPE_VARIABLE} rd.var_at (i) as ot and then ot.in_scope (ln, cn) then
						entities.add (ot)
					end
					i := i + 1
				end
				if attached ds.target_type as dt then
					if dt.is_subobject then
						td := dt
					elseif dyn and then attached pointer_to_any (ds.target) as a then
						if attached debuggee.type_of_any (a, dt) as t_ then
							td := t_
						end
					end
				end
			else
				td := t
			end
			from
				i := debuggee.constant_count
				nm := td.name
			until i = 0 loop
				i := i - 1
				c :=  debuggee.constant_at (i)
				if c.home.has_name(nm) then
					entities.add (c)
				end
			end
			from
				i := td.field_count
			until i = 0 loop
				i := i - 1
				e := td.field_at (i)
				entities.add (e)
			end
			if attached parent as p then
				as_create := p.entity = create_entity
				if as_create and then attached p.type as pt_ then
					td := pt_
				end
			end
			from
				i := td.routine_count
			until i = 0 loop
				i := i - 1
				rd := td.routine_at (i)
				if (as_create and then rd.is_creation)
					or else (not as_create and then rd.is_function)
				 then
					entities.add (rd)
				end
			end
			set_matching_entity (fast_name, td)
			type := entity.type
		ensure
			when_found: attached entity implies type = entity.type
		end

	correct
		note
			action:
				"[
				 Remove all parts that were not computed during
				 the last call to `compute' because of an error.
				 That is, only the successfully
				 computable initial part remains.
				 ]"
		local
			ok: BOOLEAN
		do
			ok := attached entity
			if attached arg as a then
				if ok then
					a.correct
					ok := attached a.entity
				end
				if not ok then
					arg := Void
					entity := Void
					type := Void
				end
			end
			if attached down as d then
				if ok then
					d.correct
					ok := attached d.entity
				end
				if not ok then
					d.unlink
					down := Void
				end
			end
			if attached detail as d then
				if d.entity = details_entity then
					detail := d.detail
				end
				if attached detail as d_ then
					d_.correct
					if attached d_.entity then
					else
						detail := Void
					end
				end
			end
			if attached next as n then
				n.correct
				if attached n.entity then
				else
					next := n.next
				end
			end
		end

	correct_for_type (t: IS_TYPE)
		local
			ex, good: detachable DG_EXPRESSION
		do
			correct
			from
				ex := Current
			until not attached ex loop
				if attached ex.entity as e and then attached e.type as et then
					if et.conforms_to_type (t) then
						good := ex
					end
					ex := ex.down
				else
					ex := Void
				end
			end
			if attached good as g then
				g.set_down (Void)
			else
				entity := Void
				type := Void
				down := Void
			end
		end

feature -- Comparison & duplication 

	copy (other: like Current)
		do
			standard_copy (other)
			fast_name := fast_name.twin
			if attached next as n then
				next := n.twin
				next.share_parent (other, Current)
			end
			if attached down as d then
				down := d.twin
				down.share_parent (other, Current)
			end
			if attached arg as a then
				arg := a.twin
				arg.share_parent (other, Current)
			end
			if attached other.detail as d then
				detail := d.twin
				detail.share_parent (other, Current)
			end
			if not is_manifest then
				entity := Void
				type := Void
				clear_value
			end
		end

	is_equal (other: like Current): BOOLEAN
		do
			Result := standard_is_equal (other)
			if not Result then
				Result := (attached next as d and then attached other.next as od
									 and then d.is_equal (od))
					or else next = Void and other.next = Void
				if Result then
					Result := (attached down as d and then attached other.down as od
										 and then d.is_equal (od))
						or else down = Void and other.down = Void
				end
				if Result then
					Result := (attached arg as d and then attached other.arg as od
										 and then d.is_equal (od))
						or else arg = Void and other.arg = Void
				end
				if Result then
					Result := fast_name.is_equal (other.fast_name)
				end
			end
			if not Result then
				Result := fast_name.is_equal (other.fast_name)
			end
		end

feature -- Removal 

	remove_next
		do
			if attached next as n then
				next := n.next
			end
		end

	cut_last
		require
			has_down: attached down
		local
			pt0, pt1: like down
		do
			from
				pt0 := Current
				pt1 := pt0.down
			until not attached pt1 loop
				if attached pt1.down then
				else
					pt0.set_down (Void)
				end
				pt0 := pt1
				pt1 := pt1.down
			end
		end

	refresh
		do
			if not is_manifest then
				entity := Void
				type := Void
			end
			if attached next as n then
				n.refresh
			end
			if attached down as d then
				d.refresh
			end
			if attached arg as a then
				a.refresh
			end
		ensure
			no_entity: is_manifest xor not attached entity
		end

feature -- Output 

	out: STRING
		do
			create Result.make (20)
			append_out (Result)
		end

	append_out (s: STRING)
		note
			action: "Append the result of `out' to `s' ignoring the `detail' branch."
			s: "STRING to be extended"
		local
			n: like next
		do
			append_single (s)
			from
				n := next
			until not attached n loop
				s.extend (',')
				s.extend (' ')
				n.append_single (s)
				n := n.next
			end
		end

	append_detailed (s: STRING)
		note
			action: "Like `append_out' but not ignoring the `detail' branch."
			s: "STRING to be extended"
		local
			n: like next
		do
			if entity /= details_entity then
				append_single (s)
			end
			if attached bottom.detail as d then
				s.extend (' ')
				s.extend ('{')
				s.extend ('{')
				s.extend (' ')
				d.append_detailed (s)
				s.extend (' ')
				if d.entity = all_entity then
					s.append (d.fast_name)
					s.extend (' ')
				end
				s.extend ('}')
				s.extend ('}')
			end
			from
				n := next
			until not attached n loop
				s.extend (',')
				s.extend (' ')
				n.append_detailed (s)
				n := n.next
			end
		end

	append_single (s: STRING)
		note
			action:
				"[
				 Append the printable format of the leading
				 SINGLE_EXPRESSION to `s'.
				 ]"
			s: "STRING to be extended"
		local
			ok: BOOLEAN
		do
			ok := append_checked_out (s, False, Void)
		end

	append_out_until_bad (s: STRING)
		local
			ok: BOOLEAN
		do
			ok := append_checked_out (s, True, Void)
		end

feature {DG_EXPRESSION} -- Computation 

	compute_one (shown_ds: IS_STACK_FRAME; values: DG_VALUE_STACK)
		note
			action: "Compute value of an expression and put it onto the top of `values'."
		local
			ds: IS_STACK_FRAME
			t: IS_TYPE
			r: IS_ROUTINE
			pt: detachable DG_EXPRESSION
			pt0: DG_EXPRESSION
			a: detachable ANY
			i: INTEGER
			ready: BOOLEAN
		do
			has_result := False
			ds := shown_ds
			values.push (Current)
			if up_frame_count > 0 then
				from
					i := up_frame_count
				until i = 0 loop
					if attached ds.caller as c then
						ds := c
					else
						up_frame_count := -1
						raise_with_code (0, once "To many stack frames up.")
					end
					i := i - 1
				end
			end
			if is_manifest and then attached entity as e then
				in_object := Void
				ready := True
				if e = current_entity then
					type := ds.target_type
					in_object := ds
					offset := ds.var_at (0).offset
				elseif e = character_entity then
					type := e.type
					put_character (fast_name [1])
				elseif e = integer_entity then
					type := e.type
					put_integer_64 (fast_name.to_integer_64)
				elseif e = double_entity then
					type := e.type
					put_double (fast_name.to_double)
				elseif e = string_entity then
					type := e.type
					put_any (fast_name)
				elseif e = bracket_entity then
				elseif e = create_entity then
					compute_creation (ds, values)
				elseif e = equality_entity then
					type := e.type
				elseif e = all_entity then
					type := debuggee.integer_type
				elseif e = constant_entity then
					type := e.type
				elseif e = alias_entity then
				elseif e = closure_entity then
					a := closure_table.key_of_value (fast_name.to_natural)
					if attached a then
					else
						tmp_str.copy (once "Unknown closure ident _")
						tmp_str.append (fast_name)
						tmp_str.extend ('.')
						raise_with_code (Unknown_closure_ident, tmp_str)
					end
					type := debuggee.type_of_any (a, Void)
					put_any (a)
				elseif e = placeholder_entity then
					if attached parent as p then
						pt0 := p
						if pt0.entity = details_entity and then attached pt0.parent as pp then
							pt0 := pp
						end
						if fast_name [1] = '?' then
							type := pt0.type
							in_object := pt0.in_object
							offset := pt0.offset
							c_ptr := pt0.c_ptr
						elseif attached {DG_RANGE_EXPRESSION} pt0 as range then
							put_natural_32 (range.at_index)
						end
					end
				elseif e = old_entity then
					r := ds.routine
					tmp_str.wipe_out
					e.append_name (tmp_str)
					i := tmp_str.to_integer - 1
					if not r.valid_old (i) then
						tmp_str.copy (once "Not so many old values in `")
						r.append_name (tmp_str)
						tmp_str.extend ('%'')
						tmp_str.extend ('.')
						raise_with_code (Not_an_old, tmp_str)
					end
					if attached r.old_at (i) as l then
						in_object := ds
						offset := l.offset
					end
				end
			else
				type := ds.target_type
				in_object := ds
				offset := ds.var_at (0).offset
			end
			adjust_address
			if not ready then
				compute_qualified (ds, values, True)
			end
			has_result := True
			if attached entity as e then
				from
					pt0 := Current
					pt := down
				until not attached pt or else not attached pt0.type as t0 loop
					pt0.fix_value
					t := t0
					if pt.entity = equality_entity then
						pt.compute_equality (shown_ds, values)
					elseif pt0.entity = constant_entity then
						if attached {IS_ONCE_CALL} pt.entity as o2 then
							if not o2.is_initialized then
								raise_with_code (Not_initialized, Once_not_initialized)
							end
							if attached o2.value as ov then
								pt.set_entity (ov)
								c_ptr := ov.address
							end
						else
							pt.compute_constant (values)
						end
					elseif pt0.c_ptr = default_pointer then
						pt0.raise_with_code (Void_call_target, once "Void target.")
					elseif pt.entity = bracket_entity then
						if t.is_special then
							pt.compute_item (shown_ds, values)
						elseif attached t0.bracket as bkt then
							pt.compute_function (bkt, pt0, shown_ds, values)
						else
							tmp_str.copy (once "Type ")
							t.append_name (tmp_str)
							tmp_str.append (once " does not have a bracket function.")
							pt0.raise_with_code (No_bracket, tmp_str)
						end
					else
						pt.compute_qualified (shown_ds, values, False)
					end
						pt0 := pt
						pt := pt.down
				end
			end
		ensure
			entity_not_void: attached entity
			values_count: values.count = old values.count + 1
		end

	compute_qualified (ds: IS_STACK_FRAME; values: DG_VALUE_STACK; left: BOOLEAN)
		note
			action:
				"[
				 Compute one qualified part of an expression.
				 If `is_left' then start analysis at `mult.stack'.
				 If `not is_left' then there is a left neighbour,
				 its type and value of the qualifier expression
				 are taken from the top of `values' which then gets replaced
				 by the result of this computation.
				 ]"
		require
			is_values_top: values.count > 0 and then values.top = Current
			when_parent: attached parent as p implies attached p.entity
		local
			t: IS_TYPE
			at: IS_AGENT_TYPE
			rc: IS_ROUTINE
			e: like entity
			cot: detachable ANY
			i, n: INTEGER
			ok: BOOLEAN
		do
			t := void_entity.type
			rc := ds.routine
			values.put (Current)
			if attached parent as p and then attached p.type as t_ then
				type := t_
			else
				type := Void
			end
			set_best_entity (ds, type, left, True)
			if attached entity as e_ then
				type := e_.type
				if e_ = void_entity then
					fix_value
					in_object := Void
					c_ptr := default_pointer
				elseif entity = true_entity then
					fix_value
					in_object := Void
					put_boolean (True)
				elseif e_ = false_entity then
					fix_value
					in_object := Void
					put_boolean (False)
				elseif attached {IS_LOCAL} e_ as l2 then
					-- arguments and local variables 
					in_object := ds
					offset := l2.offset
					if attached arg as a then
						a.raise_with_code (Not_a_function, Not_function)
					end
					if attached rc.inline_agent as ia then
						from
							at := ia
							i := rc.argument_count
						until not attached at or else i = 0 loop
							i := i - 1
							if l2 = rc.arg_at (i) then
								if at.is_closed_operand (i)
									and then attached at.closed_operands_tuple as ut
									and then attached as_any as aref 
								 then
									cot := debuggee.closed_operands (aref, at)
									from
										n := 0
									until i = 0 loop
										i := i - 1
										if at.is_closed_operand (i) then
											n := n + 1
										end
									end
									in_object := aref	-- ???
									offset := ut.field_at (n).offset
								else
									offset := l2.offset
								end
							end
						end
					else
						offset := l2.offset
					end
				elseif attached {IS_CONSTANT [ANY]} e_ as c then
					-- constants 
					compute_constant (values)
				elseif attached {IS_FIELD} e_ as f then
					-- fields and closed args 
					if attached arg then
						raise_with_code (Not_a_function, Not_function)
					end
					if left then
						if ds.target_type.is_subobject then
							in_object := ds
							offset := ds.var_at (0).offset
						else
							in_object := pointer_to_any (ds.target)
							offset := 0
						end
					elseif attached parent as p then
						if p.type.is_subobject then
							in_object := p.in_object
							offset := p.offset 
							c_ptr := p.c_ptr
						else
							in_object := p.as_any
							offset := 0
						end
						if p.type.is_agent then
							if attached {IS_AGENT_TYPE} t as ag and then f /= ag.last_result
							 then
								adjust_address
								if attached pointer_to_any (address) as a then
									cot := debuggee.closed_operands (a, ag)
									in_object := cot
									offset := 0
								end
							end
						end
					end
					offset := offset + f.offset
				else
					-- functions 
					if attached {IS_ROUTINE} e_ as r then
						if r.is_once and then attached r.once_call as o then
							if not o.is_initialized then
								raise_with_code (Not_initialized, Once_not_initialized)
							end
							if attached o.value as ov then
								entity := ov
								c_ptr := ov.address
							end
						else
							if attached r.target as l and then r = l.type.invariant_function then
								check
									arg_count = 0
								end
								ok := debuggee.check_invariant (address, l.type)
								if ok then
									entity := true_entity
								else
									entity := false_entity
								end
								put_boolean (ok)
						else
							entity := r
							compute_function (r, parent, ds, values)
							end
						end
					end
				end
				adjust_address
			else
				if is_operator then
					tmp_str.copy (once "Operator is unknown")
				else
					tmp_str.copy (once "Query name is unknown")
				end
				if t.is_tuple then
					tmp_str.extend ('.')
				else
					tmp_str.append (once " (try command %"queries")
					if attached parent then
						tmp_str.extend (' ')
						tmp_str.append_integer (t.ident)
					end
					tmp_str.append (once "%").")
				end
				raise_with_code (Unknown_query, tmp_str)
			end
		ensure
			values_count: values.count = old values.count
		end

	compute_function (func: IS_ROUTINE; target: detachable DG_EXPRESSION; ds: IS_STACK_FRAME; values: DG_VALUE_STACK)
		require
			is_function: func.is_function or else func.is_creation
			when_function: func.is_function implies attached target as r and then r.is_defined
		local
			pt, tg: like arg
			lcl: detachable IS_LOCAL
			k, n: INTEGER
		do
			type := func.type
			values.put (Current)
			n := func.argument_count - 1
			if not attached arg and then n > 0 then
				create arg.make (column + name_count)
				arg.raise_with_code (Missing_args, once "Function arguments expected.")
			else
				from
					pt := arg
				until not attached pt or else k = n loop
					k := k + 1
					if not attached pt.next and then k < n then
						pt.raise_with_code (Too_few_args, Few_args)
					end
					pt := pt.next
				end
				if attached pt as pt_ then
					if n > 0 then
						pt_.raise_with_code (Too_many_args, Many_args)
					else
						pt_.raise_with_code (Too_many_args, Not_arg_less)
					end
				end
			end
			if attached target as t then
					-- qualified call 
				values.push (t)
			else
					-- unqualified call 
				create tg.make (column)
				tg.set_entity (current_entity)
				tg.compute_one (ds, values)
				tg.fix_value
			end
			from
				pt := arg
				k := 0
			until not attached pt as a or else k = n loop
				k := k + 1
				a.compute_one (ds, values)
				a.fix_value
				lcl := func.arg_at (k)
				check attached lcl end
				if not a.bottom.is_assignable_to (lcl.type) then
					values.pop (k + 1)
					a.raise_expected_type (lcl.type)
				end
				a.bottom.convert_to (lcl.type)
				pt := a.next
			end
			in_object := Void
			invoke (func, ds, values)
			fix_value
		ensure
			values_count: values.count = old values.count
		end

	compute_creation (ds: IS_STACK_FRAME; values: DG_VALUE_STACK)
		require
			is_creation: attached parent as p_ and then p_.entity = create_entity
		local
			r: IS_ROUTINE
			i: INTEGER
		do
			if attached arg as a then
				entities.clear
				from
					i := type.routine_count
				until i = 0 loop
					i := i - 1
					r := type.routine_at (i)
					if r.is_creation then
						entities.add (r)
					end
				end
				a.set_matching_entity (a.fast_name, type)
				if attached {IS_ROUTINE} a.entity as cr then
					a.compute_function (cr, Void, ds, values)
				else
					tmp_str.copy (once "Creation procedure is unknown (try command %"creates ")
					tmp_str.append_integer (type.ident)
					tmp_str.append (once "%").")
					raise_with_code (Unknown_query, tmp_str)
				end
			elseif attached type.default_creation as dc then
				compute_function (dc, Void, ds, values)
				fix_value
			end
		ensure
			values_count: values.count = old values.count
		end

	compute_constant (values: DG_VALUE_STACK)
		require
			is_values_top: values.count > 0 and then values.top = Current
		do
			in_object := Void
			if attached {IS_CONSTANT [STRING]} entity as l_str then
				put_any (l_str.value)
			else
				fix_value
				if attached {IS_CONSTANT [REAL_64]} entity as l_dbl then
					put_double (l_dbl.value)
				elseif attached {IS_CONSTANT [INTEGER_64]} entity as l_int then
					put_integer_64 (l_int.value)
				elseif attached {IS_CONSTANT [NATURAL_64]} entity as l_nat then
					put_natural_64 (l_nat.value)
				elseif attached {IS_CONSTANT [CHARACTER]} entity as l_char then
					put_character (l_char.value)
				elseif attached {IS_CONSTANT [BOOLEAN]} entity as l_bool then
					put_boolean (l_bool.value)
				else
					put_integer_64 (0)
				end
			end
		end

	compute_equality (ds: IS_STACK_FRAME; values: DG_VALUE_STACK)
		require
			has_arg: attached arg
			has_parent: attached parent as p_
			parent_is_defined: p_.is_defined
			is_equality: entity = equality_entity
		local
			ok, arg_ok: BOOLEAN
		do
			if attached parent as lhs and then attached lhs.type as lt then
				ok := lt.is_subobject or else attached lhs.as_any
				if attached arg as a then
					a.compute_one (ds, values)
				end
				if attached {DG_EXPRESSION} values.top as rhs
					and then attached rhs.type as rt
				 then
					rhs.fix_value
					arg_ok := rt.is_subobject or else attached rhs.as_any
					if not ok then
						ok := not arg_ok
					elseif not arg_ok then
						ok := False
					else
						ok := False
						if lhs.is_assignable_to (rt) then
							ok := lhs.compare_to (rhs.bottom)
						elseif rhs.is_assignable_to (lt) then
							ok := rhs.compare_to (lhs.bottom)
						end
					end
					ok := ok xor fast_name [1] = '/'
					values.pop (1)
					type := debuggee.boolean_type
					values.put (Current)
					put_boolean (ok)
					fix_value
				end
			end
			c_ptr := values.top.c_ptr
		ensure
			values_count: values.count = old values.count
		end

	compute_item (ds: IS_STACK_FRAME; values: DG_VALUE_STACK)
		require
			has_arg: attached arg
			is_bracket:	-- entity=bracket_entity 
		local
			loc: POINTER
			n: NATURAL
			off: INTEGER
		do
			if attached arg as a and then attached a.next then
				raise_with_code (0, once "Right bracket expected.")
			end
			values.put (Current)
			if attached parent as p and then attached {IS_SPECIAL_TYPE} p.type as sp
				and then attached p.as_any as pref
				and then attached arg as a 
			 then
				n := debuggee.special_capacity (pref, sp)
				n := compute_index (ds, values, a, 0, n - 1)
				in_object := pref
				offset := sp.item_offset (n.to_integer_32)
				type := sp.item_type
			end
			adjust_address
		ensure
			values_count: values.count = old values.count
		end

	compute_index (ds: IS_STACK_FRAME; values: DG_VALUE_STACK; ex: DG_EXPRESSION; low, high: NATURAL): NATURAL
		local
			it: detachable IS_TYPE
			pt: detachable DG_EXPRESSION
		do
			values.put (Current)
			it := debuggee.integer_type
			ex.compute_one (ds, values)
			pt := ex.bottom
			Result := pt.as_natural_32
			if not pt.is_assignable_to (it) then
				values.pop (1)
				pt.raise_expected_type (it)
			end
			pt.check_index (Result, low, high)
			values.pop (1)
			c_ptr := values.top.c_ptr
			fix_value
		ensure
			values.count = old values.count
		end

feature -- Error handling 

	raise_with_code (code: INTEGER; msg: STRING)
		require
			valid_code: No_expression_error <= code and then code < Last_expression_error
		do
			entity := Void
			type := Void
			inspect code
			when Missing_args, Too_few_args, Too_many_args, Not_a_function, Not_array_target, Array_target then
				separator_error := True
			else
				separator_error := False
			end
			msg_at.set_item (column)
			raise (msg)
		end

	raise_expected_type (t: IS_TYPE)
		do
			tmp_str.copy (once "Type ")
			t.append_name (tmp_str)
			tmp_str.append (once " expected.")
			raise_with_code (Failing_call, tmp_str)
		end

feature {DG_EXPRESSION} -- Implementation

	check_index (i, l, u: NATURAL)
		do
			if l > u then
				tmp_str.copy (once "Index range is empty.")
				entity := Void
				raise_with_code (Bad_index, tmp_str)
			elseif i < l or else i > u then
				tmp_str.copy (once "Index ")
				tmp_str.append_natural_32 (i)
				tmp_str.append (once " out of range ")
				tmp_str.append_natural_32 (l)
				tmp_str.append (once " .. ")
				tmp_str.append_natural_32 (u)
				tmp_str.extend ('.')
				entity := Void
				raise_with_code (Bad_index, tmp_str)
			end
		end

feature {DG_EXPRESSION} -- Output 

	append_checked_out (s: STRING; stop_at_error: BOOLEAN; arg_of: detachable DG_EXPRESSION): BOOLEAN
		note
			return:
			"[
			 Append STRING form if there was no error (i.e. `entity/=Void')
			 or if not `stop_at_error'.
			 ]"
			s: "STRING to be extended"
			arg_of: "DG_EXPRESSION having `Current' as `arg'"
		require
			not_operator: not is_operator
			when_arg: attached arg_of as a implies a.arg = Current
		local
			expr: detachable DG_EXPRESSION
			l: INTEGER
		do
			Result := stop_at_error implies attached entity or else up_frame_count > 0
			if Result then
				l := s.count + 1
				Result := append_plain (s, stop_at_error)
				from
					expr := down
				until not Result or else not attached expr loop
					if expr.is_infix then
						if attached {DG_OPERATOR} expr as op1 then
							Result := op1.append_infix (s, l, stop_at_error, arg_of)
						end
					elseif expr.is_prefix then
						if attached {DG_OPERATOR} expr as op2 then
							Result := op2.append_prefix (s, l, stop_at_error)
						end
					else
						if not expr.is_manifest then 
							s.extend ('.')
						end
						Result := expr.append_plain (s, stop_at_error)
					end
					expr := expr.down
				end
			end
		end

	append_plain (s: STRING; stop_at_error: BOOLEAN): BOOLEAN
		local
			e, pe: detachable IS_ENTITY 
			need_exclamation: BOOLEAN
		do
			Result := True
			if is_manifest then
				e := entity
				check e /= Void end
				if e = string_entity then
					s.extend ('"')
					s.append (fast_name)
					s.extend ('"')
				elseif e = character_entity then
					s.extend ('%'')
					s.append (fast_name)
					s.extend ('%'')
				elseif e = integer_entity or else e = double_entity then
					s.append (fast_name)
					if attached down as d and then not d.is_operator then
						s.extend (' ')
					end
				elseif e = current_entity then
					e.append_name (s)
				elseif e = old_entity then
					s.append (once "old:")
					s.append (fast_name)
				elseif e = bracket_entity then
				elseif e = all_entity then
					e.append_name (s)
				elseif e = range_entity then
				elseif e = if_entity then
					e.append_name (s)
					s.extend (' ')
				elseif e = placeholder_entity then
					append_placeholder (s)
				elseif e = alias_entity then
					s.append (Alias_prefix)
					s.append (fast_name)
				elseif e = closure_entity then
					s.extend ('_')
					s.append (fast_name)
				elseif e = constant_entity then
					s.extend ('{')
						if attached down as d
							and then attached {IS_CONSTANT [ANY]} d.entity as const
						 then
						const.home.append_name (s)
					else
						s.extend ('?')
					end
					s.extend ('}')
				elseif e = create_entity then
					s.extend ('!')
					need_exclamation := True
					s.append_integer (type.ident)
					if attached arg as a then
						s.extend (':')
						Result := a.append_checked_out (s, stop_at_error, Void)
					end
					s.extend ('!')
				else
					s.append (fast_name)
				end
			else
				Result := stop_at_error implies up_frame_count >= 0
				if Result and then up_frame_count > 0 then
					inspect up_frame_count
					when 0, -1 then
					when 1 then
						s.extend ('^')
						s.extend (' ')
					when 2 then
						s.extend ('^')
						s.extend ('^')
						s.extend (' ')
					when 3 then
						s.extend ('^')
						s.extend ('^')
						s.extend ('^')
						s.extend (' ')
					else
						s.extend ('^')
						s.append_integer (up_frame_count)
						s.extend ('^')
						s.extend (' ')
					end
				end
				if attached parent as p then
					pe := p.entity
				end
				if attached entity as e_ then
					if pe = constant_entity and then attached e_.text as x then
						x.append_name (s)
					elseif attached parent as p and then p.down = Current
						and then attached pe as pe_ and then attached pe_.text as x
						and then attached x.tuple_labels
					 then
						x.append_label (e_.fast_name, s)
					else
						e_.append_name (s)
					end
				elseif not stop_at_error then
					s.append (fast_name)
				else
					Result := False
				end
			end
			if Result and then not need_exclamation then
				Result := append_arguments (s, stop_at_error)
			end
		end

	append_arguments (s: STRING; stop_at_error: BOOLEAN): BOOLEAN
		local
			more: like next
			closing: CHARACTER
			open: BOOLEAN
		do
			Result := True
			if attached arg as a then
				if stop_at_error and then a.separator_error then
					Result := False
				else
					if entity = bracket_entity then
						s.extend ('[')
						closing := ']'
					else
						s.extend ('(')
						closing := ')'
					end
					open := True
				end
				from
					more := a
				until not Result or else not attached more loop
					if stop_at_error and then more.separator_error then
						Result := False
					elseif more /= a then
						s.extend (',')
					end
					if Result then
						Result := more.append_checked_out (s, stop_at_error, Current)
					end
					more := more.next
				end
				if Result and open then
					s.extend (closing)
				end
			end
		end

	append_placeholder (s: STRING)
		do
			s.append (fast_name)
		end

feature {DG_EXPRESSION} -- Implementation 

	set_matching_entity (nm: STRING; t: detachable IS_TYPE)
		note
			action:
				"[
				 Search element of `entities' by name.
				 If no such match then try tuple labels of `parent'
				 on attributes of `t' (if not `Void' and `t.is_tuple').
				 ]"
			nm: "initial part if name to match"
		local
			e: attached like entity
			l: IS_FEATURE_TEXT
			i, n: INTEGER
			found, not_unique: BOOLEAN
		do
			entity := Void
			from
				i := entities.count
			until found or else i = 0 loop
				i := i - 1
				if attached entities [i] as ei then
					if ei.has_name (nm) then
						entity := ei
						text := ei.text
						found := True
						not_unique := False
					elseif ei.name_has_prefix (nm) then
						not_unique := attached entity
						entity := ei
						text := ei.text
					end
				end
			end
			if not found and then attached t as t_ and then t_.is_tuple
				and then attached parent as p and then attached p.entity as pe
				and then attached pe.text as x
			 then
				if attached x.tuple_labels as tl then
					entity := Void
					not_unique := False
					check
						i = 0
					end
					from
						n := tl.count
					until found or else i = n loop
						l := tl [i]
						e := t.field_at (i)
						if l.has_name (nm) then
							entity := e
							text := l
							found := True
							not_unique := false
						elseif l.name_has_prefix (nm) then
							not_unique := attached entity
							entity := e
							text := l
						end
						i := i + 1
					end
				end
			end
			if not_unique then
				entity := Void
				text := Void
				raise_with_code (Not_unique_query, Query_name_not_unique)
			end
		end

	is_assignable_to_entity (e: attached like entity): BOOLEAN
		note
			return: "Can the value be assigned to entity `e'?"
		require
			has_entity: attached entity
		do
			Result := attached type as t and then attached e.type_set as ts
				and then ts.has (t)
		end

feature {} -- Implementation 

	Not_assignable: STRING = "Target is not writable."

	Not_conforming_types: STRING = "Source type does no conform to target type."

	Not_function: STRING = "Target is not a function; dot expected."

	Few_args: STRING = "Too few function arguments, comma expected."
	Many_args: STRING = "Too many function arguments; right parenthesis or bracket expected."

	Not_arg_less: STRING = "No arguments expected."

	No_array: STRING = "Target is not a SPECIAL type; dot expected."

	Not_variable: STRING = "Left hand side is not a variable."

	Query_name_not_unique: STRING = "Query name is not unique."

	Once_not_initialized: STRING = "Once function is not initialized."

	Disturbed_object: STRING = "Object is disturbed."

	entities: IS_SEQUENCE [IS_ENTITY]
		local
			f: detachable IS_FIELD
			l: detachable IS_LOCAL
			r: detachable IS_ROUTINE
			v: detachable IS_ONCE_CALL
			cb: detachable IS_CONSTANT [BOOLEAN]
			cc: detachable IS_CONSTANT [CHARACTER]
			ci: detachable IS_CONSTANT [INTEGER_64]
			cn: detachable IS_CONSTANT [NATURAL_64]
			cr: detachable IS_CONSTANT [REAL_64]
			cs: detachable IS_CONSTANT [STRING_8]
			cu: detachable IS_CONSTANT [STRING_32]
			cy: detachable IS_CONSTANT [ANY]
			e: detachable IS_ENTITY
		once
			create Result
			if attached Result then
			else
					-- Make assignment attempts available. 
				cy := cb
				cy := cc
				cy := ci
				cy := cn
				cy := cr
				cy := cs
				cy := cu
				e := cy
				e := f
				e := l
				e := r
				e := v
			end
		end

	invoke (r: IS_ROUTINE; ds: IS_STACK_FRAME; values: DG_VALUE_STACK)
		note
			action: "Call `r' and put result into `result_buffer'."
		local
			t: like type
			n1, n2: INTEGER
		do
			t := type
			values.invoke (r)
			if attached type then
				-- function called:
				t := type
			else
				-- procedure called, reset `type':
				type := t
			end
		ensure
			values_count: values.count = old values.count - r.argument_count + 1
		rescue
			entity := Void
			msg_at.set_item (column)
			clear_value
			tmp_str.wipe_out
			if exception = Signal_exception and then signal_number = Interrupt_signal then
				tmp_str.copy (once "Function interrupted.")
			else
				tmp_str.append (once "Assertion violation in called function")
				inspect exception
				when Precondition, Postcondition, Class_invariant, Loop_invariant, Check_instruction then
					if attached meaning (exception) as me then
						tmp_str.extend (':')
						tmp_str.extend (' ')
						tmp_str.append (me)
					end
				when Loop_variant then
					if n1 = 0 then
						tmp_str.append (once " init=")
						tmp_str.append_integer (n2)
					else
						tmp_str.append (once " old=")
						tmp_str.append_integer (n1)
						tmp_str.append (once ", new=")
						tmp_str.append_integer (n2)
					end
				else
				end
				tmp_str.extend ('.')
			end
			original_msg.copy (tmp_str)
		end

	check_addressable
		do
			if attached down then
			else
				raise_with_code (0, once "Function call is not allowed here.")
			end
		end

	adjust_address
		note
			return: "C address of value."
		local
			deref: POINTER
		do
			if attached in_object as obj then
				c_ptr := any_to_pointer (obj) + offset
			end
			if not type.is_subobject then
				deref := debuggee.dereferenced (c_ptr, type)
				if deref = default_pointer then 
					type := none_type
				else
					type := debuggee.type_of_any (pointer_to_any (deref), type)
				end
			end
		end

feature {DG_EXPRESSION} -- Implementation 

	link (p: like parent)
		do
			if entity /= placeholder_entity then
				parent := p
			end
		ensure
			parent_set: parent = p
		end

	unlink
		do
			parent := Void
		ensure
			no_parent: not attached parent
		end

	share_parent (old_parent, new_parent: DG_EXPRESSION)
		do
			if not attached parent then
			elseif parent = new_parent then
			elseif parent = old_parent then
				parent := new_parent
			end
			if attached next as n then
				n.share_parent (old_parent, new_parent)
			end
			if attached down as d then
				d.share_parent (old_parent, new_parent)
			end
			if attached arg as a then
				a.share_parent (old_parent, new_parent)
			end
			if attached detail as d then
				d.share_parent (old_parent, new_parent)
			end
		end

feature {} -- Implementation 

	tmp_str2: STRING = "1234567890123456789012345678901234567890"

invariant

	when_manifest: is_manifest implies attached entity

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
