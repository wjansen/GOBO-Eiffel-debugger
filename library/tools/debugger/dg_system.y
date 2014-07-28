%{ 
note
 
  description: "Parser of Vala generated C header files" 
  
     class DG_SYSTEM
 
inherit 
 
	YY_PARSER_SKELETON 
		rename 
			make as make_parser_skeleton 
		redefine 
			default_create,
			report_error
		end 
 
	DG_SCANNER 
		undefine
			copy, is_equal, out
		redefine 
			default_create
		end 


	IS_SYSTEM
		rename 
			make as make_system 
		undefine
			copy, is_equal, out
		redefine 
			default_create,
			type_by_name
		end 

create 
 
	make 
 
%} 
 
%token <INTEGER> BEGIN_TYPEDEF END_TYPEDEF
%token <INTEGER> BEGIN_STRUCT END_STRUCT 
%token <INTEGER> BEGIN_ENUM END_ENUM 
%token <INTEGER> INTEGER
%token <STRING> IDENTIFIER ENUM_NAME CLASS_NAME TYPE_NAME STRUCT_NAME

%type <STRING> header enum entries entry delegate args arg
%type <IS_TYPE> typedef struct 
%type <IS_FIELD> field
%type <IS_SEQUENCE[IS_FIELD]> fields

%start header
 
%% 

header	:	-- ignore 
	|	header typedef
	|	header struct
	|	header enum
	|	header delegate
	;

typedef	:	BEGIN_TYPEDEF BEGIN_STRUCT STRUCT_NAME CLASS_NAME END_TYPEDEF
		  { $$ := type_of_name (as_class_name ($4), $4) }
	|	BEGIN_TYPEDEF IDENTIFIER CLASS_NAME END_TYPEDEF
		  { $$ := type_of_name (as_class_name ($3), $3) }
	|	BEGIN_TYPEDEF error END_TYPEDEF
	;

enum	:	BEGIN_TYPEDEF BEGIN_ENUM '{' entries '}' CLASS_NAME END_ENUM
		  { enum_val := 0 }
	;

entries	:	entry 
	|	entries ',' entry 
	;

entry	:	ENUM_NAME
		  { $$ := $1
		    treat_enum ($1)
		    enum_val := enum_val + 1
		  }
	|	ENUM_NAME '=' INTEGER
		  { $$ := $1
		    enum_val := last_integer_value
		    treat_enum ($1)
		    enum_val := enum_val+1
		  }
;

struct	:	BEGIN_STRUCT STRUCT_NAME '{' fields END_STRUCT
		  { $$ := type_of_name (as_struct_name ($2), $2) 
		    $$.set_fields($4) 
		  }
	;

delegate:	BEGIN_TYPEDEF TYPE_NAME '(' '*' CLASS_NAME ')' '(' args ')' END_TYPEDEF
	;

args	:	arg
	|	args ',' arg
	;

arg	:	TYPE_NAME IDENTIFIER
	;

fields	:	field
		  { create $$.make_1 ($1) }
	|	fields field
		  { $$ := $1 ;  $$.add ($2) }
	;

field	:	CLASS_NAME IDENTIFIER ';'
		  { create $$.make ($2, expanded_type (as_class_name($1), $1), Void, Void) 
		    $$.set_as_subobject 
		  }
	|	TYPE_NAME IDENTIFIER ';'
		  { create $$.make ($2, type_of_name (as_type_name($1), $1), Void, Void) 
		  }
	|	TYPE_NAME '*' IDENTIFIER ';' TYPE_NAME IDENTIFIER ';'
		  { create $$.make ($3, new_special_type 
				    (type_of_name (as_type_name($1), $1)), 
				    Void, Void) 
		  }
	;

%% 
 
