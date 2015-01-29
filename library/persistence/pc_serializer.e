note

	description:
		"[ 
		 Storing the persistence closure of one	object in binary format 
		 or in a client specific format. 
		 ]"

class PC_SERIALIZER

inherit

	IS_BASE
		redefine
			default_create
		end
	
	PC_SERIAL_BASE
		redefine
			default_create
		end

feature {NONE} -- Initialization
	
	default_create
		do
			options := Fifo_flag | Accept_actionable_flag
		end
		
feature -- Access 

	options: INTEGER
			-- Set of processing options combined by `|'. 
			-- `Result<0' means all default behaviour:
			-- `Fifo_flag | Accept_actionable_flag' 
	
	copied_object: detachable ANY
			-- Result of `put_memory'. 

	byte_count: INTEGER
			-- Number of bytes written after header info (if written to a file). 
	
feature -- Status setting 

	set_options (opts: like options)
		note
			action: "Set the processing options, `<0' means default behaviour."
		do
			options := opts
		ensure
			options_set: options = opts
		end

feature -- Basic operation 

	put (obj: detachable ANY; f: IO_MEDIUM; c: detachable READABLE_STRING_8)
		note
			action:
				"[
				 Store the persistence closure of `obj' in binary format.
				 The comment `c' is stored too and may be used
				 to identify several persistence closures.
				 ]"
			f: "file to write"
		require
			is_open: f.is_open_write
		local
			tgt: PC_STREAM_TARGET
			opts: INTEGER
		do
			create tgt.make (runtime_system)
			tgt.set_file (f)
			opts := actual_options & Basic_flag.bit_not
			serialize_by_order (obj, tgt, actual_order, opts, c)
			byte_count := tgt.byte_count
		end

	put_basically (obj: detachable ANY; f: IO_MEDIUM; c: detachable READABLE_STRING_8)
		note
			action:
				"[
				 Store the persistence closure of `obj' tin binary format.
				 The comment `c' is stored too and may be used
				 to identify several persistence closures.
				 Caution:
				 Type information is not stored implying that the object
				 can be retrieved only by the storing system.
				 ]"
			f: "file to write"
		require
			is_open: f.is_open_write
		local
			tgt: PC_BASIC_TARGET
			opts: INTEGER
		do
			create tgt
			tgt.set_file (f)
			opts := actual_options | Basic_flag
			serialize_by_order (obj, tgt, actual_order, opts, c)
			byte_count := tgt.byte_count
		end

	put_text (obj: detachable ANY; f: detachable PLAIN_TEXT_FILE; deep: BOOLEAN)
		note
			action:
				"[
				 Print persistence closure of `obj' 
				 Apply deep traversal if `deep',
				 otherwise flat traversal in pre-order.
				 ]"
			f: "file to write, if `Void' then `io.output'"
		require
			is_open: attached f as ff implies ff.is_open_write
		local
			tgt: PC_TEXT_TARGET
			ord: INTEGER
		do
			if deep then
				ord := Deep_flag
			else
				ord := Fifo_flag
			end
			if attached f as ff then
				create tgt.make (ff, runtime_system)
			else
				create tgt.make (io.output, runtime_system)
			end
			tgt.set_flat (not deep)
			serialize_by_order (obj, tgt, ord, actual_options, Void)
			byte_count := 0
		end

	put_xml (obj: detachable ANY; nm: STRING; f: PLAIN_TEXT_FILE;
					 c: detachable READABLE_STRING_8)
		note
			action:
				"[
				 Store the persistence closure of `obj' in XML format.
				 The comment `c' is stored too and may be used
				 to identify several persistence closures.
				 ]"
			nm: "name of top object"
			f: "file to write"
		require
			is_open: f.is_open_write
		local
			xt: PC_XML_TARGET
		do
			create xt.make (f, c, nm, runtime_system)
			serialize_by_order (obj, xt, Forward_flag, actual_options, c)
			byte_count := 0
		end

	put_memory (obj: detachable ANY)
		note
			action:
				"[
				 Put persistence closure of `obj' into `copied_object',
				 ignore any options.
				 ]"
		local
			src: PC_MEMORY_SOURCE
			driver: PC_RANDOM_ACCESS_DRIVER [detachable ANY, ANY]
			oo: PC_ANY_TABLE [PC_TYPED_IDENT [detachable ANY]]
			tgt: PC_MEMORY_TARGET
		do
			create src.make (runtime_system)
			src.set_actionable (False)
			src.set_ident (obj)
			create oo.make (100)
			create tgt.make (runtime_system, False)
			create driver.make (tgt, src, Deep_flag, 0, oo)
			driver.traverse (obj)
			copied_object := driver.target_root_ident
			byte_count := 0
		end

	serialize (obj: detachable ANY; target: PC_ABSTRACT_TARGET)
		note
			action:
				"[
				 Deep traversal of `obj', 
				 ignore `Accept_actionable_flag'.
				 ]"
			target: "target to use"
		local
			opts: INTEGER
		do
			opts := actual_options & Accept_actionable_flag.bit_not
			serialize_by_order (obj, target, Deep_flag, opts, Void)
		end

	pre_serialize (obj: detachable ANY; target: PC_ABSTRACT_TARGET)
		note
			action:
				"[
				 Traversal of `obj' in pre-processing order,
				 ignore `Accept_actionable_flag'.
				 ]"
			target: "target to use"
		local
			opts: INTEGER
		do
			opts := actual_options & Accept_actionable_flag.bit_not
			serialize_by_order (obj, target, Fifo_flag, opts, Void)
		end

	post_serialize (obj: detachable ANY; target: PC_ABSTRACT_TARGET)
		note
			action:
				"[
				 Traversal of `obj' in post-processing order,
				 ignore `Accept_actionable_flag'.
				 ]"
			target: "target to use"
		local
			opts: INTEGER
		do
			opts := actual_options & Accept_actionable_flag.bit_not
			serialize_by_order (obj, target, Forward_flag, opts, Void)
		end

