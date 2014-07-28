note
	
	description: ""

class PC_SELECT_DRIVER 

inherit

	PC_SERIAL_DRIVER [NATURAL]
		rename
			make as make_driver
		redefine
			source,
			target,
			process_announcement,
			process_data
		end
	
	KL_COMPARATOR [TUPLE [values: ARRAY[PC_TOOL_VALUE]; row: ARRAY[STRING]]]
		undefine
			default_create,
			copy,
			is_equal,
			out
		redefine
			less_than
		end

	EXCEPTIONS
		undefine
			default_create,
			copy,
			is_equal,
			out
		end
	
create

	make

feature {} -- Initialization

	make (src: like source; sel: like selection)
		local
			ex: PC_TOOL_FIELD
			h: PC_TOOL_VALUE
			sh: like heads
			lv, rv: PC_TOOL_VALUE
			i, l, n: INTEGER
		do
			create lv
			create rv
			create less_operator.make ({PC_TOOL_OPERATOR}.lt_op, lv, rv)
			create equal_operator.make ({PC_TOOL_OPERATOR}.eq_op, lv, rv)
			create heads.make (4)
			create columns.make (10)
			source := src
			create target.make

			selection := sel
			where := sel.where
			top_type := source.type_at (sel.type)
			create ex.make_qualified (Void, "id")
			heads.wipe_out
			heads.extend (ex)
			from
				sh := sel.heads
				sh.start
			until sh.after loop
				h := sh.item_for_iteration
				if h.head_name.is_equal ({PC_TOOL_PARSER}.all_name) then
					all_heads 
				else
					heads.extend (h)
				end
				sh.forth
			end
			n := heads.count
			create column_widths.make (0, n - 1)
			from
				i := n
			until i = 0 loop
				h := heads [i]
				if attached h.head_name as nm then
					l := nm.count
				else
					l := h.value_string.count
				end
				i := i - 1
				column_widths.put (l, i)
			end
			if attached sel.sort as ss then
				order := ss.twin
			else
				create order.make (1)
			end
			order.extend (0)
			make_driver (target, src, 0)
		end

	all_heads 
		local
			ex: PC_TOOL_FIELD
			f: IS_FIELD
			i, n: INTEGER
		do
			if attached {IS_NORMAL_TYPE} top_type as nt then
				from
					n := nt.field_count
				until i = n loop
					f := nt.field_at (i)
					create {PC_TOOL_FIELD} ex.make_qualified (Void, f.name)
					heads.extend (ex)
					i := i + 1
				end
			elseif attached {IS_TUPLE_TYPE} top_type as tt then
				from
					n := tt.field_count
				until i = n loop
					f := tt.field_at (i)
					f.set_offset (i)
					create {PC_TOOL_FIELD} ex.make_qualified (Void, f.name)
					heads.extend (ex)
					i := i + 1
				end
			end
		end
	
feature -- Access 
	
	source: PC_POSITIONED_STREAM_SOURCE

	target: PC_SELECT_TARGET

	selection: TUPLE [heads: ARRAYED_LIST [PC_TOOL_VALUE];
                          type: INTEGER;
                          where: PC_TOOL_VALUE;
                          sort: ARRAYED_LIST [INTEGER]]
													
	top_type: IS_TYPE
	
	top_ident: NATURAL
	
	heads: ARRAYED_LIST [PC_TOOL_VALUE]

	columns: DS_ARRAYED_LIST [like sortable_row]

	column_widths: ARRAY [INTEGER]
	