feature {} -- Initialization 

	default_create
		do
			make_compressed_scanner_skeleton
			make_parser_skeleton
			Precursor {IS_SYSTEM} 
		end
 
	make (pattern: IS_SYSTEM; f: KI_TEXT_INPUT_STREAM)
		local
			tid: INTEGER
		do
			default_create
			origin := pattern
			force_type (Boolean_ident, pattern)
			force_type (Char8_ident, pattern)
			force_type (Char32_ident, pattern)
			force_type (Int32_ident, pattern)
			force_type (Int64_ident, pattern)
			force_type (Nat32_ident, pattern)
			force_type (Nat64_ident, pattern)
			force_type (Pointer_ident, pattern)
			force_type (String8_ident, pattern)
			force_type (String32_ident, pattern)
			tid := pattern.any_type.ident
			force_type (tid, pattern)
			if attached {like any_type} type_at (tid) as a then
				any_type := a
			end
			max_type_id := max_type_id.max (20)	-- type ident of NONE
			create type_enums.make_equal (99)
			int64 := type_at(Int64_ident)
			make_with_file (f)
		end 
 
feature -- Access

	any_type: IS_NORMAL_TYPE

	none_type: like any_type

	type_enums: DS_HASH_TABLE[INTEGER, STRING]

feature -- Error handling

	report_error (msg: STRING)
		do
			io.error.put_string (msg)
			io.error.put_character (' ')
			io.error.put_integer (line)
			io.error.put_character (':')
			io.error.put_integer (column)
			io.error.put_new_line
		end

feature -- Basic operation

	type_by_name (tn: READABLE_STRING_8; attac: BOOLEAN): attached like type_at
		local
			bc: IS_CLASS_TEXT
			nm: STRING
		do
			create nm.make_from_string (tn)
			if attached {IS_NORMAL_TYPE} Precursor (nm, True) as nt then
				Result := nt 
			else
				max_type_id := max_type_id + 1
				max_class_id := max_class_id + 1
				create bc.make (max_class_id, tn, 0, Void, Void, Void)
				create {IS_NORMAL_TYPE} Result.make(max_type_id, bc, Reference_flag, Void, Void, Void, Void, Void)
				all_classes.force (bc, bc.ident)
				all_types.force (Result, Result.ident)
			end
		end

	new_special_type (ti: IS_TYPE): IS_TYPE
		local
			tc: IS_TYPE
			ts: IS_SPECIAL_TYPE
			f: IS_FIELD
			ff: IS_SEQUENCE [IS_FIELD]
			fl: INTEGER
		do
			if attached special_type_by_item_type (ti, True) as st then
				Result := st
			else
				max_type_id := max_type_id + 1
				tc := type_by_name ("INTEGER_32", True)
				create f.make ("count", tc, Void, Void);
				create ff.make (3, f);
				ff.add (f)
				create f.make ("capacity", tc, Void, Void);
				ff.add (f)
				create f.make ("item", ti, Void, Void);
				ff.add (f)
				ts := origin.special_type_by_item_type (ti, True)
				if ts /= Void then
					fl := ts.flags
				elseif ti.is_basic then
					fl := Reference_flag
				else 
					fl := ti.flags & Reference_flag
				end
				create {IS_SPECIAL_TYPE} 
					Result.make (max_type_id, fl, ti, ff, Void, Void)
				Result.set_c_name (ti.c_name)
				all_types.force (Result, Result.ident)
			end
		end
	
	force_type (tid: INTEGER; pattern: IS_SYSTEM)
		local
			nt: IS_NORMAL_TYPE
			cls: IS_CLASS_TEXT
			cid: INTEGER
		do
			if pattern.valid_type(tid)
				and then attached {IS_NORMAL_TYPE} pattern.type_at(tid) as t
			then
				max_class_id := max_class_id + 1
				cid := max_class_id
				create cls.make(cid, t.class_name, 0, Void, Void, Void)
				all_classes.force (cls, cid)
				if t.is_subobject then
					create {IS_EXPANDED_TYPE} nt.make (tid, cls, t.flags, Void, Void, Void, Void, Void)
				else
					create nt.make (tid, cls, t.flags, Void, Void, Void, Void, Void)
				end
				all_types.force (nt, tid)
				max_type_id := max_type_id.max(tid)
			end
		end
	
