note

	description: "Driver of Mark/Reset commands."

class DG_PERSISTENCE [TI_, SI_ -> attached ANY]

inherit

	PC_LAZY_DRIVER [TI_, SI_]
		redefine
			source,
			target
		end

create

	make

feature -- Access 

	source: DG_MS_SOURCE [SI_]

	target: DG_MS_TARGET [TI_]

feature -- Basic operation 

	traverse_stack (t: like target; s: like source; onces: IS_ARRAY [IS_ONCE_CALL])
		do
			source := s
			target := t
			flags := Deep_flag
			deep := True
			scan_stack
			scan_onces (onces)
		end

	scan_stack
		local
			i, n: INTEGER
			b: BOOLEAN
		do
			source.read_routine
			if attached source.last_routine as r then
				target.pre_routine (r)
				from
					n := r.argument_count + r.local_count + r.old_value_count
				until i = n loop
					if attached r.var_at (i) as l then
						source.set_local (l)
						target.set_local (l)
						process_entity (l)
					end
					i := i + 1
				end
				from
					n := n + r.scope_var_count
				until i = n loop
					if attached r.var_at (i) as l then
						source.set_local (l)
						target.set_local (l)
						source.read_scope_var
						b := source.last_scope_var
						target.put_scope_var (b)
						if b then
							process_entity (l)
						end
					end
					i := i + 1
				end
				target.post_routine (r)
			end
		end

	scan_onces (onces: IS_ARRAY [IS_ONCE_CALL])
		local
			o: IS_ONCE_CALL
			i: INTEGER
			init: BOOLEAN
		do
			from
				i := onces.count
			until i = 0 loop
				i := i - 1
				o := onces [i]
				if attached o.value as v then
					source.set_once (o)
					init := source.last_once_init
					target.set_once (o, init)
					if init then
						process_entity (v)
					end
				end
			end
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
