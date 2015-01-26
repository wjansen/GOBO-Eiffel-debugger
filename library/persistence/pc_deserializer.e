note

	description: "Retrieving the persistence closure of an object."

class PC_DESERIALIZER

inherit

	IS_BASE
		redefine
			default_create,
			out
		end

	PC_BASE
		redefine
			default_create,
			out
		end

	EXCEPTIONS
		undefine
			default_create,
			copy,
			is_equal,
			out
		end

create
	
	default_create

feature {NONE} -- Initialization

	default_create
		do
			use_default_creation := True
			reset
		ensure then
			use_default_creation_set: use_default_creation = True
		end

feature -- Initialization 

	reset
		do
			top_object := Void
			top_type := Void
		ensure
			void_top_object: not attached top_object
		end

feature -- Access 

	top_object: detachable ANY

	comment: detachable STRING
			-- Comment stored with the object. 

	compilation_time: INTEGER_64
			-- Time (in seconds) when the storing system 
			-- has been Eiffel compiled. 

	creation_time: INTEGER_64
			-- Time (in seconds) when the storing system 
			-- has been Eiffel created. 

	store_time: INTEGER_64
			-- Time (in seconds) when storing has started. 

	store_order: INTEGER
			-- Store order: one of `Lifo_flag', `Fifo_lag', `Deep_flag'. 

	is_basic: BOOLEAN
			-- Was the last read persistence closure stred in basic mode?

	indices_mode: INTEGER
			-- Choice of object indices: possible ORing
			-- of `No_consecutive_flag' and `File_position_flag'.
	
	with_onces: BOOLEAN

	use_default_creation: BOOLEAN
			-- Does PC_MEMORY_TARGET use type's `default_create' procedure 
			-- to create new objects? 

	byte_count: INTEGER
			-- Number of bytes read after header info.
	
