note 

	description: 
		"Formatting and displaying of command results of the debugger." 
	 
class DG_OUTPUT 
	 
inherit 
	 
	DG_GLOBALS 
		undefine 
			default_create, 
			copy, is_equal, out 
		end 
	 
	PC_LAZY_DRIVER[NATURAL, ANY] 
		rename 
			make as make_pre_order, 
			reset as reset_driver, 
			deep as deep_traversal, 
			runtime_system as debuggee 
		undefine 
			debuggee 
		redefine 
			default_create, 
			source, target, 
			process_basic_field 
		end 
	
feature {NONE} -- Initialization 
	 
	default_create 
		do 
			create names
			create strings.make 
			system := debuggee
			make_pre_order (closure_table, types_table) 
			create source.make (system, {PC_BASE}.Fifo_flag)
			create target.make (system, source)
			if attached {DG_GUI_FILE} ui_file then
				short_length := {INTEGER_32}.max_value
			else
				short_length := 75
			end
		end 
 
feature -- Initialization 
 
	reset 
		do 
			target.set_closure (False)
			ui_file.set_print_mode (True) 
			target.set_file (ui_file) 
			silent := False
		end 
 
feature -- Command list 
	 
	overview 
		local 
			cmd: attached like no_command 
			name: STRING
			arg: detachable STRING 
			i, l, l0, n: INTEGER 
		do 
			ui_file.put_line (once "%FOverview of commands%N") 
			from
				n := commands.count
			until i = n loop 
				i := i + 1 
				cmd := commands[i] 
				name := cmd.name 
				arg := cmd.help_arg 
				l0 := name.count 
				if attached cmd.help_arg as ha then 
					l0 := l0 + 1 + ha.count 
				end 
				l := l.max (l0) 
			end 
			from
				i := 0
			until i = n loop 
				i := i + 1 
				cmd := commands[i] 
				name := cmd.name 
				if attached cmd.help_line as hl then 
					tmp_str1.wipe_out 
					tmp_str1.append (name) 
					if attached cmd.help_arg as ha then 
						tmp_str1.extend (' ') 
						tmp_str1.append (ha) 
					end 
					l0 := tmp_str1.count 
					multiple_extend (tmp_str1, ' ', l - l0 + 1) 
					tmp_str1.append (hl) 
					ui_file.put_line (tmp_str1) 
				end 
			end 
		end 
	 
feature -- Messages 
 
	silent: BOOLEAN 
 
	set_silent (s: BOOLEAN) 
		do 
			silent := s 
		ensure 
			silent_set: silent = s 
		end 
	 
	error (msg: STRING) 
		do 
			if not silent then 
				tmp_str1.copy (error_prompt) 
				tmp_str1.append (msg) 
				ui_file.put_line (tmp_str1) 
			end 
		end 
	 
	command_message (msg: STRING; after: INTEGER) 
		require 
			not_negative:	after > 0 
		local 
			i: INTEGER 
		do 
			if not silent then 
				tmp_str1.wipe_out 
				from
					i := after
				until i = 0 loop 
					tmp_str1.extend ('.') 
					i := i - 1 
				end 
				tmp_str1.extend ('|') 
				ui_file.put_line (tmp_str1) 
				error (msg) 
			end 
		end 
	 
	expression_msg (ex: DG_EXPRESSION; after: INTEGER)
		local
			excess: INTEGER
		do 
			tmp_str1.wipe_out 
			multiple_extend (tmp_str1, ' ', target.indent_size) 
			if not ex.has_result then 
				tmp_str1.extend ('?')
				excess := 1
			end 
			ex.append_single (tmp_str1) 
			ui_file.put_line (tmp_str1) 
			tmp_str1.wipe_out 
			ex.append_out_until_bad (tmp_str1) 
			if original_msg.is_empty then 
				original_msg.copy (once "Internal error.") 
			end 
			command_message (original_msg, after + excess + tmp_str1.count) 
		end 
	 
	bottom_frame_message 
		do 
			error (once "Stack bottom reached.") 
		end 
	 
	top_frame_message 
		do 
			error (once "Stack top reached.") 
		end 
	 
	after_end_message 
		do 
			error (once "System has completed successfully.") 
		end 
	 
	exception_message (reason, errno: INTEGER; crashed: BOOLEAN) 
		do 
			tmp_str1.copy (once "Exception: ") 
			display_exception_name (reason, errno, tmp_str1) 
			if crashed then 
				error (once "System has crashed") 
			end 
		end 
	 
	signal_message (sig: INTEGER; crashed: BOOLEAN) 
		do 
			tmp_str1.wipe_out 
			tmp_str1.append (once "OS signal ") 
			tmp_str1.append_integer (sig) 
			error (tmp_str1) 
		end 
	 
	interrupt_message 
		do 
			error (once "Interrupt.") 
		end 
	 
	breakpoint_message (ds: IS_STACK_FRAME; bp: DG_BREAKPOINT; reason, match: INTEGER) 
		local
			fmt: INTEGER
		do 
			tmp_str1.wipe_out 
			inspect match 
			when Break_match, Trace_match then 
				bp.append_short_out (tmp_str1);	 
			when Error_match then 
				tmp_str1.append (once "Error in ") 
				bp.append_out (tmp_str1);	 
			else 
			end 
			ui_file.put_line (tmp_str1) 
			if bp.has_catch and then reason > 0 then 
				tmp_str1.copy (once "  actual reason : ") 
				display_exception_name (reason, 0, tmp_str1) 
			end 
			tmp_str1.wipe_out 
			if bp.has_watch then
			   	fmt := target.format | {DG_TEXT_TARGET}.With_address
				if attached bp.old_watch as v and then attached v.type as vt then
					print_variable (once "  old", Void, v.address, vt, 0, fmt)
				end
				if attached bp.watch_value as v and then attached v.type as vt then
					print_variable (once "  new", Void, v.address, vt, 0, fmt)
				end
			end 
			if match = Error_match and then bp.has_if then 
				if attached bp.if_condition as ex and then not ex.has_result then 
					tmp_str1.wipe_out 
					tmp_str1.extend ('?') 
					ex.append_out_until_bad (tmp_str1) 
					command_message (original_msg, tmp_str1.count + bp.prompt_count) 
					bp.correct_if_condition 
				end 
			end 
			if attached bp.do_action as bpa then 
				display_expressions (ds, bpa, 0, 0) 
				bp.correct_do_action 
			end 
		end 
	 
	explicit_break_message (ds: IS_STACK_FRAME; tracing: BOOLEAN) 
		do	 
			if tracing then 
				ui_file.put_line (once "Tracing debug statement") 
			else 
				ui_file.put_line (once "Break at debug statement") 
			end 
		end 
	 
	bye_message 
		do 
		end 
	 
feature -- Welcome message 
	 
	greetings 
		once 
			if pma then 
				tmp_str1.copy (once 
"[ 
											 
The system has crashed: this is the GEC post mortem analyser. 
						 
Below you see reason of the crash, the source code around 
the actual program point and the value of `Current'. 
 
]") 
			else 
				tmp_str1.copy (once 
"[ 
 
                  Welcome to the GEC debugger 
 
Below you see the source code around the actual program point 
and the value of `Current'. 
 
]") 
			end 
			tmp_str1.append (once 
"[ 
Then the command prompt follows and you may enter commands. Enter 
  ?      to get a compact overview of the commands, 
  help   to get extensive help, 
  quit   to exit from the program. 
 
 
]") 
			ui_file.put_line (tmp_str1) 
		end 
	 
