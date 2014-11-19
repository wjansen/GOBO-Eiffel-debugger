/* inspect.h generated by valac 0.22.1, the Vala compiler, do not modify */


#ifndef __INSPECT_H__
#define __INSPECT_H__

#include <glib.h>
#include <stdlib.h>
#include <string.h>
#include <glib-object.h>

G_BEGIN_DECLS


#define GEDB_TYPE_TYPE_IDENT (gedb_type_ident_get_type ())

#define GEDB_TYPE_SYSTEM_FLAG (gedb_system_flag_get_type ())

#define GEDB_TYPE_CLASS_FLAG (gedb_class_flag_get_type ())

#define GEDB_TYPE_TYPE_FLAG (gedb_type_flag_get_type ())

#define GEDB_TYPE_ROUTINE_FLAG (gedb_routine_flag_get_type ())

#define GEDB_TYPE_NAME (gedb_name_get_type ())
typedef struct _GedbName GedbName;

#define GEDB_TYPE_OFFSETS (gedb_offsets_get_type ())
typedef struct _GedbOffsets GedbOffsets;

#define GEDB_TYPE_SYSTEM (gedb_system_get_type ())

#define GEDB_TYPE_AGENT_TYPE (gedb_agent_type_get_type ())

#define GEDB_TYPE_TYPE (gedb_type_get_type ())

#define GEDB_TYPE_CLASS_TEXT (gedb_class_text_get_type ())

#define GEDB_TYPE_FEATURE_TEXT (gedb_feature_text_get_type ())
typedef struct _GedbFeatureText GedbFeatureText;
typedef struct _GedbClassText GedbClassText;

#define GEDB_TYPE_ROUTINE (gedb_routine_get_type ())

#define GEDB_TYPE_ENTITY (gedb_entity_get_type ())
typedef struct _GedbEntity GedbEntity;

#define GEDB_TYPE_LOCAL (gedb_local_get_type ())
typedef struct _GedbLocal GedbLocal;
typedef struct _GedbRoutine GedbRoutine;

#define GEDB_TYPE_FIELD (gedb_field_get_type ())
typedef struct _GedbField GedbField;

#define GEDB_TYPE_CONSTANT (gedb_constant_get_type ())
typedef struct _GedbConstant GedbConstant;
typedef struct _GedbType GedbType;

#define GEDB_TYPE_NORMAL_TYPE (gedb_normal_type_get_type ())
typedef struct _GedbNormalType GedbNormalType;

#define GEDB_TYPE_TUPLE_TYPE (gedb_tuple_type_get_type ())
typedef struct _GedbTupleType GedbTupleType;
typedef struct _GedbAgentType GedbAgentType;

#define GEDB_TYPE_ONCE (gedb_once_get_type ())
typedef struct _GedbOnce GedbOnce;
typedef struct _GedbSystem GedbSystem;

#define GEDB_TYPE_SPECIAL_TYPE (gedb_special_type_get_type ())
typedef struct _GedbSpecialType GedbSpecialType;

#define GEDB_TYPE_SCOPE_VARIABLE (gedb_scope_variable_get_type ())
typedef struct _GedbScopeVariable GedbScopeVariable;

#define GEDB_TYPE_ROUTINE_TEXT (gedb_routine_text_get_type ())
typedef struct _GedbRoutineText GedbRoutineText;

#define GEDB_TYPE_EXPANDED_TYPE (gedb_expanded_type_get_type ())
typedef struct _GedbExpandedType GedbExpandedType;

#define GEDB_TYPE_STACK_FRAME (gedb_stack_frame_get_type ())
typedef struct _GedbStackFrame GedbStackFrame;

typedef enum  {
	GEDB_TYPE_IDENT_BOOLEAN = 1,
	GEDB_TYPE_IDENT_CHARACTER_8,
	GEDB_TYPE_IDENT_CHARACTER_32,
	GEDB_TYPE_IDENT_INTEGER_8,
	GEDB_TYPE_IDENT_INTEGER_16,
	GEDB_TYPE_IDENT_INTEGER_32,
	GEDB_TYPE_IDENT_INTEGER_64,
	GEDB_TYPE_IDENT_NATURAL_8,
	GEDB_TYPE_IDENT_NATURAL_16,
	GEDB_TYPE_IDENT_NATURAL_32,
	GEDB_TYPE_IDENT_NATURAL_64,
	GEDB_TYPE_IDENT_REAL_32,
	GEDB_TYPE_IDENT_REAL_64,
	GEDB_TYPE_IDENT_POINTER,
	GEDB_TYPE_IDENT_MAX_BASIC = 14,
	GEDB_TYPE_IDENT_STRING_8 = 17,
	GEDB_TYPE_IDENT_STRING_32 = 18,
	GEDB_TYPE_IDENT_ANY = 19,
	GEDB_TYPE_IDENT_NONE = 20,
	GEDB_TYPE_IDENT_NAME,
	GEDB_TYPE_IDENT_TYPE,
	GEDB_TYPE_IDENT_NORMAL_TYPE,
	GEDB_TYPE_IDENT_EXPANDED_TYPE,
	GEDB_TYPE_IDENT_SPECIAL_TYPE,
	GEDB_TYPE_IDENT_TUPLE_TYPE,
	GEDB_TYPE_IDENT_AGENT_TYPE,
	GEDB_TYPE_IDENT_CLASS_TEXT,
	GEDB_TYPE_IDENT_FEATURE_TEXT,
	GEDB_TYPE_IDENT_ROUTINE_TEXT,
	GEDB_TYPE_IDENT_ENTITY,
	GEDB_TYPE_IDENT_CONSTANT,
	GEDB_TYPE_IDENT_FIELD,
	GEDB_TYPE_IDENT_LOCAL,
	GEDB_TYPE_IDENT_ROUTINE,
	GEDB_TYPE_IDENT_SCOPE_VARIABLE,
	GEDB_TYPE_IDENT_ONCE,
	GEDB_TYPE_IDENT_SYSTEM
} GedbTypeIdent;

