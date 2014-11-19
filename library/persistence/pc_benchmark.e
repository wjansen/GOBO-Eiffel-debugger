note

	description:
		"Come benchmark tests to test efficiency of store/retrive operations."

class PC_BENCHMARK

inherit

	IS_BASE
		redefine
			default_create,
			out
		end

feature {NONE} -- Initialization 

	default_create
		do
			filename := "pc"
		end

feature -- Constants 

	All_tests: INTEGER = -1

	Basic: INTEGER = 1

	General: INTEGER = 2

	Fast: INTEGER = 4

	Memory: INTEGER = 8

	Text: INTEGER = 0x10

	Xml: INTEGER = 0x20

	Statistics: INTEGER = 0x40

	Intrinsic_copy: INTEGER = 0x80

	Create_system: INTEGER = 0x10

feature -- Access 

	filename: STRING

	general_store_time, general_load_time, fast_load_time: REAL_64

	basic_store_time, basic_load_time: REAL_64

	text_time, xml_time: REAL_64

	memory_time, copy_time, statistics_time, create_time: REAL_64

	type_count, once_count, object_count, special_count: INTEGER

	memory_size: INTEGER

feature -- Basic operation 

	test (obj: ANY; fn: STRING; tests: INTEGER)
		note
			action:
			"[
			 Test effeciency to store/retrieve `obj'.
			 File extensions added are:
			 ".bs" for `Basic', ".gs" for `General' and `Fast', ".txt" for `Text',
			 and ".xml" for `Xml'.
			 ]"
			fn: "file name (without extension) to use"
			tests:
			"[
			 tests to apply: the ORing of some of
			 `Basic', `General', `Fast', `Memory', `Text', `Xml',
			 `Statistics',`Intrinsic_copy', `Create_system',
			 or simply `All_tests'
			 ]"
		require
			fn_not_empty: fn.is_empty
		do
			filename := fn
			general_store_time := 0.
			general_load_time := 0.
			fast_load_time := 0.
			basic_store_time := 0.
			basic_load_time := 0.
			text_time := 0.
			xml_time := 0.
			memory_time := 0.
			copy_time := 0.
			statistics_time := 0.
			create_time := 0.
			type_count := 0
			once_count := 0
			object_count := 0
			special_count := 0
			memory_size := 0
			if (tests & Create_system) > 0 then
				create_test
			end
			if (tests & General) > 0 then
				load_test
				store_test (obj)
			end
			if (tests & Fast) > 0 then
				fast_load_test
			end
			if (tests & Basic) > 0 then
				basic_store_test (obj)
				basic_load_test
			end
			if (tests & Memory) > 0 then
				memory_test (obj)
			end
			if (tests & Text) > 0 then
				store_text_test (obj)
			end
			if (tests & Xml) > 0 then
				store_xml_test (obj)
			end
			if (tests & Statistics) > 0 then
				statistics_test (obj)
			end
			if (tests & Intrinsic_copy) > 0 then
				copy_test (obj)
			end
		end

feature -- Output 

	out: attached STRING
		do
			create Result.make (100)
			if create_time > 0. then
				Result.append ("System creation time:  ")
				Result.append_real (create_time.truncated_to_real)
				Result.extend ('%N')
			end
			if general_store_time > 0. then
				Result.append ("General store time:    ")
				Result.append_real (general_store_time.truncated_to_real)
				Result.extend ('%N')
			end
			if general_load_time > 0. then
				Result.append ("General retrieve time: ")
				Result.append_real (general_load_time.truncated_to_real)
				Result.extend ('%N')
			end
			if fast_load_time > 0. then
				Result.append ("Fast retrieve time:    ")
				Result.append_real (fast_load_time.truncated_to_real)
				Result.extend ('%N')
			end
			if basic_store_time > 0. then
				Result.append ("Basic store time:      ")
				Result.append_real (basic_store_time.truncated_to_real)
				Result.extend ('%N')
				Result.append ("Basic retrieve time:   ")
				Result.append_real (basic_load_time.truncated_to_real)
				Result.extend ('%N')
			end
			if memory_time > 0. then
				Result.append ("Memory store time:     ")
				Result.append_real (memory_time.truncated_to_real)
				Result.extend ('%N')
			end
			if text_time > 0. then
				Result.append ("Text store time:       ")
				Result.append_real (text_time.truncated_to_real)
				Result.extend ('%N')
			end
			if xml_time > 0. then
				Result.append ("XML store time:        ")
				Result.append_real (xml_time.truncated_to_real)
				Result.extend ('%N')
			end
			if copy_time > 0. then
				Result.append ("Deep_copy time:        ")
				Result.append_real (copy_time.truncated_to_real)
				Result.extend ('%N')
			end
			if object_count > 0 then
				Result.append ("Statistics")
				Result.append ("%N  types:    ")
				Result.append_integer (type_count)
				Result.append ("%N  onces:    ")
				Result.append_integer (once_count)
				Result.append ("%N  objects:  ")
				Result.append_integer (object_count)
				Result.append ("%N  specials: ")
				Result.append_integer (special_count)
				Result.append ("%N  memory:   ")
				Result.append_integer (memory_size)
				Result.extend ('%N')
			end
		end