feature -- Program status display 
	 
	display_current (ds: IS_STACK_FRAME; deep, verbose: BOOLEAN; fmt: INTEGER) 
		local 
			p, pc, null: POINTER 
			a: detachable ANY 
			t: detachable IS_TYPE 
			tc: IS_TYPE 
			r: IS_ROUTINE 
			f: IS_FIELD
			l: detachable IS_LOCAL 
			j, k, m, n: INTEGER 
			def_fmt: INTEGER 
			anonymous: BOOLEAN 
		do 
			t := ds.target_type
			check attached t end
			p := ds.target 
			r := ds.routine 
			if not t.is_special then 
				def_fmt := fmt | {DG_TEXT_TARGET}.Without_defaults 
				def_fmt := def_fmt.bit_xor ({DG_TEXT_TARGET}.Without_defaults)
			end
			target.set_short_output (True)
			if not t.is_subobject then 
				a := as_any (p) 
				if not t.is_subobject then 
					t := system.type_of_any (a, t) 
				end 
			end 
			check attached t end
			tc := t
			anonymous := r.is_anonymous 
			if anonymous then 
				m := r.argument_count 
				pc := p
				if attached system.type_of_any (a, Void) as ta then
					tc := ta
				end
				f := tc.field_at (0) 
				t := f.type 
				p := system.dereferenced (p + f.offset, t) 
			end 
			if p = null then 
			else 
				if deep then 
					n := {INTEGER_32}.max_value 
				elseif verbose then 
					n := 1 
				end 
				if not t.is_subobject then 
					t := system.type_of_any (a, t) 
				end 
				check attached t end
				print_variable (once "Current", Void, p, t, n, def_fmt) 
			end 
			if verbose then
				from 
					k := 1	-- skip over routine's `Current' 
					n := r.variable_count 
				until k >= n loop 
					l := r.var_at (k) 
					if attached {IS_SCOPE_VARIABLE} l as ot
						and then not ot.in_scope (ds.line, ds.column)
					 then 
						l := Void 
					end 
					if attached l as l_ then 
						if anonymous then 
							if l_.offset = 0 then 
								j := j + 1 
								f := tc.field_at (j) 
								t := f.type 
								p := pc + f.offset 
							else 
								p := ds.stack_address (k) 
							end 
						else 
							p := ds.stack_address (k) 
						end 
						t := l_.type 
						check attached t end
						if not t.is_subobject then 
							p := system.dereferenced (p, t) 
							if p /= null then 
								if not t.is_subobject then 
									t := system.type_of_any (as_any (p), t) 
								end 
							end 
						end 
						var_str.wipe_out 
						l_.append_name (var_str) 
						check attached t end
						print_variable (var_str, Void, p, t, 0, def_fmt) 
					end 
					k := k + 1 
				end 
			end 
			source.reset 
		end 
	 
	display_expressions (ds: IS_STACK_FRAME; root: DG_EXPRESSION; depth, fmt: INTEGER) 
		do
			target.reset (False)
			target.set_short_output (fmt & {DG_TEXT_TARGET}.Long_output = 0)
			print_expression_list (ds, root, depth, fmt) 
			source.reset 
		end 
 
	print_deep_expression (ds: IS_STACK_FRAME; ex: DG_EXPRESSION; depth, fmt: INTEGER) 
		local 
			node: DG_EXPRESSION 
			e: detachable IS_ENTITY
			t: detachable IS_TYPE 
			addr, null: POINTER 
			id: NATURAL 
			d: INTEGER 
			def_fmt: INTEGER 
			cap, first, last, k: NATURAL 
			selective, detailed, with_defaults: BOOLEAN 
		do 
			target.set_closure (False)
			target.set_flat (False) 
			ex.compute (ds, value_stack) 
			node := ex.bottom 
			t := node.type 
			check attached t end
			e := node.entity
			check attached e end
			def_fmt := fmt 
			if attached {DG_RANGE_EXPRESSION} node as idx then 
				first := idx.lower_limit
				last := idx.upper_limit
				cap := idx.capacity 
				selective := idx.is_selective 
				addr := idx.array_location 
				with_defaults := def_fmt & target.Without_defaults = 0
			else 
				if not t.is_special then
					def_fmt := def_fmt | target.Without_defaults 
					def_fmt := def_fmt.bit_xor (target.Without_defaults)
				end 
				addr := node.address 
				if t.is_subobject and then not node.is_manifest 
					and then attached e.type as et and then not et.is_subobject 
				 then 
					t := et
					addr := system.dereferenced (addr, t) 
				end
			end 
			if node.is_detailed then 
				d := node.detail_depth 
				if d < 0 then 
					d := 0 
					detailed := True 
				end 
			else 
				d := depth 
			end 
			var_str.wipe_out
			ex.append_single (var_str)
			if attached {DG_RANGE_EXPRESSION} node as idx
				and then attached idx.array_type as sp
			 then
				t := sp.item_type 
				check attached t end
				target.set_top_name (var_str) 
				if attached as_any (addr)as a then
					source.pre_special (sp, cap, a) 
					target.pre_special (sp, cap, id) 
					from
						k := first
					until k > last loop 
						idx.move_to_index (k) 
						addr := idx.address
						if not selective or else idx.valid_index (k, ds, value_stack) then 
							target.set_index (sp, k, id)
							if with_defaults or else addr /= null then
								print_variable (Void, Void, addr, t, d, def_fmt) 
								if detailed and then attached idx.detail as det then 
									target.indent
									print_expression_list (ds, det , (d-1).max (0), def_fmt) 
									target.dedent
								end 
							end
						end
						k := k + 1 
					end
					source.post_special (sp, a) 
				end 
				target.post_special (sp, id)
			else
				check attached t end
 				print_variable (var_str, e, addr, t, d, def_fmt) 
				if detailed and then attached node.detail as det then 
					target.indent
					print_expression_list (ds, det, (d-1).max (0), def_fmt) 
					target.dedent
				end 
			end 
			value_stack.pop (1) 
		end 
	 
	display_closure (ex: DG_EXPRESSION; ds: IS_STACK_FRAME; fmt: INTEGER) 
		require 
			ex_computed: ex.has_result 
		local 
			node: DG_EXPRESSION 
			t: IS_TYPE 
			snt: detachable IS_TYPE
			a: detachable ANY 
			fl: INTEGER
			m: NATURAL
		do 
			dynamic_type := Void
			capacity := 0
			target.reset (False)
			target.set_closure (True)
			target.set_short_output (True)
			target.set_format (fmt)
			var_str.wipe_out 
			ex.append_single (var_str) 
			target.set_top_name (var_str) 
			node := ex.bottom 
			if attached node.type as nt then
				t := nt
				a := node.as_any
			else
				snt := none_type
				t := snt
			end
			if closure_table.has (a) then 
				target.put_known_ident (closure_table[a], types_table[a], node.entity.type) 
			else 
				source.set_top_object (a) 
				if attached {IS_ENTITY} node.entity as f
					and then attached f.type as ft
				 then 
					source.set_field (f, a)
					target.set_field_and_type (f, ft)
				end
				inspect fmt & Order_flag 
				when Deep_flag then 
					fl := Deep_flag 
					target.set_flat (False)
				else 
					fl := Fifo_flag 
					target.set_flat (True)
				end
				source.set_order (fl)
				m := target.max_closure_ident 
				traverse (target, source, fl) 
				if target.max_closure_ident > m then 
					m := target.max_closure_ident 
					closure_roots.force ([a, ex, m, ds.depth]) 
				end 
			end 
			source.reset 
		rescue 
			source.reset 
		end 
	 
	display_nameof (ex: DG_EXPRESSION; ds: IS_STACK_FRAME; n: INTEGER; typed: BOOLEAN) 
		require 
			is_closure_entity: ex.is_manifest and then ex.entity = closure_entity 
		local 
			root: like closure_top 
			top: detachable DG_EXPRESSION 
			k: INTEGER 
			id: NATURAL
		do 
			tmp_str1.wipe_out 
			ex.append_name (tmp_str1) 
			id := tmp_str1.to_natural 
			root := closure_root_of_ident (id) 
			check attached root end 
			k := ds.depth - root.depth 
			if k < 0 then 
				tmp_str1.copy (once "Closure ident not visible from current stack frame, go ") 
				tmp_str1.append_integer (-k) 
				tmp_str1.append (once " levels down.") 
				raise (tmp_str1) 
			end 
			top := root.expr
			check attached top end
			top.set_up_frame_count (top.up_frame_count + k) 
			tmp_str1.wipe_out 
			top.append_single (tmp_str1) 
			top.set_up_frame_count (top.up_frame_count - k)
			target.append_qualified_name (id, tmp_str1, typed, False)
			ui_file.put_line (tmp_str1)
		end 

	display_program_point (ds: IS_STACK_FRAME; wide: BOOLEAN; lr: DG_LINE_RANGE) 
		local
			cls: IS_CLASS_TEXT 
			row: INTEGER 
		do 
			tmp_str1.wipe_out
			cls := ds.routine.home
			if ds.line > 0 then 
				row := ds.line 
				lr.set_class (cls) 
				if wide then 
					lr.set_first_line ( (row-5).max (1)) 
					lr.set_count (7) 
				else 
					lr.set_first_line (row) 
					lr.set_count (1) 
				end 
				display_processor 
				display_source (lr, row, ds.column) 
				display_current (ds, False, False, 0) 
			else 
				ui_file.put_line (once "Stack information not available at this level.") 
			end 
		end 
	 
	display_processor 
		do 
			if actual_proc.exists then 
				tmp_str1.wipe_out 
				tmp_str1.append (once "SCOOP processor ") 
				tmp_str1.append_integer (actual_proc.ident) 
				ui_file.put_line (tmp_str1) 
			end 
		end 
	 
	display_frame (ds: IS_STACK_FRAME; level, depth, line, col: INTEGER; 
								is_actual, first: BOOLEAN) 
		require 
			valid_level:	0 <= level and then level <= depth 
		local 
			r: IS_ROUTINE 
			l, c: INTEGER 
			valid: BOOLEAN 
		do 
			tmp_str1.wipe_out 
			tmp_str1.append_integer (depth) 
			l := tmp_str1.count 
			if first then 
				display_processor 
				tmp_str1.wipe_out 
				tmp_str1.append (once "Stack depth = ") 
				tmp_str1.append_integer (depth) 
				ui_file.put_line (tmp_str1) 
			end 
			tmp_str1.wipe_out 
			r := ds.routine 
			if is_actual then 
				tmp_str1.extend ('*') 
			else 
				tmp_str1.extend (' ') 
			end 
			valid := attached r.home as cls and then cls.is_debug_enabled 
				and then (ds.line > 0 or else line > 0) 
			if valid then 
				tmp_str1.extend (' ') 
			else 
				tmp_str1.extend ('-') 
			end 
			if ds.is_rescueing then 
				tmp_str1.extend ('>') 
			else 
				tmp_str1.extend (' ') 
			end 
			tmp_str1.extend (' ') 
			append_sized_int (tmp_str1, level, l) 
			tmp_str1.extend (' ') 
			if attached r.home as cls then 
				cls.append_name (tmp_str1) 
				tmp_str1.extend ('.') 
				r.append_name (tmp_str1) 
				if line > 0 then 
					l := line 
					c := col 
				else 
					l := ds.line 
					c := ds.column 
				end 
				if l > 0 then 
					tmp_str1.extend (':') 
					tmp_str1.append_integer (l) 
					tmp_str1.extend (':') 
					tmp_str1.append_integer (c) 
				end 
			else 
			end 
			ui_file.put_line (tmp_str1) 
		end 
 
	print_variable (nm: detachable STRING; f: detachable IS_ENTITY;
		obj: POINTER; td: IS_TYPE; depth: INTEGER; fmt: INTEGER) 
		require 
			when_type: not attached td implies obj = default_pointer 
		local 
			dyn: IS_TYPE 
			nt: detachable IS_TYPE
			any: detachable ANY 
			old_indent: INTEGER 
		do 
			dynamic_type := Void
			capacity := 0
			target.set_closure (False)
			target.set_format (fmt)
			old_indent := target.indent_size 
			if obj = default_pointer then 
				nt := none_type
				check attached nt end
				dyn := nt
				source.set_top_object (any) 
			else 
				dyn := td 
				if not dyn.is_subobject then 
					any := dyn	-- make `any' living 
					any := as_any (obj) 
					if attached system.type_of_any (any, dyn) as d then
						dyn := d
					end
				end 
				if dyn.is_subobject then 
					source.set_address (obj, dyn.instance_bytes) 
				else 
					source.set_top_object (any) 
				end 
			end 
			if attached nm as nn then 
				target.set_top_name (nn) 
			end 
			target.set_field_and_type (f, dyn)
			target.set_flat (False) 
			print_deep_variable (dyn, depth, True) 
			target.set_indent_size (old_indent)
		rescue 
			target.set_indent_size (old_indent)
		end 
 
	display_type (tp: IS_TYPE; 
							 attrs: detachable IS_SEQUENCE[IS_FIELD]; 
							 funcs: detachable IS_SEQUENCE[IS_ROUTINE]; 
							 creates: detachable IS_SEQUENCE[IS_ROUTINE]; 
							 onces: detachable IS_SEQUENCE[IS_ONCE_CALL]; 
							 consts: detachable IS_SEQUENCE[IS_CONSTANT[ANY]]; 
							 args, locs, olds, tests: detachable IS_SEQUENCE[IS_LOCAL]) 
		local 
			fd: IS_FIELD 
			ld: IS_LOCAL 
			rd: IS_ROUTINE 
			o: IS_ONCE_CALL 
			at: POINTER 
			i, n: INTEGER 
			ok: BOOLEAN 
		do
			target.set_short_output (True)
			tmp_str1.wipe_out 
			tmp_str1.copy (once "type ") 
			tmp_str1.append_integer (tp.ident) 
			tmp_str1.extend (' ') 
			tp.append_name (tmp_str1) 
			ui_file.put_line (tmp_str1) 
			target.set_indent_size (target.indent_increment)
			if attached args as aa then 
				n := aa.count 
				if n > 0 then 
					ui_file.put_line (once "Arguments") 
					from
						i := 0
					until i = n or else ui_file.skip_lines loop 
						ld := aa [i] 
						tmp_str1.wipe_out 
						target.put_indented (tmp_str1) 
						ld.append_name (tmp_str1) 
						tmp_str1.extend (':')
						tmp_str1.extend (' ')
						ld.type.append_name (tmp_str1) 
						ui_file.put_line (tmp_str1) 
						i := i + 1 
					end 
				end 
			end 
			if attached locs as ll and then not ui_file.skip_lines then 
				n := ll.count 
				if n > 0 then 
					ui_file.put_line (once "Local variables") 
					from
						i := 0
					until i = n loop 
						ld := ll[i] 
						tmp_str1.wipe_out 
						target.put_indented (tmp_str1) 
						ld.append_name (tmp_str1) 
						tmp_str1.extend (':')
						tmp_str1.extend (' ')
						ld.type.append_name (tmp_str1) 
						ui_file.put_line (tmp_str1) 
						i := i + 1 
					end 
				end 
			end	 
			if attached olds as oo and then not ui_file.skip_lines then 
				n := oo.count 
				if n > 0 then 
					ui_file.put_line (once "Old values") 
					from
						i := 0
					until i = n or else ui_file.skip_lines loop 
						ld := oo[i] 
						tmp_str1.wipe_out 
						target.put_indented (tmp_str1) 
						ld.append_name (tmp_str1) 
						tmp_str1.extend (':')
						tmp_str1.extend (' ')
						ld.type.append_name (tmp_str1) 
						ui_file.put_line (tmp_str1) 
						i := i + 1 
					end 
				end 
			end	 
			if attached tests as tt and then not ui_file.skip_lines then 
				n := tt.count 
				if n > 0 then 
					ui_file.put_line (once "Object test locals") 
					from
						i := 0
					until i = n or else ui_file.skip_lines loop 
						ld := tt[i] 
						tmp_str1.wipe_out 
						target.put_indented (tmp_str1) 
						ld.append_name (tmp_str1)
						tmp_str1.extend (':')
						tmp_str1.extend (' ')
						ld.type.append_name (tmp_str1) 
						ui_file.put_line (tmp_str1) 
						i := i + 1 
					end 
				end 
			end	 
			if attached attrs as aa and then not ui_file.skip_lines then 
				n := aa.count 
				if n > 0 then 
					ui_file.put_line (once "Attributes") 
					from
						i := 0
					until i = n or else ui_file.skip_lines loop 
						fd := aa[i] 
						tmp_str1.wipe_out 
						target.put_indented (tmp_str1) 
						fd.append_name (tmp_str1) 
						tmp_str1.extend (':')
						tmp_str1.extend (' ')
						fd.type.append_name (tmp_str1) 
						ui_file.put_line (tmp_str1) 
						i := i + 1 
					end 
				end 
			end 
			if attached funcs as ff and then not ui_file.skip_lines then 
				n := ff.count 
				if n > 0 then 
					ui_file.put_line (once "Functions") 
					from
						i := 0
					until i = n or else ui_file.skip_lines loop 
						tmp_str1.wipe_out 
						target.put_indented (tmp_str1) 
						format_function_call (ff[i], tmp_str1) 
						ui_file.put_line (tmp_str1) 
						i := i + 1 
					end 
				end 
			end 
			if attached onces as oo and then not ui_file.skip_lines then 
				n := oo.count 
				ok := False 
				from
					i := 0
				until ok or else i = n loop 
					o := oo[i] 
					ok := o.is_initialized 
					i := i + 1 
				end 
				if ok then 
					ui_file.put_line (once "Once functions") 
					from
						i := 0
					until i = n or else ui_file.skip_lines loop 
						o := onces[i] 
						if o.is_initialized then 
							var_str.wipe_out 
							o.append_name (var_str) 
							target.set_top_name (var_str) 
							if attached o.value as ov and then attached ov.type as ot then
								at := system.dereferenced (ov.address, ot) 
								print_variable (var_str, Void, at, ot, 0, 0)
							end
						end 
						i := i + 1 
					end 
				end 
			end 
			if attached consts as cc and then not ui_file.skip_lines then 
				n := cc.count 
				if n > 0 then 
					ui_file.put_line (once "Constants") 
					from
						i := 0
					until i = n or else ui_file.skip_lines loop 
						print_constant (cc [i])
						i := i + 1 
					end 
				end 
			end 
			if attached creates and then not ui_file.skip_lines then 
				n := creates.count 
				if n > 0 then 
					ui_file.put_line (once "Creation procedures") 
					from
						i := 0
					until i = n or else ui_file.skip_lines loop 
						tmp_str1.wipe_out 
						target.put_indented (tmp_str1) 
						rd := creates[i] 
						if attached rd.type as rt and then rd = rt.default_creation then 
							tmp_str1.replace_substring (once "*", 1, 1) 
						end 
						format_function_call (rd, tmp_str1) 
						ui_file.put_line (tmp_str1) 
						i := i + 1 
					end 
				end 
			end 
			target.set_indent_size (0) 
		end 
	 
	display_universe (types: IS_SEQUENCE[IS_NAME]; ex: detachable DG_EXPRESSION; 
									 headline: STRING; with_classes: BOOLEAN) 
		require 
			ex_has_result: attached ex as ex_ implies ex_.has_result 
		local 
			this, next: detachable IS_NAME 
			tp: detachable IS_TYPE 
			cls: detachable IS_CLASS_TEXT 
			i, l, n, id: INTEGER 
			c, t, e, g: CHARACTER 
		do 
			tmp_str1.wipe_out 
			tmp_str1.append_integer (system.type_count-1) 
			l := tmp_str1.count 
			if attached ex as ex_ and then attached ex_.bottom.entity as ent
				and then attached ent.type as tp_
			 then 
				tp := tp_
				tmp_str1.wipe_out 
				tmp_str1.append (once "Static type:  ") 
				append_sized_int (tmp_str1, tp_.ident, l) 
				tmp_str1.extend (' ') 
				tp_.append_name (tmp_str1) 
				ui_file.put_line (tmp_str1) 
			end 
			tmp_str1.wipe_out 
			n := types.count 
			tmp_str1.append_integer (n) 
			tmp_str1.extend (' ') 
			tmp_str1.append (headline) 
			if n > 0 then 
				tmp_str1.extend (':') 
			end 
			ui_file.put_line (tmp_str1) 
			from
				i := 0
			until i = n loop 
				tmp_str1.wipe_out 
				t := ' ' 
				c := ' ' 
				e := ' ' 
				g := ' ' 
				id := 0 
				this := types[i] 
				tp := Void 
				cls := Void 
				if attached {IS_TYPE} this as tp_ and then (not with_classes or else tp_.is_alive) then 
					tp := tp_
				end 
				if attached {IS_CLASS_TEXT} this as cl_ then 
					cls := cl_
				end 
				i := i + 1 
				if i < n then 
					next := types[i] 
					if next.same_name (this) then 
						if attached {IS_TYPE} next as tp_ and then (not with_classes or else tp_.is_alive) then 
							tp := tp_ 
						end 
						if attached {IS_CLASS_TEXT} next as cl_ then 
							cls := cl_
						end 
						i := i + 1 
					end 
				end 
				if attached tp as tp_ then 
					t := 'T' 
					if tp_.is_basic then 
						e := 'b' 
					elseif tp_.is_subobject then 
						e := 'x' 
					elseif tp_.is_separate then 
						e := 's' 
					end 
					id := tp_.ident 
				end 
				if with_classes and then attached cls as cls_ then 
					c := 'C' 
					if not cls_.is_debug_enabled then 
						g := '-' 
					end 
					if e = ' ' then 
						if cls_.is_deferred then 
							e := 'd' 
						end 
					end 
				end 
				if id > 0 then 
					append_sized_int (tmp_str1, id, l) 
					tmp_str1.extend (' ') 
				else 
					multiple_extend (tmp_str1, ' ', l + 1) 
				end 
				if with_classes then 
					tmp_str1.extend (c) 
					tmp_str1.extend (t) 
					tmp_str1.extend (g) 
				end 
				tmp_str1.extend (e) 
				tmp_str1.extend (' ') 
				if attached tp as tp_ then 
					tp_.append_name (tmp_str1) 
				elseif with_classes and then attached cls as cls_ then 
					cls_.append_name (tmp_str1) 
				end 
				if tmp_str1[tmp_str1.count] /= ' ' then 
					ui_file.put_line (tmp_str1) 
				end 
			end 
		end 
	 
	display_system 
		do 
			tmp_str1.wipe_out 
			tmp_str1.append (once   "System name       : ") 
			system.append_name (tmp_str1) 
			tmp_str1.append (once "%NRoot creation     : ")
			if attached system.root_type as root then
				root.append_name (tmp_str1)
			end
			tmp_str1.extend ('.')
			if attached system.root_creation_procedure as root then
				root.append_name (tmp_str1)
			end
			tmp_str1.append (once "%NGarbage collection: ") 
			if system.has_gc then 
				tmp_str1.append (once "yes") 
			else 
				tmp_str1.append (once "no") 
			end 
			tmp_str1.append (once "%NAssertion check   : ") 
			inspect system.assertion_check 
			when Void_call_target then 
				tmp_str1.append (once "Call on void target") 
			when No_more_memory then 
				tmp_str1.append (once "No more memory") 
			when Routine_failure then 
				tmp_str1.append (once "Routine failure") 
			when Eiffel_runtime_panic then 
				tmp_str1.append (once "CAT-call") 
			when Operating_system_exception then 
				tmp_str1.append (once "OS signal") 
			when Developer_exception then 
				tmp_str1.append (once "Developer exception") 
			else 
				tmp_str1.append (once "Unkown exception") 
			end 
			ui_file.put_line (tmp_str1) 
		end 
	 
	display_source (lr: DG_LINE_RANGE; row, col: INTEGER) 
		require 
			class_not_void: attached lr.cls 
			not_relative: not lr.is_relative 
		local 
			l, c, fl, ll, len: INTEGER 
		do 
			if attached lr.cls as cls then
				if attached cls.path then 
					if attached lr.text as x then 
						fl := x.first_line 
						ll := x.last_line 
					else 
						fl := lr.first_line 
						ll := lr.last_line 
					end 
					tmp_str1.wipe_out 
					tmp_str1.append_integer (ll) 
					len := tmp_str1.count 
					tmp_str1.wipe_out 
					tmp_str1.append (once "class ") 
					cls.append_name (tmp_str1) 
					ui_file.put_line (tmp_str1) 
					from 
						open_source (lr) 
						l := fl 
					until not is_source_file_open or else l > ll or else ui_file.skip_lines loop 
						tmp_str1.wipe_out 
						tmp_str1.extend (bp_indicator (cls, l)) 
						tmp_str1.extend (' ') 
							append_sized_int (tmp_str1, l, len) 
							tmp_str1.extend (' ') 
							tmp_str2.wipe_out 
							read_source_line (tmp_str2) 
						if l = row then 
							c := col 
						else 
							c := 0 
						end 
						display_source_line (tmp_str1, tmp_str2, c) 
						l := l + 1 
					end 
					if not is_source_file_open then 
						ui_file.put_line (once "[EOF]") 
						lr.set_first_line (1) 
						else 
							lr.set_first_line (l) 
					end
				end
			end 
		ensure 
			absolute_range:	not lr.is_relative 
		rescue 
			if attached lr.cls as cls and then attached cls.path then 
				cls.invalidate_path 
			end 
		end 
 
	display_source_line (s, line: STRING; col: INTEGER) 
			-- Append formatted source code line `line' to `s' then print `s'. 
			-- `col>0' means that this position is to be highlighted. 
		local 
			i, j, l, n: INTEGER 
			c: CHARACTER 
		do 
			l := s.count 
			from
				n := line.count
			until i = n loop 
				i := i + 1 
				c := line[i] 
				if c = '%T' then 
					from
						j := target.indent_increment - (s.count \\ target.indent_increment) 
					until j = 0 loop 
						s.extend (' ') 
						j := j - 1 
					end	 
				else 
					s.extend (c) 
				end 
			end 
			ui_file.put_line (s) 
			if col > 0 then 
				s.wipe_out 
				from
				until l = 0 loop 
					s.extend (' ') 
					l := l - 1 
				end 
				from
					i := 1
				until i = col loop 
					c := line[i] 
					if c = '%T' then 
						from
							j := target.indent_increment - (s.count \\ target.indent_increment) 
						until j = 0 loop 
							s.extend (' ') 
							j := j - 1 
						end						 
					else 
						s.extend (' ') 
					end 
					i := i + 1 
				end 
				s.extend ('^') 
				ui_file.put_line (s) 
			end 
		end 
	 
	display_globals (types_and_classes: IS_SEQUENCE[IS_NAME]) 
		local
			t: IS_TYPE
			c: IS_CLASS_TEXT
			c0: detachable IS_CLASS_TEXT
			txt: IS_FEATURE_TEXT
			o: detachable IS_ONCE_CALL 
			y: detachable IS_CONSTANT[ANY]
			x: IS_NAME
			p : POINTER 
			i, jo, jy, k, m, n, no, ny: INTEGER 
			init: BOOLEAN 
		do
			target.set_short_output (True)
			no := system.once_count 
			ny := system.constant_count 
			n := no + ny 
			if n > 0 then 
				from 
					i := 0 
					jo := 0 
					jy := 0
					if jo<no then
						o := system.once_at(jo)
						jo := jo + 1
					end
					if jy<ny then
						y := system.constant_at(jy)
						jy := jy + 1
					end
				until o = Void and y = Void loop
					var_str.wipe_out
					target.set_indent_size (target.indent_increment)
					if o /= Void and then y /= Void then
						if o.home.is_less(y.home) or else
							(o.home.is_equal(y.home) and then o.name.is_less(y.name))
						 then
							x := o
							c := o.home
							txt := o.text
							init := o.is_initialized
							if jo < no then
								o := system.once_at(jo)
								jo := jo + 1
							else
								o := Void
							end
						else
							x := y
							c := y.home
							txt := y.text
							init := True
							target.set_field_and_type (y, y.type)
							from
								y := Void
							until attached y or else jy = ny loop
								y := system.constant_at(jy)
								if not attached {IS_UNIQUE} y then
									y := Void
								end
								jy := jy + 1
							end
						end
					elseif o /= Void then
						x := o
						c := o.home
						txt := o.text
						init := o.is_initialized
						if jo < no then
							o := system.once_at(jo)
							jo := jo + 1
						else
							o := Void
						end
					elseif y /= Void then
						x := y
						c := y.home
						txt := y.text
						init := True
						target.set_field_and_type (y, y.type)
						from
							y := Void
						until attached y or else jy = ny loop
							y := system.constant_at(jy)
							if not attached {IS_UNIQUE} y then
								y := Void
							end
							jy := jy + 1
						end
					end
					if c /= c0 then
						c.append_name (var_str) 
						var_str.extend (':') 
						ui_file.put_line (var_str)
						var_str.wipe_out
						c0 := c
					end
					if not init then
						var_str.append (once "  -- ")
					end
					txt.append_name (var_str)
					if attached {IS_ONCE_CALL} x as oc then 
						if init and then oc.is_function
							and then attached oc.value as ov
						 then
							t := ov.type 
							p := ov.address 
							check p /= default_pointer end 
							p := system.dereferenced (p, t) 
							target.set_field_and_type (ov, ov.type)
							print_variable (var_str, Void, p, t, 0, 0) 
						else 
							target.put_indented (var_str) 
							if oc.is_function and then attached oc.value as ov then 
								var_str.append (once " : ") 
								t := ov.type 
								t.append_name (var_str) 
							end 
							ui_file.put_line (var_str) 
						end 
					elseif attached {IS_UNIQUE} x as u then
						print_constant (u)
					end 
				end
			end
		end
	
	display_aliases (ds: IS_STACK_FRAME) 
		local 
			nm: STRING 
			i, n: INTEGER 
		do 
			strings.wipe_out 
			from
				aliases.start
			until aliases.after loop 
				nm := aliases.key_for_iteration 
				strings.force (nm) 
				aliases.forth 
			end 
			strings.sort 
			from
				n := strings.count
			until i = n loop 
				i := i + 1 
				nm := strings[i] 
				if attached aliases[nm] as ex then
					var_str.wipe_out 
					var_str.extend ('_') 
					var_str.append (nm) 
					if is_alias_manifest (ex) and then attached ex.type as et then 
						print_variable (var_str, Void, ex.address, et, 0, 0) 
					else 
						var_str.extend (' ') 
						var_str.append (alias_separator (ex)) 
						var_str.extend (' ') 
						ex.append_detailed (var_str) 
						ui_file.put_line (var_str) 
					end
				end
			end 
		end 
	 
	display_all_processors (frame: IS_STACK_FRAME) 
		local 
			p: DG_PROCESSOR 
			ds: IS_STACK_FRAME 
			status_names: ARRAY[STRING] 
			l1, l2, max_id: INTEGER 
			ident_width, state_width, creator_width, pos_width: INTEGER 
		do 
			status_names := p.status_names 
			from
				p := p.next
			until not p.exists loop 
				if attached p.creator (system) as c then 
					tmp_str1.wipe_out 
					c.append_name (tmp_str1) 
					creator_width := creator_width.max (tmp_str1.count) 
					state_width := state_width.max (status_names[p.status].count) 
					max_id := max_id.max (p.ident) 
				end 
				p := p.next 
			end 
			tmp_str1.wipe_out 
			multiple_extend (tmp_str1, ' ', 3) 
			tmp_str2.wipe_out 
			tmp_str2.append_integer (max_id) 
			l2 := tmp_str2.count 
			tmp_str2.wipe_out 
			tmp_str2.append (once "Id") 
			l1 := tmp_str2.count 
			ident_width := l1.max (l2) 
			tmp_str1.append (tmp_str2) 
			multiple_extend (tmp_str1, ' ', ident_width - l1) 
			tmp_str1.extend (' ') 
			tmp_str2.wipe_out 
			tmp_str2.append (once "State") 
			l1 := tmp_str2.count 
			state_width := state_width.max (l1) 
			tmp_str1.append (tmp_str2) 
			multiple_extend (tmp_str1, ' ', state_width - l1) 
			tmp_str1.extend (' ') 
			tmp_str2.wipe_out 
			tmp_str2.append (once "Home") 
			l1 := tmp_str2.count 
			creator_width := creator_width.max (l1) 
			tmp_str1.append (tmp_str2) 
			multiple_extend (tmp_str1, ' ', creator_width - l1) 
			tmp_str1.extend (' ') 
			tmp_str2.wipe_out 
			tmp_str2.append (once "CLASS.routine:line") 
			l1 := tmp_str2.count 
			pos_width := tmp_str2.count 
			tmp_str1.append ( tmp_str2) 
			ui_file.put_line (tmp_str1) 
			tmp_str1.wipe_out 
			l2 := 3 + ident_width + 1 + state_width + 1 + creator_width + 1 + pos_width 
			multiple_extend (tmp_str1, '-', l2.max (l2)) 
			ui_file.put_line (tmp_str1) 
			from
				p := p.next
			until not p.exists loop 
				tmp_str1.wipe_out 
				max_id := max_id.max (p.ident) 
				if p.is_equal (actual_proc) then 
					tmp_str1.extend ('*') 
				else 
					tmp_str1.extend (' ') 
				end 
				if p.is_equal (broken_proc) then 
					tmp_str1.extend ('#') 
				else 
					tmp_str1.extend (' ') 
				end 
				tmp_str1.extend (' ') 
				append_sized_int (tmp_str1, p.ident, ident_width) 
				tmp_str2.copy (status_names[p.status]) 
				multiple_extend (tmp_str2, ' ', state_width-tmp_str2.count) 
				tmp_str1.extend (' ') 
				tmp_str1.append (tmp_str2) 
				tmp_str1.extend (' ') 
				if attached p.creator (system) as c then 
					tmp_str2.wipe_out 
					c.append_name (tmp_str2) 
					l2 := tmp_str2.count 
					tmp_str1.append (tmp_str2) 
				else 
					l2 := 0 
				end 
				multiple_extend (tmp_str1, ' ', creator_width - l2) 
				tmp_str1.extend (' ') 
				if p.is_equal (broken_proc) then 
					ds := frame 
				else 
					ds := p.top_frame 
				end 
				if p.status /= p.Idle then 
					ds.routine.text.append_name (tmp_str1) 
					tmp_str1.extend ('.') 
					ds.routine.append_name (tmp_str1) 
					tmp_str1.extend (':') 
					tmp_str1.append_integer (ds.line) 
				end 
				ui_file.put_line (tmp_str1) 
				p := p.next 
			end 
		end 
	 
	display_breakpoint (b: DG_BREAKPOINT) 
		do 
			tmp_str1.wipe_out 
			b.append_out (tmp_str1) 
			ui_file.put_line (tmp_str1) 
		end 
	 
	display_debug_break (enabled: BOOLEAN) 
		do 
			tmp_str1.copy (once "Break at debug clauses ") 
			if enabled then 
				tmp_str1.append (once "enabled.") 
			else 
				tmp_str1.append (once "disabled.") 
			end 
			ui_file.put_line (tmp_str1) 
		end 
	 
	display_markers (list: ARRAYED_LIST[DG_MARK_RESET_COMMAND]) 
		local 
			m: DG_MARK_RESET_COMMAND 
			i, n: INTEGER 
		do 
			from 
				n := list.count 
				i := n 
			until i = 0 loop 
				m := list[i] 
				i := i - 1 
				display_frame (m.saved_frame, i, n, m.line, m.column, False, False) 
			end 
		end 
	 
	display_status_overview (header: STRING; indent_count: INTEGER) 
			-- Display list of status parameter descriptions. 
		require 
			indent_count_not_negative: indent_count >= 0 
    local 
			c: attached like no_command 
      nm: STRING
      i, l, l0, l1, n: INTEGER 
		do 
			ui_file.put_line (header) 
			from
				n := status_commands.count
			until i = n loop 
				i := i + 1 
				c := status_commands[i] 
				nm := c.name 
				l1 := nm.count 
				if attached c.help_arg as ha then 
					l1 := l1 + ha.count + 1 
				end 
				l0 := l0.max (l1) 
			end 
			l0 := l0 + indent_count 
			from
				i := 0
			until i = n loop 
				i := i + 1 
				c := status_commands[i] 
				tmp_str1.wipe_out 
				from
					l := indent_count
				until l = 0 loop 
					tmp_str1.extend (' ') 
					l := l - 1 
				end 
				nm := c.name 
				tmp_str1.append (nm) 
				if attached c.help_arg as ha then 
					tmp_str1.extend (' ') 
					tmp_str1.append (ha) 
				end 
				from
					l := l0 - tmp_str1.count + 2
				until l = 0 loop 
					tmp_str1.extend (' ') 
					l := l - 1 
				end 
				if attached c.help_line as hl then 
					tmp_str1.append (hl) 
				end 
				ui_file.put_line (tmp_str1) 
				l := l + nm.count 
			end 
		end 
	 
	display_gc (mem: detachable MEM_INFO; gc: detachable GC_INFO) 
		local 
			sc, su, st: STRING 
			l, u: INTEGER 
		do 
			if attached gc then 
				u := gc.memory_used 
				if u > 0 then 
					sc := gc.collected.out 
					l := sc.count 
					su := u.out 
					l := l.max (su.count) 
					st := gc.sys_time.out 
					l := l.max (st.count) 
					tmp_str.wipe_out 
					tmp_str.append (once "Bytes collected: ") 
					multiple_extend (tmp_str, ' ', l-sc.count+1) 
					tmp_str.append (sc) 
					tmp_str.append (once "%NBytes still used:") 
					multiple_extend (tmp_str, ' ', l-su.count+1) 
					tmp_str.append (su) 
					tmp_str.append (once "%NCollection time: ") 
					multiple_extend (tmp_str, ' ', l-st.count+1) 
					tmp_str.append (st) 
					tmp_str.append (once " sec") 
					ui_file.put_line (tmp_str) 
				else 
					ui_file.put_line ("Collection info is not available.") 
				end
			end
		end 
	 