typedef enum  {
	GEDB_SYSTEM_FLAG_FOREIGN = 0x08,
	GEDB_SYSTEM_FLAG_SCOOP = 0x10,
	GEDB_SYSTEM_FLAG_NO_GC = 0x20
} GedbSystemFlag;

typedef enum  {
	GEDB_CLASS_FLAG_SUBOBJECT = 1,
	GEDB_CLASS_FLAG_REFERENCE = 2,
	GEDB_CLASS_FLAG_PROXY = 3,
	GEDB_CLASS_FLAG_FLEXIBLE = 4,
	GEDB_CLASS_FLAG_MEMORY_CATEGORY = 7,
	GEDB_CLASS_FLAG_BASIC_EXPANDED = 0x9,
	GEDB_CLASS_FLAG_BITS = 0x11,
	GEDB_CLASS_FLAG_TUPLE = 0x10,
	GEDB_CLASS_FLAG_AGENT = 0x20,
	GEDB_CLASS_FLAG_ANONYMOUS = 0x30,
	GEDB_CLASS_FLAG_TYPE_CATEGORY = 0x3f,
	GEDB_CLASS_FLAG_ACTIONABLE = 0x40,
	GEDB_CLASS_FLAG_INVARIANT = 0x80,
	GEDB_CLASS_FLAG_DEBUGGER = 0x100
} GedbClassFlag;

typedef enum  {
	GEDB_TYPE_FLAG_SUBOBJECT = 1,
	GEDB_TYPE_FLAG_REFERENCE = 2,
	GEDB_TYPE_FLAG_PROXY = 3,
	GEDB_TYPE_FLAG_FLEXIBLE = 4,
	GEDB_TYPE_FLAG_MEMORY_CATEGORY = 7,
	GEDB_TYPE_FLAG_BASIC_EXPANDED = 0x9,
	GEDB_TYPE_FLAG_BITS = 0x11,
	GEDB_TYPE_FLAG_TUPLE = 0x10,
	GEDB_TYPE_FLAG_AGENT = 0x20,
	GEDB_TYPE_FLAG_ANONYMOUS = 0x30,
	GEDB_TYPE_FLAG_TYPE_CATEGORY = 0x3f,
	GEDB_TYPE_FLAG_ATTACHED = 0x40,
	GEDB_TYPE_FLAG_COPY_SEMANTICS = 0x200,
	GEDB_TYPE_FLAG_MISSING_ID = 0x800,
	GEDB_TYPE_FLAG_AGENT_EXPRESSION = 0x1000,
	GEDB_TYPE_FLAG_META_TYPE = 0x2000
} GedbTypeFlag;

typedef enum  {
	GEDB_ROUTINE_FLAG_DO = 0,
	GEDB_ROUTINE_FLAG_EXTERNAL = 1,
	GEDB_ROUTINE_FLAG_ONCE = 2,
	GEDB_ROUTINE_FLAG_DEFERRED = 3,
	GEDB_ROUTINE_FLAG_IMPLEMENTATION = 3,
	GEDB_ROUTINE_FLAG_FUNCTION = 4,
	GEDB_ROUTINE_FLAG_OPERATOR = 0xC,
	GEDB_ROUTINE_FLAG_BRACKET = 0x14,
	GEDB_ROUTINE_FLAG_CREATION = 0x20,
	GEDB_ROUTINE_FLAG_DEFAULT_CREATION = 0x60,
	GEDB_ROUTINE_FLAG_INVARIANT = 0x80,
	GEDB_ROUTINE_FLAG_PRECURSOR = 0x100,
	GEDB_ROUTINE_FLAG_RESCUE = 0x200,
	GEDB_ROUTINE_FLAG_NO_CURRENT = 0x400,
	GEDB_ROUTINE_FLAG_ANONYMOUS_ROUTINE = 0x800,
	GEDB_ROUTINE_FLAG_INLINED = 0x1000,
	GEDB_ROUTINE_FLAG_FROZEN = 0x2000,
	GEDB_ROUTINE_FLAG_SIDE_EFFECT = 0x4000,
	GEDB_ROUTINE_FLAG_ROUTINE = 0x8000
} GedbRoutineFlag;

