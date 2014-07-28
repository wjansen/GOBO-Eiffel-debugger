note

	description:

		"Formatting of an entry in the persistence closure."

deferred class PC_QUALIFIER_TARGET 

inherit

	PC_ABSTRACT_TARGET 
		redefine
			default_create,
			reset,
--			pre_object,
--			pre_special,
			put_new_object,
			put_new_special,
			put_known_ident,
			set_field,
			set_index
		end

feature {} -- Initialization 

	default_create
		do
			create items.make (100)
			create depths.make (100)
			create path.make (20)
		end

feature -- Initialization 

	reset
		do
			items.wipe_out
			depths.wipe_out
			actual_ident := void_ident
			top_ident := void_ident
		end

feature -- Basic operation 

	append_qualified_name (searched: NATURAL; to: STRING; typed, init_ident: BOOLEAN)
		local
			what: like no_item
			e, p: detachable like field
			t: detachable IS_TYPE
			s: detachable IS_SPECIAL_TYPE
			id: NATURAL
			i, n: INTEGER
			cont: BOOLEAN
		do
			from
				id := searched
				path.wipe_out
			until id = void_ident loop
				what := items [id]
				path.put_front (what)
				id := what.parent
			end
			from
				n := path.count
			until i = n loop
				i := i + 1
				what := path [i]
				e := what.f
				if attached e as f then
					t := f.type
				else
					t := Void
				end
				t := what.dyn
				check attached t end
				if cont then
					if typed then
						to.extend ('%N')
						to.extend ('_')
						if i < n then
							to.append_natural_32 (path[i+1].parent)
						else
							to.append_natural_32 (searched)
						end
						to.extend('%T')
					end
					if not attached s and then attached e as e_ then
						to.extend ('.')
						if attached p as p_ and then attached p_.text as pt
							and then attached pt.tuple_labels
						 then
							pt.append_label (e_.name, to)
						else
							e_.append_name (to)
						end
					else
						to.extend ('[')
						to.append_integer (what.idx)
						to.extend (']')
					end
				elseif init_ident then
					to.extend('_')
					to.append_natural_32 (top_ident)
				end
				if t.is_special and then attached {IS_SPECIAL_TYPE} t as spec then
					s := spec
				else
					s := Void
				end
				if typed then
					to.append (once " : ")
					if attached s as sp then
						sp.item_type.append_name (to)
						to.extend (' ')
						to.extend ('[')
						to.append_integer (what.idx)
						to.extend (']')
					else
						t.append_name (to)
					end
				end
				p := e
				cont := True
			end
		end

feature {PC_DRIVER} -- Push and pop data 

	pre_object0 (t: IS_TYPE; id: attached NATURAL)
		do
			if id /= void_ident then
				actual_ident := id
			end
		end

	pre_special0 (s: IS_SPECIAL_TYPE; cap: NATURAL; id: attached NATURAL)
		do
			actual_ident := id
		end

feature {PC_DRIVER} -- Writing elementary data

	put_known_ident (id: detachable NATURAL; t: IS_TYPE)
		local
			item: like no_item
			d: INTEGER
		do
			if attached actual_ident as act then
				d := depths[act] + 1
				if depths [id] > d then
					item := items [id]
					item.parent := act
					depths.force (d, id)
				end
			end
		end

	put_new_object (t: IS_TYPE)
		do
			items.force ([actual_ident, t, field, index], last_ident)
			depths.force (depths [actual_ident] + 1, last_ident)
		end

	put_new_special (st: IS_SPECIAL_TYPE; cap: NATURAL; id: NATURAL)
		do
			items.force ([actual_ident, st, field, cap.to_integer_32], last_ident)
			depths.force (depths [actual_ident] + 1, last_ident)
		end

feature {PC_DRIVER} -- Object location

	set_field (f: like field; in: NATURAL)
		do
			Precursor (f, in)
			actual_ident := in
		end

	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: NATURAL)
		do
			Precursor (s, i, in)
			actual_ident := in
		end
	
feature {} -- Implementation 

	actual_ident: NATURAL

	items: HASH_TABLE [like no_item, NATURAL]

	depths: HASH_TABLE [INTEGER, NATURAL]
	
	path: ARRAYED_LIST [like no_item]
	
	no_item: TUPLE [parent: NATURAL; dyn: IS_TYPE; f: detachable like field; idx: INTEGER]
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