feature -- Printing 
 
	bp_indicator (cls: IS_CLASS_TEXT; l: INTEGER): CHARACTER 
		local 
			bp_list: ARRAY[detachable DG_BREAKPOINT] 
			n: INTEGER 
		do 
			bp_list := breakpoints 
			Result := ' ' 
			from
				n := bp_list.lower 
			until Result = '+' or else n > bp_list.upper loop 
				if attached bp_list[n] as bp and then attached bp.range then 
					if bp.match_line (cls, l) then 
						if bp.trace_only then 
							Result := '|' 
						else 
							Result := '+' 
						end 
					end 
				end 
				n := n + 1 
			end 
		end 
 
feature -- PC_DRIVER 
	 
	source: PC_MEMORY_SOURCE 
	
	target: DG_TEXT_TARGET 
	 
	process_basic_field (t: IS_TYPE) 
		local
			ok: BOOLEAN
		do
			ok := (target.format & target.Without_defaults) = 0 
			inspect t.ident 
			when Boolean_ident then 
				source.read_boolean 
				if ok or else source.last_boolean then 
					target.put_boolean (source.last_boolean) 
				end 
			when Character_ident then 
				source.read_character 
				if ok or else source.last_character /= '%U' then 
					target.put_character (source.last_character) 
				end 
			when Char32_ident then 
				source.read_character_32 
				if ok or else source.last_character_32.code /= 0 then 
					target.put_character_32 (source.last_character_32) 
				end 
			when Int8_ident then 
				source.read_integer_8 
				if ok or else source.last_integer /= 0 then 
					target.put_integer (source.last_integer) 
				end 
			when Int16_ident then 
				source.read_integer_16 
				if ok or else source.last_integer /= 0 then 
					target.put_integer (source.last_integer) 
				end 
			when Int32_ident then 
				source.read_integer 
				if ok or else source.last_integer /= 0 then 
					target.put_integer (source.last_integer) 
				end 
			when Int64_ident then 
				source.read_integer_64 
				if ok or else source.last_integer_64 /= 0 then 
					target.put_integer_64 (source.last_integer_64) 
				end 
			when Nat8_ident then 
				source.read_natural_8 
				if ok or else source.last_natural /= 0 then 
					target.put_natural (source.last_natural) 
				end 
			when Nat16_ident then 
				source.read_natural_16 
				if ok or else source.last_natural /= 0 then 
					target.put_natural (source.last_natural) 
				end 
			when Nat32_ident then 
				source.read_natural 
				if ok or else source.last_natural /= 0 then 
					target.put_natural (source.last_natural) 
				end 
			when Nat64_ident then 
				source.read_natural_64 
				if ok or else source.last_natural_64 /= 0 then 
					target.put_natural_64 (source.last_natural_64) 
				end 
			when Real32_ident then 
				source.read_real 
				if ok or else source.last_real /= 0 then 
					target.put_real (source.last_real) 
				end 
			when Real64_ident then 
				source.read_double 
				if ok or else source.last_double /= 0. then 
					target.put_double (source.last_double) 
				end 
			when Pointer_ident then 
				source.read_pointer 
				if ok or else source.last_pointer /= default_pointer then 
					target.put_pointer (source.last_pointer) 
				end 
			else 
			end 
		end 
 