typedef gboolean (*GedbLessFunc) (gconstpointer u, gconstpointer v, void* user_data);
struct _GedbName {
	gint _id;
	gchar* fast_name;
};

struct _GedbOffsets {
	gint area;
	gint item;
};

struct _GedbFeatureText {
	GedbName _name;
	gchar* alias_name;
	gint flags;
	GedbFeatureText** tuple_labels;
	gint tuple_labels_length1;
	GedbClassText* home;
	GedbClassText* result_text;
	GedbFeatureText* renames;
	guint first_pos;
	guint last_pos;
};

struct _GedbClassText {
	GedbName _name;
	guint ident;
	guint flags;
	gchar* path;
	GedbClassText** parents;
	gint parents_length1;
	GedbFeatureText** features;
	gint features_length1;
};

struct _GedbEntity {
	GedbName _name;
	GedbType* type;
	GedbType* target;
	GedbType** type_set;
	gint type_set_length1;
	GedbFeatureText* text;
	gchar* alias_name;
};

struct _GedbLocal {
	GedbEntity _entity;
	gint offset;
};

struct _GedbRoutine {
	GedbEntity _entity;
	guint flags;
	GedbType* target;
	GedbAgentType* inline_agent;
	guint argument_count;
	guint local_count;
	guint scope_var_count;
	guint old_value_count;
	guint temp_var_count;
	GedbLocal** vars;
	gint vars_length1;
	GedbRoutine** inline_routines;
	gint inline_routines_length1;
	GedbRoutine** precursors;
	gint precursors_length1;
	void* call;
	guint wrap;
};

struct _GedbField {
	GedbEntity _entity;
	gint offset;
};

struct _GedbConstant {
	GedbEntity _entity;
	guint flags;
	GedbClassText* home;
	guint64 basic;
	void* ms;
};

struct _GedbType {
	GedbName _name;
	guint ident;
	GedbClassText* base_class;
	gchar* class_name;
	GedbType** generics;
	gint generics_length1;
	GedbType** effectors;
	gint effectors_length1;
	GedbRoutine** routines;
	gint routines_length1;
	GedbField** fields;
	gint fields_length1;
	GedbConstant** constants;
	gint constants_length1;
	guint flags;
	guint instance_bytes;
	void* default_instance;
	void* allocate;
};

struct _GedbNormalType {
	GedbType _type;
};

struct _GedbTupleType {
	GedbType _type;
};

struct _GedbAgentType {
	GedbType _type;
	GedbType* base_type;
	gchar* open_closed_pattern;
	guint open_operand_count;
	guint closed_operand_count;
	GedbNormalType* declared_type;
	GedbTupleType* closed_operands_tuple;
	GedbRoutine* routine;
	gchar* routine_name;
	void* call_function;
	void* function_location;
	gint function_offset;
};

struct _GedbOnce {
	GedbRoutine _routine;
	GedbClassText* home;
	void* value_address;
	void* init_address;
};

struct _GedbSystem {
	GedbName _name;
	gint flags;
	GedbAgentType** all_agents;
	gint all_agents_length1;
	GedbType** all_types;
	gint all_types_length1;
	GedbClassText** all_classes;
	gint all_classes_length1;
	GedbConstant** all_constants;
	gint all_constants_length1;
	GedbOnce** all_onces;
	gint all_onces_length1;
	gint assertion_check;
	GedbRoutine* root_creation_procedure;
	GedbNormalType* root_type;
	guint max_bytes;
	guint64 compilation_time;
	guint64 creation_time;
	gchar* compiler;
	GedbType** type_stack;
	gint type_stack_length1;
	guint type_stack_count;
};

struct _GedbSpecialType {
	GedbType _type;
};

struct _GedbScopeVariable {
	GedbLocal _local;
	gboolean is_object_test;
	gint lower_scope_limit;
	gint upper_scope_limit;
};

struct _GedbRoutineText {
	GedbFeatureText _feature;
	guint entry_pos;
	guint rescue_pos;
	guint exit_pos;
	GedbFeatureText** vars;
	gint vars_length1;
	gint argument_count;
	gint local_count;
	gint scope_var_count;
	GedbRoutineText** inline_texts;
	gint inline_texts_length1;
	guint* instruction_positions;
	gint instruction_positions_length1;
};

struct _GedbExpandedType {
	GedbNormalType _normal;
	guint boxed_bytes;
	guint boxed_offset;
	void* unboxed_location;
};

struct _GedbStackFrame {
	gint depth;
	gint scope_depth;
	GedbStackFrame* caller;
	guint pos;
	guint class_id;
	GedbRoutine* routine;
};

typedef void* (*GedbNewObject) (gboolean init, void* user_data);
typedef void* (*GedbNewArray) (guint n, gboolean init, void* user_data);
typedef void (*GedbInit) (void* obj, void* user_data);

