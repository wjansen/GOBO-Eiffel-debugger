indexing

	description:

		"Test XPath Cast Expressions and type constructors"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2001, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XPATH_TEST_CAST_EXPRESSION

inherit

	TS_TEST_CASE
		redefine
			set_up
		end

	XM_XPATH_TYPE
	
	XM_XPATH_ERROR_TYPES

	XM_XPATH_SHARED_CONFORMANCE

	KL_IMPORTED_STRING_ROUTINES

	KL_SHARED_STANDARD_FILES

feature -- Tests

	test_untyped_atomic_to_untyped_atomic is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xdt:untypedAtomic.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic ('fred') cast as xdt:untypedAtomic")
--			diagnose_evaluation_error (an_evaluator)
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			assert ("String value", STRING_.same_string (evaluated_items.item (1).string_value, "fred"))
		end

	test_untyped_atomic_to_string is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:string.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic ('fred') cast as xs:string")
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			assert ("String value", STRING_.same_string (evaluated_items.item (1).string_value, "fred"))
		end

	test_untyped_atomic_to_any_uri is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:anyURI
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic ('fred') cast as xs:anyURI")
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			assert ("String value", STRING_.same_string (evaluated_items.item (1).string_value, "fred"))
		end

	test_untyped_atomic_to_notation is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:NOTATION.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic ('fred') cast as xs:NOTATION")
			-- xs:NOTATION not supported by basic-level processor
			assert ("Evaluation error", an_evaluator.is_error) 
		end

	test_untyped_atomic_to_float is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:float.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic ('fred') cast as xs:float")
			-- xs:float not supported by basic-level processor
			assert ("Evaluation error", an_evaluator.is_error)
		end

	test_untyped_atomic_to_double_unsucessful is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:double, with invalid value.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic ('fred') cast as xs:double")
			assert ("Evaluation error", an_evaluator.is_error and then an_evaluator.error_value.type = Dynamic_error and an_evaluator.error_value.code = 21)
		end

	test_untyped_atomic_to_double is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:double.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
			a_double_value: XM_XPATH_DOUBLE_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic (' 17.5E-12') cast as xs:double")
			assert ("No valuation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			a_double_value ?= evaluated_items.item (1)
			assert ("Correct value", a_double_value /= Void and then a_double_value.value = 17.5E-12)
		end	

	test_untyped_atomic_to_decimal_unsucessful is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:decimal, with invalid value.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic ('fred') cast as xs:decimal")
			assert ("Evaluation error", an_evaluator.is_error and then an_evaluator.error_value.type = Dynamic_error and an_evaluator.error_value.code = 21)
		end

	test_untyped_atomic_to_decimal is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:decimal
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
			a_decimal_value: XM_XPATH_DECIMAL_VALUE
			a_decimal: MA_DECIMAL
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic (' 256.7198003 ') cast as xs:decimal")
			assert ("No valuation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			create a_decimal.make_from_string ("256.7198003")
			a_decimal_value ?= evaluated_items.item (1)
			assert ("Correct value", a_decimal_value /= Void and then a_decimal_value.value.is_equal (a_decimal))
		end
	
	test_untyped_atomic_to_integer_unsucessful is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:integer, with invalid value.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic ('fred') cast as xs:integer")
			assert ("Evaluation error", an_evaluator.is_error and then an_evaluator.error_value.type = Dynamic_error and an_evaluator.error_value.code = 21)
		end

	test_untyped_atomic_to_integer is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:integer
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
			an_integer_value: XM_XPATH_INTEGER_VALUE
			an_integer: MA_DECIMAL
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic (' 56 ') cast as xs:integer")
			assert ("No valuation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			an_integer_value ?= evaluated_items.item (1)
			create an_integer.make_from_integer (56)
			assert ("Correct value", an_integer_value /= Void and then an_integer_value.value.is_equal (an_integer))
		end

	test_untyped_atomic_to_boolean_unsucessful is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:boolean, with invalid value.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic ('fred') cast as xs:boolean")
			assert ("Evaluation error", an_evaluator.is_error and then an_evaluator.error_value.type = Dynamic_error and an_evaluator.error_value.code = 21)
		end

	test_untyped_atomic_to_boolean is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:boolean.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
			a_boolean_value: XM_XPATH_BOOLEAN_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic (' true ') cast as xs:boolean")
			assert ("No valuation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			a_boolean_value ?= evaluated_items.item (1)
			assert ("Correct value", a_boolean_value /= Void and then a_boolean_value.value)
		end	

	test_untyped_atomic_to_qname_unsucessful is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:QName, with invalid value.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic ('xs:b:fred') cast as xs:QName")
			assert ("Evaluation error", an_evaluator.is_error and then an_evaluator.error_value.type = Dynamic_error and an_evaluator.error_value.code = 1)
		end

	test_untyped_atomic_to_qname is
			-- Test creating an xdt:untypedAtomic from a string then casting it to an xs:QName.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
			a_qname_value: XM_XPATH_QNAME_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/books.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("xdt:untypedAtomic ('xdt:untypedAtomic') cast as xs:QName")
			assert ("No valuation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			a_qname_value ?= evaluated_items.item (1)
			assert ("Correct value", a_qname_value /= Void and then STRING_.same_string (a_qname_value.string_value, "xdt:untypedAtomic"))
		end	

feature -- Set up

	set_up is
		do
			conformance.set_basic_xslt_processor
		end


feature {NONE} -- Implementation

	diagnose_evaluation_error (an_evaluator: XM_XPATH_EVALUATOR) is
		-- Print error diagnosis to standard error stream.
		do
			std.error.put_string (an_evaluator.error_value.error_message)
			std.error.put_string (", error code is ")
			std.error.put_string (an_evaluator.error_value.code.out)
			std.error.put_new_line
		end

end

			