feature -- PC_TEXT_TARGET 
 
	clear_closure 
		local 
			src: like source 
			tgt: like target 
		do 
			source.reset 
			src := source 
			tgt := target 
			reset_driver 
			source := src 
			target := tgt 
			target.reset (True)
			closure_roots.wipe_out 
		end 
 
feature {NONE} -- Implementation 
	 
	system: IS_RUNTIME_SYSTEM 

	names: IS_SEQUENCE[DG_EXPRESSION] 

	strings: SORTED_TWO_WAY_LIST[STRING] 
	 
	tmp_str1: STRING = 
		"........................................................................" 
 
	tmp_str2: STRING = 
		"........................................................................" 
 
	tmp_str3: STRING = 
		"........................................................................" 
 
	var_str: STRING = 
		"........................................................................" 
 
	display_exception_name (reason, errno: INTEGER; head: STRING) 
		require 
			positive: reason > 0 
		local
			cs: C_STRING
			n: INTEGER 
		do 
			tmp_str2.copy (head) 
			from
				n := parser.catch_keys.count
			until n = 0 loop 
				if attached {like no_command} parser.catch_keys [n] as key
					and then key.code = reason
				 then
					if attached key.help_line as h then
						tmp_str2.append (h)
					else
						tmp_str2.append (key.name)
					end
					n := 0
				else
					n := n - 1 
				end 
			end 
			if reason = Operating_system_exception and then errno /= 0 then 
				create cs.make (tmp_str2) 
				c_print_errno (errno, cs.item) 
			else 
				inspect reason
				when Developer_exception then 
					tmp_str2.extend (' ') 
					tmp_str2.extend ('"') 
					if attached developer_exception_name as den then 
						tmp_str2.append (den) 
					end 
					tmp_str2.extend ('"')
				when Eiffel_runtime_panic then
					tmp_str2.append (once ", formal type-id = ")
					tmp_str2.append_integer (c_catcall_target)
					tmp_str2.append (once ", actual type-id = ")
					tmp_str2.append_integer (c_catcall_source)
				else 
				end 
				ui_file.put_line (tmp_str2) 
			end 
		end 
	 
	format_function_call (rd: IS_ROUTINE; s: STRING) 
		require 
			s_not_tmp_str: s /= tmp_str2 
		local 
			i, k, l, m, n: INTEGER 
		do 
			rd.append_name (s) 
			n := rd.argument_count 
			tmp_str2.wipe_out 
			if rd.is_function and then attached rd.type as rt then 
				tmp_str2.append (once ": ") 
				rt.append_name (tmp_str2) 
			end 
			k := tmp_str2.count 
			if n > 1 then 
				s.extend (' ') 
				s.extend ('(') 
				from
					i := 1
				until i = n loop 
					if i > 1 then 
						s.extend (',') 
						s.extend (' ') 
					end 
					l := s.count + k + 3* (n-i) 
					m := short_length - l 
					tmp_str3.wipe_out
					if attached rd.arg_at (i) as li then
						li.type.append_name (tmp_str3)
					end
					l := tmp_str3.count 
					if l <= m then 
						s.append (tmp_str3) 
					elseif m > 5 then 
						tmp_str3.keep_head (m - 3) 
						s.append (tmp_str3) 
						s.extend ('.') 
						s.extend ('.') 
						s.extend ('.') 
					else 
						s.extend ('?') 
					end 
					i := i + 1 
				end 
				s.extend (')') 
			end 
			s.append (tmp_str2) 
		end 
	 
	append_sized_int (trgt: STRING; i, s: INTEGER) 
		local 
			k, l: INTEGER 
		do 
			k := trgt.count 
			trgt.append_integer (i) 
			l := trgt.count 
			l := (s-l+k).max (0) + k 
			from
			until k = l loop 
				k := k + 1 
				trgt.insert_character (' ', k) 
			end 
		end 
 
	print_expression_list (ds: IS_STACK_FRAME; root: DG_EXPRESSION; 
		depth, fmt: INTEGER) 
		local 
			ex: detachable DG_EXPRESSION 
			old_indent: INTEGER 
			retried: BOOLEAN 
		do 
			from 
				if not retried then 
					ex := root 
					old_indent := target.indent_size 
				end 
			until not attached ex as e loop 
				if e.entity = details_entity then 
					ex := e.detail 
				end 
				print_deep_expression (ds, e, depth, fmt) 
				ex := e.next 
			end 
		rescue 
			retried := True 
			check attached ex end
			expression_msg (ex, target.indent_size) 
			ex := ex.next 
			target.set_indent_size (old_indent)
			retry 
		end 
 
	print_deep_variable (static: IS_TYPE; depth: INTEGER; top: BOOLEAN) 
		require 
			not_negative: depth >= 0 
		local
			t: detachable IS_TYPE
			f: IS_FIELD
			oc: IS_ONCE_CALL 
			id: NATURAL
			i, n: INTEGER 
			k, l: NATURAL 
			ready, is_ref: BOOLEAN 
		do
			t := static
			is_ref := not t.is_subobject 
			if is_ref then 
				if top then 
					source.read_next_ident 
				else 
					source.read_field_ident 
				end
				target.set_any_to_print (source.last_ident)
				t := source.last_dynamic_type
				if attached target.any_to_print as any then
					if (target.format & target.As_global_definition) /= 0 then 
						system.refresh_initialized_onces (Void)
						if attached system.once_by_address (as_pointer(any)) as ov then 
							target.append_name (True, var_str) 
							oc := ov.call 
							oc.home.append_name (var_str) 
							var_str.extend ('.') 
							oc.append_name (var_str) 
							ui_file.put_line (var_str) 
							ready := True 
						end 
					end
				else
					target.put_known_ident (id, t, static)
					ready := True
				end
			end
			check attached t end
			if ready then
			elseif t.is_basic then 
				process_basic_field (t) 
			elseif attached target.any_to_print as any then
				if t.is_special and then attached {IS_SPECIAL_TYPE} t as sp then 
					l := system.special_capacity (any, sp).to_natural_32 
					source.pre_special (sp, l, any) 
					target.pre_special (sp, l, id)
					t := sp.item_type
					if depth > 0 then 
						from
						until k = l loop 
							source.set_index (sp, k, any) 
							target.set_index (sp, k, id) 
							print_deep_variable (t, depth - 1, False) 
							k := k + 1 
						end 
					end 
					source.post_special (sp, any) 
					target.post_special (sp, id) 
				elseif t.is_agent and then attached {IS_AGENT_TYPE} t as ag then 
					source.pre_object (t, True, any) 
					target.pre_object (t, is_ref, id) 
					if depth > 0 then 
						n := ag.closed_operand_count 
						if n > 0 then 
							source.pre_agent (ag, any) 
							target.pre_agent (ag, id) 
							from
							until i = n loop 
								f := ag.field_at (i)
								source.set_field (f, any) 
								target.set_field (f, id) 
								print_deep_variable (f.type, depth - 1, False) 
								i := i + 1 
							end 
							source.post_agent (ag, id) 
							target.post_agent (ag, id) 
						end 
						if attached ag.last_result as lr then 
							source.set_field (lr, any) 
							target.set_field (lr, id) 
							print_deep_variable (lr.type, depth - 1, False) 
						end 
					end 
					source.post_object (t, any) 
					target.post_object (t, id)
				else 
					source.pre_object (t, is_ref, any) 
					target.pre_object (t, is_ref, id) 
					if t.is_string or else t.is_unicode then 
						ui_file.put_new_line 
					elseif not is_ref or else (depth > 0) then 
						from
							n := t.field_count
						until i = n loop 
							f := t.field_at (i)
							source.set_field (f, any) 
							target.set_field (f, id) 
							print_deep_variable (f.type, (depth-1).max (0), False) 
							i := i + 1 
						end 
					end 
					source.post_object (t, any) 
					target.post_object (t, id)
				end
			end 
		end
	
	field_buffer: IS_SEQUENCE [IS_FIELD]
		once
			create Result
		end

	local_buffer: IS_SEQUENCE [IS_LOCAL]
		once
			create Result
		end

	print_constant (c: IS_CONSTANT[ANY])
		do
			target.set_field_and_type (c, c.type)
			var_str.wipe_out 
			c.append_name (var_str) 
			target.set_top_name (var_str) 
			inspect c.type.ident 
			when Boolean_ident then 
				if attached {IS_CONSTANT[BOOLEAN]} c as bool then 
					target.put_boolean (bool.value) 
				end 
			when Character_ident then 
				if attached {IS_CONSTANT[CHARACTER_8]} c as char8 then 
					target.put_character (char8.value) 
				end 
			when Char32_ident then 
				if attached {IS_CONSTANT[CHARACTER_32]} c as char32 then 
					target.put_character_32 (char32.value) 
				end 
			when Int8_ident, Int16_ident, Int32_ident then 
				if attached {IS_CONSTANT[INTEGER_64]} c as int then 
					target.put_integer (int.value.to_integer_32) 
				end 
			when Int64_ident then 
				if attached {IS_CONSTANT[INTEGER_64]} c as int then 
					target.put_integer_64 (int.value) 
				end 
			when Nat8_ident, Nat16_ident, Nat32_ident then 
				if attached {IS_CONSTANT[NATURAL_64]} c as nat then	 
					target.put_natural (nat.value.to_natural_32) 
				end 
			when Nat64_ident then 
				if attached {IS_CONSTANT[NATURAL_64]} c as nat then	 
					target.put_natural_64 (nat.value) 
				end 
			when Real32_ident then 
				if attached {IS_CONSTANT[REAL_64]} c as r then 
					target.put_real (r.value.truncated_to_real) 
				end 
			when Real64_ident then 
				if attached {IS_CONSTANT[REAL_64]} c as d then 
					target.put_double (d.value) 
				end 
			when String8_ident then 
				if attached {IS_CONSTANT[STRING_8]} c as str8 then
					var_str.wipe_out
					target.append_name (True, var_str)
					target.append_simple_string (str8.value, var_str)
					ui_file.put_string (var_str)
					ui_file.put_new_line
				end 
			when String32_ident then 
				if attached {IS_CONSTANT[STRING_32]} c as str32 then
					var_str.wipe_out
					target.append_name (True, var_str)
					target.append_simple_unicode (str32.value, var_str)
					ui_file.put_string (var_str)
					ui_file.put_new_line
				end 
			else 
			end 
		end
	
	variable_depth: INTEGER 
	short_length: INTEGER
 	 
invariant

note 
	author: "Wolfgang Jansen" 
	date: "$Date$" 
	revision: "$Revision$"	 
 
end