feature {NONE} -- Implementation 

	basic_store_test (obj: ANY)
		local
			f: RAW_FILE
			s: PC_SERIALIZER
			c: REAL_64
		do
			create f.make_open_write (filename + ".bs")
			create s
			c := c_clock
			s.put_basically (obj, f, Void)
			basic_store_time := (c_clock - c) / c_factor
			f.close
		end

	store_test (obj: ANY)
		local
			f: RAW_FILE
			s: PC_SERIALIZER
			c: REAL_64
		do
			create f.make_open_write (filename + ".gs")
			create s
			c := c_clock
			s.put (obj, f, Void)
			general_store_time := (c_clock - c) / c_factor
			f.close
		end

	store_text_test (obj: ANY)
		local
			f: PLAIN_TEXT_FILE
			s: PC_SERIALIZER
			c: REAL_64
		do
			create f.make_open_write (filename + ".txt")
			create s
			c := c_clock
			s.put_text (obj, f, False)
			text_time := (c_clock - c) / c_factor
			f.close
		end

	store_xml_test (obj: ANY)
		local
			f: PLAIN_TEXT_FILE
			s: PC_SERIALIZER
			c: REAL_64
		do
			create f.make_open_write (filename + ".xml")
			create s
			c := c_clock
			s.put_xml (obj, "top", f, Void)
			xml_time := (c_clock - c) / c_factor
			f.close
		end

	basic_load_test
		local
			f: RAW_FILE
			d: PC_DESERIALIZER
			c: REAL_64
			retried: BOOLEAN
		do
			if not retried then
				create f.make_open_read (filename + ".bs")
				if f.exists then
					create d
					c := c_clock
					d.read (f)
					basic_load_time := (c_clock - c) / c_factor
					f.close
				end
			end
		rescue
			retried := True
			retry
		end

	fast_load_test
		local
			f: RAW_FILE
			d: PC_DESERIALIZER
			c: REAL_64
			retried: BOOLEAN
		do
			if not retried then
				create f.make_open_read (filename + ".gs")
				if f.exists then
					create d
					c := c_clock
					d.read (f)
					fast_load_time := (c_clock - c) / c_factor
					f.close
				end
			end
		rescue
			retried := True
			retry
		end

	load_test
		local
			f: RAW_FILE
			d: PC_DESERIALIZER
			c: REAL_64
			retried: BOOLEAN
		do
			if not retried then
				create f.make_open_read (filename + ".gs")
				if f.exists then
					create d
					c := c_clock
					d.read (f)
					general_load_time := (c_clock - c) / c_factor
					f.close
				end
			end
		rescue
			retried := True
			retry
		end

	memory_test (obj: ANY)
		local
			s: PC_SERIALIZER
			c: REAL_64
		do
			create s
			c := c_clock
			s.put_memory (obj)
			memory_time := (c_clock - c) / c_factor
		end

	statistics_test (obj: ANY)
		local
			s: PC_SERIALIZER
			tgt: PC_STATISTICS_TARGET
		do
			create s
			create tgt.make (True)
			s.pre_serialize (obj, tgt)
			type_count := tgt.type_count
			object_count := tgt.object_count
			special_count := tgt.special_count
			once_count := tgt.once_count
			memory_size := tgt.memory_size
		end

	copy_test (obj: ANY)
		local
			a: detachable ANY
			c: REAL_64
		do
			c := c_clock
			a := obj.deep_twin
			copy_time := (c_clock - c) / c_factor
		end

	create_test
		local
			rts: IS_RUNTIME_SYSTEM
			c: REAL_64
		do
			c := c_clock
			rts := runtime_system
			create_time := (c_clock - c) / c_factor
			if create_time < 0.1 then
				c := c_clock
				create rts.make_from_c
				create_time := (c_clock - c) / c_factor
			end
		end

feature {NONE} -- External implemetation 

	c_clock: REAL_64
		external
			"C inline use <time.h>"
		alias
			"(EIF_REAL_64)clock()"
		end

	c_factor: REAL_64
		external
			"C inline use <time.h>"
		alias
			"(EIF_REAL_64)CLOCKS_PER_SEC"
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