feature -- Error messages 

	is_ok: BOOLEAN
		note
			return: "Was the store file readable without errors?"
		do
			Result := (missing_types = Void or else missing_types.is_empty)
				and (missing_fields = Void or else missing_fields.is_empty)
				and (inconsistent_fields = Void or else inconsistent_fields.is_empty)
				and (violated_invariants = Void or else violated_invariants.is_empty)
				and has_large_integers
		end
	
	missing_types: detachable HASH_TABLE [IS_TYPE, IS_TYPE]
		note
			return:
			"[
			 Types occuring in the store file
			 but not available in the running system
			 (may be `Void' indicating that there are no missing types).
			 ]"
		do
			if attached indirect_target as it then
				Result := it.missing_types
			end
		end

	missing_fields: detachable HASH_TABLE [IS_TYPE, IS_ENTITY]
		note
			return:
			"[
			 Attributes occuring in the store file
			 but not available in the running system
			 (may be `Void' indicating that there are no missing attributes).
			 ]"
		do
			if attached indirect_target as it then
				Result := it.missing_fields
			end
		end

	inconsistent_fields: detachable HASH_TABLE [IS_TYPE, IS_ENTITY]
		note
			return:
			"[
			 Attributes occuring in both the store file
			 but of not belonging to the typeset of the attribute
			 in the running system
			 (may be `Void' indicating that there are no missing attributes).
			 ]"
		do
			if attached indirect_target as it then
				Result := it.missing_fields
			end
		end

	default_fields: detachable HASH_TABLE [IS_TYPE, IS_ENTITY]
		note
			return:
				"[
				 Attributes in the running system not occuring
				 in the store file (i.e. set to default values).
				 (may be `Void' indicating that there are no default attributes).
				 ]"
		do
			if attached indirect_target as it then
				Result := it.default_fields
			end
		end

	violated_invariants: detachable HASH_TABLE [STRING, STRING]
		note
			return:
				"[
				 Names of classes having a retrieved object
				 violating the class variant (may be `Void' indicating
				 that there are no violated inviarants).
				 ]"
		do
			if attached indirect_target as it then
				Result := it.violated_invariants
			end
		end

	has_large_integers: BOOLEAN
		note
			return: "Does the store file contain a too large integer?"
		do
			if attached indirect_target as it then
				Result := it.large_integer
			end
		end

	has_truncated_real: BOOLEAN
		note
			return: "Does the store file contain a real of too large precision?"
		do
			if attached indirect_target as it then
				Result := it.truncated_real
			end
		end

	has_invalid_utf8_string: BOOLEAN
		note
			return: "Does the store file contain an invalid UTF8 string?"
		do
			if attached indirect_target as it then
				Result := it.not_utf8
			end
		end

feature -- Status setting 

	set_use_default_creation (use: BOOLEAN)
		do
			use_default_creation := use
		ensure
			use_default_creation_set: use_default_creation = use
		end

feature -- Basic operation 

	read (f: IO_MEDIUM)
		note
			action:
				"[
				 Restore persistence closure from `f'
				 and put the object into `top_object'.
				 ]"
		require
			f_is_open: f.exists and f.is_open_read
		local
			src: PC_BASIC_SOURCE
			fast, retried: BOOLEAN
		do
			if not retried then
				reset
				create src.make (Deep_flag)
				src.set_file (f)
				create header.make_from_source (src)
				store_order := header.order
				with_onces := (header.options & Once_observation_flag) /= 0
				byte_count := 0
				is_basic := header.is_basic
				compilation_time := header.compilation_time
				creation_time := header.creation_time
				store_time := header.store_time
				fast := compilation_time.is_equal (runtime_system.compilation_time)
					and then attached runtime_system.root_type as root
					and then root.has_name (header.root_name)
				if is_basic then 
					if not fast then 
						raise_retrieval_exception (store_root_or_time_error)
					end
					read_basic_or_fast (f, store_order, header.options)
				elseif fast then
					read_basic_or_fast (f, store_order, header.options)
				else
					read_general (f, store_order, header.options, header.root_name)
				end
			end
		ensure
			f_is_open: f.is_open_read
		rescue
			retried := True
			retry
		end

feature {NONE} -- Traversal 

	source (mode, order: INTEGER): PC_BASIC_SOURCE
		local
			bs: PC_BASIC_SOURCE
			fs: PC_FAST_STREAM_SOURCE
			ss: PC_STREAM_SOURCE
		do
			inspect mode
			when Basic_store then
				create bs.make (order)
				Result := bs
			when Fast_store then
				create fs.make (order)
				Result := fs
			else
				create ss.make (order)
				Result := ss
			end
		ensure
			has_system: attached Result.system
		end

	target (indirect: BOOLEAN): PC_MEMORY_TARGET
		do
			if indirect then
				create {PC_INDIRECT_MEMORY_TARGET} Result.make (runtime_system, False)
			else
				create Result.make (runtime_system, False)
			end
		end

	any_driver (t: PC_TARGET [detachable ANY]; s: PC_SOURCE [NATURAL];
			order, opts: INTEGER): PC_SERIAL_DRIVER [detachable ANY]
		do
			create Result.make (t, s, order, opts)
		ensure
			is_serial: Result.is_setrial
		end

	integer_driver (t: PC_TARGET [NATURAL]; s: PC_SOURCE [NATURAL];
		order, opts: INTEGER): PC_SERIAL_DRIVER [NATURAL]
		do
			create Result.make (t, s, order, opts)
		ensure
			is_serial: Result.is_setrial
		end

	read_general (f: IO_MEDIUM; order, opts: INTEGER; name: READABLE_STRING_8)
		require
			is_open: f.is_open_read
		local
			dr: like any_driver
			retried: BOOLEAN
		do
			if not retried and then attached {like indirect_target} target (True) as tgt then
				indirect_target := tgt
				tgt.set_actionable (opts & Accept_actionable_flag /= 0)
				tgt.set_use_default_creation (use_default_creation)
				if attached {PC_STREAM_SOURCE} source (General_store, order) as src then
					src.set_file (f)
					src.set_name (name)
					src.read_header
					dr := any_driver (tgt, src, order, opts)
					dr.traverse 
					top_object := dr.target_root_ident
					top_type := dr.root_type
					byte_count := src.byte_count
				end
			end
		ensure
			is_open: f.is_open_read
		rescue
			retried := True
			retry
		end

	read_basic_or_fast (f: IO_MEDIUM; order, opts: INTEGER)
		require
			is_open: f.is_open_read
		local
			src: PC_BASIC_SOURCE
			tgt: PC_MEMORY_TARGET
			dr: like any_driver
			mode: INTEGER
			retried: BOOLEAN
		do
			if not retried then
				if is_basic then
					mode := Basic_store
				else
					mode := Fast_store
				end
				tgt := target (False)
				tgt.set_actionable (opts & Accept_actionable_flag /= 0)
				tgt.set_use_default_creation (False)
				src := source (mode, order)
				src.set_file (f)
				src.set_version (header.major, header.minor)
				src.read_header
				dr := any_driver (tgt, src, order, opts)
				dr.traverse 
				top_object := dr.target_root_ident
				top_type := dr.root_type
				byte_count := src.byte_count
			end
		ensure
			is_open: f.is_open_read
		rescue
			retried := True
			retry
		end

	run (tgt: PC_ABSTRACT_TARGET; mode, order, opts: INTEGER; f: IO_MEDIUM)
		require
			is_open: f.is_open_read
		local
			src: PC_BASIC_SOURCE
			retried: BOOLEAN
		do
			if not retried then
				top_object := Void
				src := source (mode, order)
				tgt.reset
				src.set_file (f)
				src.read_header
				integer_driver.traverse (tgt, src, opts)
			end
		ensure
			is_open: f.is_open_read
		rescue
			retried := True
			retry
		end

feature -- Output 

	out: attached STRING
		do
			create Result.make (0)
			if attached top_type as tt then
				Result.append (once "Top object: ")
				tt.append_name (Result)
				Result.extend ('%N')
			end
			if attached missing_types as mt and then mt.count > 0 then
				Result.append (once "Warning - missing types:%N")
				from
					mt.start
				until mt.after loop
					Result.append (once "	")
					mt.item_for_iteration.append_name (Result)
					Result.extend ('%N')
					mt.forth
				end
			end
			if attached default_fields as df and then df.count > 0 then
				Result.append (once "Error - missing attributes (set to default value):%N")
				from
					df.start
				until df.after loop
					Result.extend ('%T')
					df.item_for_iteration.append_name (Result)
					Result.extend ('.')
					df.key_for_iteration.append_name (Result)
					Result.extend ('%N')
					df.forth
				end
			end
			if attached inconsistent_fields as mf and then mf.count > 0 then
				Result.append (once "Error - non-conforming attributes (set to default value):%N")
				from
					mf.start
				until mf.after loop
					Result.extend ('%T')
					mf.item_for_iteration.append_name (Result)
					Result.extend ('.')
					mf.key_for_iteration.append_name (Result)
					Result.extend ('%N')
					mf.forth
				end
			end
			if attached violated_invariants as vi and then vi.count > 0 then
				Result.append (once "Error - violated invariants:%N")
				from
					vi.start
				until vi.after loop
					Result.append (once "	")
					Result.append (vi.item_for_iteration)
					Result.extend ('%N')
					vi.forth
				end
			end
			if has_large_integers then
				Result.append (once "Error - too large integers or naturals%N")
			end
			if has_truncated_real then
				Result.append (once "Warning - real number precision lost%N")
			end
		end

feature {NONE} -- Implementation 

	Basic_store: INTEGER = 1
	
	General_store: INTEGER = 2
	
	Fast_store: INTEGER = 3

	store_root_or_time_error: STRING = "Wrong root class or compilation time."

	header: PC_HEADER
	
	top_type: detachable IS_TYPE

	indirect_target: detachable PC_INDIRECT_MEMORY_TARGET
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