feature {} -- Implementation

	max_type_id: INTEGER
	max_class_id: INTEGER

	enum_val: INTEGER

	int64: IS_TYPE

	origin: IS_SYSTEM
									
	as_class_name (cn: STRING): STRING
		do
			Result := cn.twin
			Result.remove_head (4)
			Result.to_upper
		end

	as_type_name (tn: STRING): STRING
		do
			if STRING_.same_string (tn, "gboolean") then
				Result := "BOOLEAN"
			elseif STRING_.same_string (tn, "gint") then
				Result := "INTEGER_32"
			elseif STRING_.same_string (tn, "gint") then
				Result := "INTEGER_32"
			elseif STRING_.same_string (tn, "guint") then
				Result := "NATURAL_32"
			elseif STRING_.same_string (tn, "guint64") then
				Result := "NATURAL_64"
			elseif STRING_.same_string (tn, "gsize") then
				Result := "NATURAL_64"
			elseif STRING_.same_string (tn, "gchar*") then
				Result := "STRING_8"
			elseif STRING_.same_string (tn, "gpointer") then
				Result := "POINTER"
			elseif STRING_.same_string (tn, "gconstpointer") then
				Result := "POINTER"
			elseif STRING_.same_string (tn, "void*") then
				Result := "POINTER"
			else
				Result := tn.twin
				Result.remove_head (4)
				Result.remove_tail (1)
				Result.right_adjust
			end
			Result.to_upper
		end

	as_struct_name (sn: STRING): STRING
		do
			Result := sn.twin
			Result.remove_head (5)
			Result.to_upper
		end

	type_of_name (nm, c: STRING): IS_TYPE
		local
			cn: STRING    
		do
			Result := type_by_name (nm, True)
			if Result.c_name = Void then
				inspect Result.ident
				when Boolean_ident then
					cn := "char"
				when Int32_ident then
					cn := "int32_t"
				when Nat32_ident then
					cn := "uint32_t"
				when Nat64_ident then
					cn := "uint64_t"
				when Real32_ident then
					cn := "float"
				when Real64_ident then
					cn := "double"
				when Pointer_ident then
					cn := "void*"
				when String8_ident, String32_ident then
					cn := "char"
				else
					cn := c
				end
				Result.set_c_name (cn)
			end
		end

	expanded_type (nm, cn: STRING): IS_EXPANDED_TYPE
		local
			cls: IS_CLASS_TEXT
			pp: IS_SEQUENCE[IS_CLASS_TEXT]
			base, ft: IS_TYPE
			f: IS_FIELD
			ff: IS_SEQUENCE[IS_FIELD]
			nn: STRING
			id, i, n: INTEGER
		do
			max_class_id := max_class_id + 1
			nn :=  "GE_Z_" + max_class_id.out
			create pp.make_1 (class_by_name (nm))
			create cls.make (max_class_id, nn, 0, Void, Void, pp)
			base := type_of_name (nm, cn)
	       		max_type_id := max_type_id + 1
			id := max_type_id
		    	from
				n := base.field_count
				create ff.make (n, Void)
			until i = n loop
		    		f := base.field_at(i)
				ft := f.type
				if f.name_has_prefix (once "_") and then not f.has_name (once "_id") then
					ft := expanded_type (as_class_name (ft.c_name), ft.c_name)
				else
				end
				create f.make (f.fast_name, ft, Void, Void)
				ff.add (f)
				i := i + 1
			end
			create Result.make (id, cls, 
				Subobject_flag, Void, Void, ff, Void, Void)
			Result.set_c_name (cn)
		end

	treat_enum (nm: STRING)
		local
			i, l: INTEGER
			c: CHARACTER
		do
			l := nm.substring_index(type_ident_name, 1)
			if l > 0 then
				nm.remove_head (type_ident_name.count)
				from
					l := nm.count
					i := 2
				until i > l loop
					c := nm[i]
					if c = '_' then
						nm.remove (i)
					else
						nm[i] := c.as_lower
					end
					i := i + 1
				end
				type_enums.force (enum_val, "Gedb" + nm)
			end
		end

	type_ident_name: STRING = "GEDB_TYPE_IDENT_"

invariant 
 
note
	copyright: "Copyright (c) 2013-2014, Wolfgang Jansen and others" 
	license: "MIT License" 
	date: "$Date$" 
	revision: "$Revision$" 
	compilation: "geyacc -t DG_TOKENS -o dg_system.e -x dg_system.y" 

end