feature {NONE} -- Implementation 

	actual_order: INTEGER
		do
			if options < 0 then
				Result := Lifo_flag 
			else
				Result := options & Order_flag
			end
		end
	
	actual_options: INTEGER
		do
			if options < 0 then
				Result := Accept_actionable_flag
			else
				Result := options & Order_flag.bit_not
			end
		end
	
	serialize_by_order (obj: detachable ANY; target: PC_ABSTRACT_TARGET;
											ord, opts: INTEGER;
											comment: detachable READABLE_STRING_8)
		require
			valid_order: ord = Deep_flag or ord = Fifo_flag or ord = Lifo_flag or ord = Forward_flag
		local
			oo: PC_ANY_TABLE [PC_TYPED_IDENT [NATURAL]]
			src: PC_MEMORY_SOURCE
			driver: PC_RANDOM_ACCESS_DRIVER [NATURAL, ANY]
			h: PC_HEADER
			a: ANY
		do
			create oo.make (997)
			create {PC_MEMORY_SOURCE} src.make (runtime_system)
			src.set_actionable (opts & Accept_actionable_flag /= 0)
			if attached {PC_BASIC_TARGET} target as bin then
				create h.make_for_target (src.system.root_type.name, src.system,
																	comment, ord, opts)
				h.put (bin)
				bin.write_header (src.system)
			end
			if ord & Forward_flag = Forward_flag then
				create {PC_FORWARD_DRIVER [NATURAL, ANY]}
					driver.make (target, src, oo)
			else
				create {PC_RANDOM_ACCESS_DRIVER [NATURAL, ANY]}
					driver.make (target, src, ord, opts, oo)
			end
			driver.traverse (obj)
			if attached {PC_BASIC_TARGET} target as tgt then
				byte_count := tgt.byte_count
			else
				byte_count := 0
			end
			-- Add typeset of `obj' stored object to `common' for retrival:
			a := common (obj)
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