GType gedb_type_ident_get_type (void) G_GNUC_CONST;
GType gedb_system_flag_get_type (void) G_GNUC_CONST;
GType gedb_class_flag_get_type (void) G_GNUC_CONST;
GType gedb_type_flag_get_type (void) G_GNUC_CONST;
GType gedb_routine_flag_get_type (void) G_GNUC_CONST;
void gedb_add (GType n_type, GBoxedCopyFunc n_dup_func, GDestroyNotify n_destroy_func, gpointer* list, int list_length1, gconstpointer d);
void gedb_clean (GType n_type, GBoxedCopyFunc n_dup_func, GDestroyNotify n_destroy_func, gpointer* list, int list_length1);
void gedb_sort (GType n_type, GBoxedCopyFunc n_dup_func, GDestroyNotify n_destroy_func, gpointer* list, int list_length1, GedbLessFunc comp, void* comp_target);
guint gedb_position_as_integer (guint l, guint c);
guint gedb_line_of_position (guint p);
guint gedb_column_of_position (guint p);
GType gedb_name_get_type (void) G_GNUC_CONST;
GedbName* gedb_name_dup (const GedbName* self);
void gedb_name_free (GedbName* self);
void gedb_name_copy (const GedbName* self, GedbName* dest);
void gedb_name_destroy (GedbName* self);
GedbName* gedb_query_from_list (const gchar* name, GedbName** list, int list_length1, guint* n);
gboolean gedb_name_has_name (GedbName *self, const gchar* name);
gboolean gedb_name_has_prefix (GedbName *self, const gchar* pre);
gchar* gedb_name_to_string (GedbName *self);
gchar* gedb_name_append_name (GedbName *self, const gchar* to);
gchar* gedb_name_append_indented_name (GedbName *self, const gchar* to, gint indent);
gchar* gedb_name_pad_right (GedbName *self, const gchar* to, guint n);
gchar* gedb_name_pad_left (GedbName *self, const gchar* to, guint n);
gboolean gedb_name_is_less (GedbName *self, GedbName* other);
gboolean gedb_name_is_system (GedbName *self);
gboolean gedb_name_is_entity (GedbName *self);
gboolean gedb_name_is_field (GedbName *self);
gboolean gedb_name_is_local (GedbName *self);
gboolean gedb_name_is_scope_var (GedbName *self);
gboolean gedb_name_is_routine (GedbName *self);
gboolean gedb_name_is_once (GedbName *self);
gboolean gedb_name_is_constant (GedbName *self);
gboolean gedb_name_is_class_text (GedbName *self);
gboolean gedb_name_is_feature_text (GedbName *self);
gboolean gedb_name_is_routine_text (GedbName *self);
gboolean gedb_name_is_type (GedbName *self);
gboolean gedb_name_is_normal_type (GedbName *self);
gboolean gedb_name_is_expanded_type (GedbName *self);
gboolean gedb_name_is_special_type (GedbName *self);
gboolean gedb_name_is_tuple_type (GedbName *self);
gboolean gedb_name_is_agent_type (GedbName *self);
GType gedb_offsets_get_type (void) G_GNUC_CONST;
GedbOffsets* gedb_offsets_dup (const GedbOffsets* self);
void gedb_offsets_free (GedbOffsets* self);
GType gedb_system_get_type (void) G_GNUC_CONST;
GType gedb_agent_type_get_type (void) G_GNUC_CONST;
GType gedb_type_get_type (void) G_GNUC_CONST;
GType gedb_class_text_get_type (void) G_GNUC_CONST;
GType gedb_feature_text_get_type (void) G_GNUC_CONST;
GedbFeatureText* gedb_feature_text_dup (const GedbFeatureText* self);
void gedb_feature_text_free (GedbFeatureText* self);
void gedb_feature_text_copy (const GedbFeatureText* self, GedbFeatureText* dest);
void gedb_feature_text_destroy (GedbFeatureText* self);
GedbClassText* gedb_class_text_dup (const GedbClassText* self);
void gedb_class_text_free (GedbClassText* self);
void gedb_class_text_copy (const GedbClassText* self, GedbClassText* dest);
void gedb_class_text_destroy (GedbClassText* self);
GType gedb_routine_get_type (void) G_GNUC_CONST;
GType gedb_entity_get_type (void) G_GNUC_CONST;
GedbEntity* gedb_entity_dup (const GedbEntity* self);
void gedb_entity_free (GedbEntity* self);
void gedb_entity_copy (const GedbEntity* self, GedbEntity* dest);
void gedb_entity_destroy (GedbEntity* self);
GType gedb_local_get_type (void) G_GNUC_CONST;
GedbLocal* gedb_local_dup (const GedbLocal* self);
void gedb_local_free (GedbLocal* self);
void gedb_local_copy (const GedbLocal* self, GedbLocal* dest);
void gedb_local_destroy (GedbLocal* self);
GedbRoutine* gedb_routine_dup (const GedbRoutine* self);
void gedb_routine_free (GedbRoutine* self);
void gedb_routine_copy (const GedbRoutine* self, GedbRoutine* dest);
void gedb_routine_destroy (GedbRoutine* self);
GType gedb_field_get_type (void) G_GNUC_CONST;
GedbField* gedb_field_dup (const GedbField* self);
void gedb_field_free (GedbField* self);
void gedb_field_copy (const GedbField* self, GedbField* dest);
void gedb_field_destroy (GedbField* self);
GType gedb_constant_get_type (void) G_GNUC_CONST;
GedbConstant* gedb_constant_dup (const GedbConstant* self);
void gedb_constant_free (GedbConstant* self);
void gedb_constant_copy (const GedbConstant* self, GedbConstant* dest);
void gedb_constant_destroy (GedbConstant* self);
GedbType* gedb_type_dup (const GedbType* self);
void gedb_type_free (GedbType* self);
void gedb_type_copy (const GedbType* self, GedbType* dest);
void gedb_type_destroy (GedbType* self);
GType gedb_normal_type_get_type (void) G_GNUC_CONST;
GedbNormalType* gedb_normal_type_dup (const GedbNormalType* self);
void gedb_normal_type_free (GedbNormalType* self);
void gedb_normal_type_copy (const GedbNormalType* self, GedbNormalType* dest);
void gedb_normal_type_destroy (GedbNormalType* self);
GType gedb_tuple_type_get_type (void) G_GNUC_CONST;
GedbTupleType* gedb_tuple_type_dup (const GedbTupleType* self);
void gedb_tuple_type_free (GedbTupleType* self);
void gedb_tuple_type_copy (const GedbTupleType* self, GedbTupleType* dest);
void gedb_tuple_type_destroy (GedbTupleType* self);
GedbAgentType* gedb_agent_type_dup (const GedbAgentType* self);
void gedb_agent_type_free (GedbAgentType* self);
void gedb_agent_type_copy (const GedbAgentType* self, GedbAgentType* dest);
void gedb_agent_type_destroy (GedbAgentType* self);
GType gedb_once_get_type (void) G_GNUC_CONST;
GedbOnce* gedb_once_dup (const GedbOnce* self);
void gedb_once_free (GedbOnce* self);
void gedb_once_copy (const GedbOnce* self, GedbOnce* dest);
void gedb_once_destroy (GedbOnce* self);
GedbSystem* gedb_system_dup (const GedbSystem* self);
void gedb_system_free (GedbSystem* self);
void gedb_system_copy (const GedbSystem* self, GedbSystem* dest);
void gedb_system_destroy (GedbSystem* self);
extern GedbOffsets gedb_system_string_offsets;
extern GedbOffsets gedb_system_unicode_offsets;
gboolean gedb_system_has_gc (GedbSystem *self);
gboolean gedb_system_is_scoop (GedbSystem *self);
gboolean gedb_system_is_debugging (GedbSystem *self);
guint gedb_system_class_count (GedbSystem *self);
GedbClassText* gedb_system_class_at (GedbSystem *self, guint i);
guint gedb_system_type_count (GedbSystem *self);
GedbType* gedb_system_type_at (GedbSystem *self, guint i);
guint gedb_system_agent_count (GedbSystem *self);
GedbAgentType* gedb_system_agent_at (GedbSystem *self, guint i);
guint gedb_system_once_count (GedbSystem *self);
GedbOnce* gedb_system_once_at (GedbSystem *self, guint i);
guint gedb_system_constant_count (GedbSystem *self);
GedbConstant* gedb_system_constant_at (GedbSystem *self, guint i);
GedbType* gedb_system_as_type (GedbSystem *self, GedbClassText* ct);
GedbClassText* gedb_system_class_by_name (GedbSystem *self, const gchar* name);
void gedb_system_push_type (GedbSystem* s, guint id);
GedbType* gedb_system_top_type (GedbSystem* s);
GedbType* gedb_system_below_top_type (GedbSystem* s, guint n);
void gedb_system_pop_types (GedbSystem* s, guint n);
GedbType* gedb_system_basic_type (GedbSystem *self, guint id);
GedbType* gedb_system_type_by_class_and_generics (GedbSystem *self, const gchar* nm, guint gc, gboolean attac);
GedbTupleType* gedb_system_tuple_type_by_generics (GedbSystem *self, guint gc, gboolean attac);
GType gedb_special_type_get_type (void) G_GNUC_CONST;
GedbSpecialType* gedb_special_type_dup (const GedbSpecialType* self);
void gedb_special_type_free (GedbSpecialType* self);
void gedb_special_type_copy (const GedbSpecialType* self, GedbSpecialType* dest);
void gedb_special_type_destroy (GedbSpecialType* self);
GedbSpecialType* gedb_system_special_type_by_item_type (GedbSystem *self, GedbType* it, gboolean attac);
GedbAgentType* gedb_system_agent_by_base_and_routine (GedbSystem *self, GedbType* bt, const gchar* ocp, const gchar* nm);
GedbType* gedb_system_type_by_name (GedbSystem *self, const gchar* type_name, gboolean attac);
GedbEntity* gedb_system_global_by_name_and_class (GedbSystem *self, const gchar* nm, GedbClassText* cls, gboolean as_function, gboolean init, guint* n);
guint gedb_system_object_type_id (GedbSystem *self, guint8* addr, gboolean is_home_addr, GedbType* stat);
gchar* gedb_system_append_name (GedbSystem *self, const gchar* to);
gchar* gedb_system_append_alphabetically (GedbSystem *self, const gchar* to);
GedbType* gedb_system_type_by_subname (GedbSystem *self, gchar** nm, gboolean attac);
GedbType* gedb_system_type_of_any (GedbSystem *self, void* a, GedbType* stat);
GedbAgentType* gedb_system_as_agent (GedbSystem *self, guint8* a);
gboolean gedb_entity_is_less (GedbEntity *self, GedbEntity* other);
gboolean gedb_entity_has_name (GedbEntity *self, const gchar* name);
gboolean gedb_entity_has_prefix (GedbEntity *self, const gchar* pre);
gchar* gedb_entity_to_string (GedbEntity *self);
gchar* gedb_entity_append_name (GedbEntity *self, const gchar* to);
gboolean gedb_entity_is_field (GedbEntity *self);
gboolean gedb_entity_is_local (GedbEntity *self);
gboolean gedb_entity_is_scope_var (GedbEntity *self);
gboolean gedb_entity_is_routine (GedbEntity *self);
gboolean gedb_entity_is_once (GedbEntity *self);
gboolean gedb_entity_is_constant (GedbEntity *self);
gboolean gedb_entity_is_assignable_from (GedbEntity *self, GedbType* rhs);
gboolean gedb_local_is_scope_var (GedbLocal *self);
GType gedb_scope_variable_get_type (void) G_GNUC_CONST;
GedbScopeVariable* gedb_scope_variable_dup (const GedbScopeVariable* self);
void gedb_scope_variable_free (GedbScopeVariable* self);
void gedb_scope_variable_copy (const GedbScopeVariable* self, GedbScopeVariable* dest);
void gedb_scope_variable_destroy (GedbScopeVariable* self);
gboolean gedb_scope_variable_in_scope (GedbScopeVariable *self, guint line, guint col);
void gedb_scope_variable_set_lower_scope_limit (GedbScopeVariable *self, gint l);
void gedb_scope_variable_set_upper_scope_limit (GedbScopeVariable *self, gint l);
GType gedb_routine_text_get_type (void) G_GNUC_CONST;
GedbRoutineText* gedb_routine_text_dup (const GedbRoutineText* self);
void gedb_routine_text_free (GedbRoutineText* self);
void gedb_routine_text_copy (const GedbRoutineText* self, GedbRoutineText* dest);
void gedb_routine_text_destroy (GedbRoutineText* self);
GedbRoutineText* gedb_routine_routine_text (GedbRoutine *self);
gboolean gedb_routine_is_procedure (GedbRoutine *self);
gboolean gedb_routine_is_function (GedbRoutine *self);
gboolean gedb_routine_is_operator (GedbRoutine *self);
gboolean gedb_routine_is_bracket (GedbRoutine *self);
gboolean gedb_routine_is_prefix (GedbRoutine *self);
gboolean gedb_routine_is_creation (GedbRoutine *self);
gboolean gedb_routine_is_default_creation (GedbRoutine *self);
gboolean gedb_routine_is_precursor (GedbRoutine *self);
gboolean gedb_routine_is_once (GedbRoutine *self);
gboolean gedb_routine_is_external (GedbRoutine *self);
gboolean gedb_routine_is_inlined (GedbRoutine *self);
gboolean gedb_routine_uses_current (GedbRoutine *self);
gboolean gedb_routine_has_result (GedbRoutine *self);
gboolean gedb_routine_has_rescue (GedbRoutine *self);
guint gedb_routine_variable_count (GedbRoutine *self);
gboolean gedb_routine_valid_var (GedbRoutine *self, guint i);
GedbLocal* gedb_routine_var_at (GedbRoutine *self, guint i);
GedbLocal* gedb_routine_result_field (GedbRoutine *self);
guint gedb_routine_inline_routine_count (GedbRoutine *self);
GedbRoutine* gedb_routine_inline_routine_at (GedbRoutine *self, guint i);
GedbLocal* gedb_routine_var_by_name (GedbRoutine *self, const gchar* nm);
gboolean gedb_routine_is_less (GedbRoutine *self, GedbRoutine* other);
gchar* gedb_routine_append_name (GedbRoutine *self, const gchar* to);
gboolean gedb_once_is_function (GedbOnce *self);
gboolean gedb_once_is_initialized (GedbOnce *self);
void gedb_once_re_initialize (GedbOnce *self);
void gedb_once_refresh (GedbOnce *self);
gboolean gedb_class_text_is_expanded (GedbClassText *self);
gboolean gedb_class_text_is_basic (GedbClassText *self);
gboolean gedb_class_text_is_separate (GedbClassText *self);
gboolean gedb_class_text_is_deferred (GedbClassText *self);
gboolean gedb_class_text_is_actionable (GedbClassText *self);
gboolean gedb_class_text_is_debug_enabled (GedbClassText *self);
gboolean gedb_class_text_supports_invariant (GedbClassText *self);
gboolean gedb_class_text_is_special (GedbClassText *self);
gboolean gedb_class_text_is_tuple (GedbClassText *self);
guint gedb_class_text_parent_count (GedbClassText *self);
gboolean gedb_class_text_valid_parent (GedbClassText *self, guint i);
GedbClassText* gedb_class_text_parent_at (GedbClassText *self, guint i);
guint gedb_class_text_feature_count (GedbClassText *self);
gboolean gedb_class_text_valid_feature (GedbClassText *self, guint i);
GedbFeatureText* gedb_class_text_feature_at (GedbClassText *self, guint i);
GedbFeatureText* gedb_class_text_feature_by_name (GedbClassText *self, const gchar* nm, gboolean deep);
GedbFeatureText* gedb_class_text_feature_by_line (GedbClassText *self, guint l);
guint gedb_class_text_descendance (GedbClassText *self, GedbClassText* other);
gboolean gedb_class_text_is_descendant (GedbClassText *self, GedbClassText* other);
GedbFeatureText* gedb_class_text_query_by_name (GedbClassText *self, guint* n, const gchar* name, gboolean as_prefix, GedbRoutineText* within);
gboolean gedb_feature_text_is_attribute (GedbFeatureText *self);
gboolean gedb_feature_text_is_routine (GedbFeatureText *self);
gboolean gedb_feature_text_is_constant (GedbFeatureText *self);
gboolean gedb_feature_text_is_variable (GedbFeatureText *self);
GedbFeatureText* gedb_feature_text_definition (GedbFeatureText *self);
gboolean gedb_feature_text_has_line (GedbFeatureText *self, guint l);
gboolean gedb_feature_text_has_position (GedbFeatureText *self, guint l, guint c);
guint gedb_feature_text_first_line (GedbFeatureText *self);
guint gedb_feature_text_last_line (GedbFeatureText *self);
guint gedb_feature_text_column (GedbFeatureText *self);
gchar* gedb_feature_text_append_label (GedbFeatureText *self, const gchar* to, const gchar* item);
gint gedb_feature_text_item_by_label (GedbFeatureText *self, const gchar* name);
gboolean gedb_routine_text_has_position (GedbRoutineText *self, guint l, guint c, gboolean body_only);
gboolean gedb_routine_text_has_rescue (GedbRoutineText *self);
guint gedb_routine_text_var_count (GedbRoutineText *self);
GedbFeatureText* gedb_routine_text_var_at (GedbRoutineText *self, guint i);
GedbFeatureText* gedb_routine_text_var_by_name (GedbRoutineText *self, const gchar* name);
gint gedb_routine_text_inline_text_count (GedbRoutineText *self);
guint gedb_routine_text_next_position (GedbRoutineText *self, gint p);
guint gedb_type_generic_count (GedbType *self);
gboolean gedb_type_valid_generic (GedbType *self, guint i);
GedbType* gedb_type_generic_at (GedbType *self, guint i);
guint gedb_type_effector_count (GedbType *self);
gboolean gedb_type_valid_effector (GedbType *self, guint i);
GedbType* gedb_type_effector_at (GedbType *self, guint i);
guint gedb_type_field_count (GedbType *self);
gboolean gedb_type_valid_field (GedbType *self, guint i);
GedbField* gedb_type_field_at (GedbType *self, guint i);
guint gedb_type_constant_count (GedbType *self);
gboolean gedb_type_valid_constant (GedbType *self, guint i);
GedbConstant* gedb_type_constant_at (GedbType *self, guint i);
guint gedb_type_routine_count (GedbType *self);
gboolean gedb_type_valid_routine (GedbType *self, guint i);
GedbRoutine* gedb_type_routine_at (GedbType *self, guint i);
GedbRoutine* gedb_type_default_creation (GedbType *self);
GedbRoutine* gedb_type_invariant_function (GedbType *self);
gboolean gedb_type_has_bracket (GedbType *self);
GedbRoutine* gedb_type_bracket (GedbType *self);
gboolean gedb_type_is_none (GedbType *self);
gboolean gedb_type_is_boolean (GedbType *self);
gboolean gedb_type_is_character (GedbType *self);
gboolean gedb_type_is_char8 (GedbType *self);
gboolean gedb_type_is_char32 (GedbType *self);
gboolean gedb_type_is_integer (GedbType *self);
gboolean gedb_type_is_int8 (GedbType *self);
gboolean gedb_type_is_int16 (GedbType *self);
gboolean gedb_type_is_int32 (GedbType *self);
gboolean gedb_type_is_int64 (GedbType *self);
gboolean gedb_type_is_natural (GedbType *self);
gboolean gedb_type_is_nat8 (GedbType *self);
gboolean gedb_type_is_nat16 (GedbType *self);
gboolean gedb_type_is_nat32 (GedbType *self);
gboolean gedb_type_is_nat64 (GedbType *self);
gboolean gedb_type_is_real (GedbType *self);
gboolean gedb_type_is_real32 (GedbType *self);
gboolean gedb_type_is_real64 (GedbType *self);
gboolean gedb_type_is_pointer (GedbType *self);
gboolean gedb_type_is_string (GedbType *self);
gboolean gedb_type_is_unicode (GedbType *self);
gboolean gedb_type_is_subobject (GedbType *self);
gboolean gedb_type_is_basic (GedbType *self);
gboolean gedb_type_is_reference (GedbType *self);
gboolean gedb_type_is_separate (GedbType *self);
gboolean gedb_type_is_anonymous (GedbType *self);
gboolean gedb_type_is_attached (GedbType *self);
gboolean gedb_type_is_meta_type (GedbType *self);
gboolean gedb_type_is_actionable (GedbType *self);
gboolean gedb_type_is_normal (GedbType *self);
gboolean gedb_type_is_expanded (GedbType *self);
gboolean gedb_type_is_nonbasic_expanded (GedbType *self);
gboolean gedb_type_is_special (GedbType *self);
gboolean gedb_type_is_tuple (GedbType *self);
gboolean gedb_type_is_agent (GedbType *self);
gboolean gedb_type_conforms_to (GedbType *self, GedbType* t);
gboolean gedb_type_is_alive (GedbType *self);
gboolean gedb_type_has_invariant (GedbType *self);
guint gedb_type_field_bytes (GedbType *self);
gboolean gedb_type_is_less (GedbType *self, GedbType* other);
gboolean gedb_type_is_name_less (GedbType *self, GedbType* other);
gboolean gedb_type_does_effect (GedbType *self, GedbType* other);
GedbField* gedb_type_field_by_name (GedbType *self, const gchar* nm);
GedbRoutine* gedb_type_routine_by_name (GedbType *self, const gchar* nm, gboolean creation);
GedbEntity* gedb_type_query_by_name (GedbType *self, guint* n, const gchar* name, gboolean as_prefix, GedbRoutine* within);
gchar* gedb_type_append_name (GedbType *self, const gchar* to);
void* gedb_type_new_instance (GedbType *self, gboolean use_default_creation);
guint8* gedb_type_dereference (GedbType *self, void* addr);
GType gedb_expanded_type_get_type (void) G_GNUC_CONST;
GedbExpandedType* gedb_expanded_type_dup (const GedbExpandedType* self);
void gedb_expanded_type_free (GedbExpandedType* self);
void gedb_expanded_type_copy (const GedbExpandedType* self, GedbExpandedType* dest);
void gedb_expanded_type_destroy (GedbExpandedType* self);
void gedb_expanded_type_set_boxed_bytes (GedbExpandedType *self, guint x);
void gedb_expanded_type_set_boxed_offset (GedbExpandedType *self, guint o);
void* gedb_expanded_type_new_instance (GedbExpandedType *self, gboolean use_default_creation);
GedbField* gedb_special_type_count (GedbSpecialType *self);
GedbField* gedb_special_type_item_0 (GedbSpecialType *self);
GedbType* gedb_special_type_item_type (GedbSpecialType *self);
guint gedb_special_type_item_bytes (GedbSpecialType *self);
gint gedb_special_type_item_offset (GedbSpecialType *self, guint i);
void* gedb_special_type_new_instance (GedbSpecialType *self, gboolean use_default_creation);
void* gedb_special_type_new_array (GedbSpecialType *self, guint n);
guint gedb_special_type_capacity (GedbSpecialType *self, guint8* a);
guint gedb_special_type_special_count (GedbSpecialType *self, guint8* addr);
guint8* gedb_special_type_base_address (GedbSpecialType *self, guint8* addr);
gchar* gedb_tuple_type_append_labeled_type_name (GedbTupleType *self, GedbField* field, const gchar* to);
GedbField* gedb_tuple_type_item_by_label (GedbTupleType *self, const gchar* name, GedbFeatureText* labeled, guint* n);
#define GEDB_AGENT_TYPE_open_operand_indicator '?'
#define GEDB_AGENT_TYPE_closed_operand_indicator '_'
gboolean gedb_agent_type_base_is_closed (GedbAgentType *self);
gboolean gedb_agent_type_base_is_open (GedbAgentType *self);
gboolean gedb_agent_type_valid_arg_index (GedbAgentType *self, guint pos);
gboolean gedb_agent_type_is_open_operand (GedbAgentType *self, guint pos);
gboolean gedb_agent_type_is_closed_operand (GedbAgentType *self, guint pos);
GedbType* gedb_agent_type_result_type (GedbAgentType *self);
GedbField* gedb_agent_type_last_result (GedbAgentType *self);
gchar* gedb_agent_type_append_name (GedbAgentType *self, const gchar* to);
guint8* gedb_agent_type_closed_operands (GedbAgentType *self, guint8* id);
guint8* gedb_agent_type_closed_operand (GedbAgentType *self, guint8* id, guint i);
GType gedb_stack_frame_get_type (void) G_GNUC_CONST;
GedbStackFrame* gedb_stack_frame_dup (const GedbStackFrame* self);
void gedb_stack_frame_free (GedbStackFrame* self);
guint gedb_stack_frame_line (GedbStackFrame *self);
guint gedb_stack_frame_column (GedbStackFrame *self);
void gedb_stack_frame_set_position (GedbStackFrame *self, gint l, gint c);
GedbType* gedb_stack_frame_target_type (GedbStackFrame *self);
guint8* gedb_target (GedbStackFrame* f);
guint gedb_c_ident (void* a);
void* gedb_c_new_object (void* call);
void* gedb_c_new_boxed_object (void* call);
void* gedb_c_new_array (void* call, guint n);
void gedb_c_call_create (void* call, void* obj);
extern GObject* dummy;


G_END_DECLS

#endif