feature -- Basic operation

	item (id: NATURAL; obj: NATURAL)
		local
			ex, val: PC_TOOL_VALUE
			sort: ARRAY[PC_TOOL_VALUE]
			row: ARRAY[STRING]
			str: STRING
			i, n, l, ls: INTEGER
			ok: BOOLEAN
		do
			top_ident := id
			if source.types [obj] = top_type then
				move_to (id)
				ex := where
				if attached ex then 
					ex.evaluate (obj, Current)
					if not ex.is_boolean then
						raise ("")
					end
					ok := ex.boolean_value
				else
					ok := True
				end
				if ok then
					n := heads.count
					create row.make (0, n - 1)
					create sort.make (0, n - 1)
					from
						i := 0
					until i = n loop
						ex := heads [i + 1]
						val := ex.twin
						if i = 0 then
							val.set_ident (id, source.types [id].ident)
						else
							val.evaluate (obj, Current)
						end
						str := val.value_string
						row.force (str, i)
						l := column_widths [i]
						ls := str.count
						if ls > l then
							column_widths [i] := ls
						end
						sort.force (val, i)
						i := i + 1
					end
					columns.force_last ([sort,row])
				end
				move_to (id)
			end
		end
	
	finish
		local
			sorter: DS_BUBBLE_SORTER [like sortable_row]
		do
			if attached selection.sort as sel then
				create sorter.make (Current)
				sorter.sort (columns)
			end
		end

	move_to (id: NATURAL)
		local
			tid: PC_TYPED_IDENT[NATURAL]
			t: IS_TYPE
			ti: NATURAL
			i: INTEGER
		do
			i := id.to_integer_32
			if known_objects.has (id) then
				tid := known_objects [id]
				ti := tid.ident
				if not attached target.values [ti] then
					ti := 0
				end
			end
			if ti = 0 then
				t := source.types [id]
				process_announcement (id)
				ti := target.last_ident
				if t.is_special and then attached {IS_SPECIAL_TYPE} t as s then
					process_special (s, source.capacities [id], id, ti, False)
				else
					process_normal_or_tuple (t, id, ti, False)
				end
			end
		end

	get_field_value (f: IS_FIELD; in: NATURAL): PC_TOOL_VALUE
		local
			vals: ARRAY [PC_TOOL_VALUE]
		do
			vals := target.values [in]
			Result := vals [f.offset]
		end
	
feature {} -- Scanning structures 

	process_announcement (si: NATURAL)
		local
			tid: PC_TYPED_IDENT [NATURAL]
		do
			if attached source.types [si] as t then
				target.set_next_ident (si)
				if attached {IS_SPECIAL_TYPE} t as s then
					target.put_new_special (s, 0, 0)
				else
					target.put_new_object (t)
				end
				tid.make (si, t, 0)
				known_objects [si] := tid
			end
		end

	process_data (si: NATURAL)
		do
			dynamic_type := source.last_dynamic_type
			capacity := source.last_capacity
			if attached dynamic_type as t
				and then attached known_objects [si] as ti
			 then
				if not deep then
					target.put_next_ident (ti)
				end
				if t.is_special and then attached {IS_SPECIAL_TYPE} t as s then
					process_special (s, capacity, si, ti)
				elseif t.is_agent and then attached {IS_AGENT_TYPE} t as a then
					process_agent (a, si, ti)
				else
					process_normal_or_tuple (t, True, si, ti)
				end
			end
		end

feature {} -- Implementation

	where: PC_TOOL_VALUE
		
	order: ARRAYED_LIST[INTEGER]
	
	less_operator, equal_operator: PC_TOOL_OPERATOR

	sortable_row: TUPLE [value: ARRAY[PC_TOOL_VALUE]; row: ARRAY[STRING]]
	
	less_than (u, v: like sortable_row): BOOLEAN
		local
			ui, vi: PC_TOOL_VALUE
			i, n, idx: INTEGER
		do
			from
				n := order.count
			until Result or else i = n loop
				i := i + 1
				idx := order [i]
				if idx < 0 then
					idx := idx.abs
					vi := u.value [idx]
					ui := v.value [idx]
				else
					ui := u.value [idx]
					vi := v.value [idx]
				end
				less_operator.evaluate_for_operands (ui, vi)
				Result := less_operator.boolean_value 
				if not Result and then i < n then
					equal_operator.evaluate_for_operands (ui, vi)
					if not equal_operator.boolean_value then
						i := n
					end
				end
			end
		end

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
