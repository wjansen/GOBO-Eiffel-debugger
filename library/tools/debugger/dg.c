#include <limits.h>

/* 
  Constant part of the system description. 
 */

extern GedbSystem* gedb_rts;
void* gedb_address_by_name(const char* name);

static int scope_limit = 0;
static int depth_limit = 0;
static int bp_depth = 0;

void gedb_init() {
#if GEDB_D == 1
  gedb_make_pma(GE_argv, GE_argc, gedb_address_by_name);
#else
  bp_depth = INT_MAX;
  depth_limit = 1;
  gedb_make_rta(&GE_argc, &GE_argv, gedb_address_by_name);
#endif
}

void* gedb_type(u_int32_t t_id) {
  return gedb_rts->all_types[t_id];
}

void gedb_field_offset(void* t, int off, u_int32_t f_id) {
  GedbType* type = (GedbType*)t;
  GedbField* field = type->fields[f_id];
  field->offset = off;
}

void* gedb_routine(u_int32_t t_id, u_int32_t r_id) {
  GedbType* t = gedb_rts->all_types[t_id];
  return t->routines[r_id];
}

void gedb_local_offset(void* r, int off, u_int32_t l_id) {
  GedbRoutine* routine = (GedbRoutine*)r;
  GedbLocal* local = routine->vars[l_id];
  local->offset = off;
}

void* gedb_inform1(int reason) {
#if GEDB_D == 2
  if (gedb_inter) gedb_inform(reason);
  switch (reason) {
  case -5: /* End_compound_break */
    return gedb_top->scope_depth<=scope_limit ? gedb_inform(reason) : 0;
  case -6: /* End_routine_break */
    return gedb_top->depth<=depth_limit ? gedb_inform(reason) : 0;
  default:
    return gedb_inform(reason);
  }
#endif
}

static void set_limits_(int d, int s) {
  depth_limit =  d;
  scope_limit = s;
}

#define TAB_SIZE 89
static u_int32_t bp_table[TAB_SIZE] = {0};
static int bp_table_size = 0;

int gedb_stop1(u_int32_t pos, int reason) {
  u_int32_t i, val, d;
  if (gedb_step || gedb_inter) return 1;
  d = gedb_top->depth;
  if (d<=depth_limit || d>=bp_depth) return 1;
  if (bp_table_size!=0) {
    i = pos % TAB_SIZE;
    val = bp_table[i];
    while (val!=0) {
      if (val==pos) return 1;
      ++i;
      i %= TAB_SIZE;
      val = bp_table[i];
    }
  }
  return 0;
}

static void* results_ = 0;
static void* markers_ = 0;

static void free_(void* p) {
#ifndef EIF_BOEHM_GC
  if (p) free(p);
#endif
}

static void* realloc_(void* p, size_t n) {
  if (n==0) (free_)(p);
  return GE_null(GE_realloc(p, n));
}

static void* jmp_buffer_() {
  return realloc_(0, sizeof(GE_jmp_buf));
}

static void longjmp_(void* buf, u_int32_t jmp) {
  GE_longjmp(*(GE_jmp_buf*)buf,jmp);
}

static void set_bp_pos_(int id, int l, int c) {
#if GEDB_D == 2
  u_int32_t i, pos, val;
  pos = id<<GEDB_IDSH | l<<GEDB_LSH | c;
  if (pos==0) { // clear table
    for (i=TAB_SIZE; i-->0;) bp_table[i] = 0;
    bp_table_size = 0;
    return;
  } else if (l==0) { // not a position but a depth
    bp_depth = id;
  }
  i = pos % TAB_SIZE;
  val = bp_table[i];
  while (val!=0) {
    ++i;
    i %= TAB_SIZE;
    val = bp_table[i];
  }
  bp_table[i] = pos;
  ++bp_table_size;
#endif
}

typedef enum {
  Subobject_flag = 1,
  Reference_flag = 2,
  Alive_flag = 3,
  Flexible_flag = 4,
  Memory_category_flag = 7,
  Basic_expanded_flag = 0x9,
  Tuple_flag = 0x10,
  Agent_flag = 0x20
} TypeFlags;

static void set_offsets_(void) {
  GedbSystem* rts = (GedbSystem*)gedb_rts;
  GedbField* f;
  GedbRoutine* r;
  GedbType* t;
  GedbType* dt;
  GedbOnce* o;
  GedbConstant* c;
  void** addr;
  GEIP_T* ext;
  GEIP_F* ext_f;
  size_t off;
  u_int32_t i, j, n=rts->all_types_length;
  u_int32_t fl;
  for (i=0; i<n; ++i) {
    t = rts->all_types[i];
    if (t==0) continue;
    fl = t->flags;
    ext = geip_t[i];
    if (fl & Flexible_flag) {
      t->class_name = "SPECIAL";
    } else if (fl & Tuple_flag) {
      t->class_name = "TUPLE";
    } else if (fl & Agent_flag) {
      t->class_name = "AGENT";
    } else {
      t->class_name = ((GedbName*)t->base_class)->fast_name;
    }
    if ((fl & Alive_flag)==0) continue;
    t->instance_bytes = ext->size;
    t->default_instance = ext->def;
    t->allocate = ext->alloc;
    if (fl & Subobject_flag) {
      GEIP_Tb* b = (GEIP_Tb*)ext;
      GedbExpandedType* et = (GedbExpandedType*)t;
      et->boxed_bytes = b->boxed_size;
      off = (size_t)b->subobject - (size_t)b->boxed_def;
      et->boxed_offset = (int)off;
    }
    if (fl & Agent_flag) { 
      GEIP_A* a = (GEIP_A*)ext;
      GedbAgentType* at = (GedbAgentType*)t;
      GedbType* cot = (GedbType*)at->closed_operands_tuple;
      if (t->fields_length>0) {
	j = cot->fields_length;
	if (j<t->fields_length) {
	  dt = (GedbType*)at->declared_type;				
	  off = dt->fields[2]->offset;
	  f = t->fields[j];
	  f->offset = (int)off;
	}
	for (j=cot->fields_length; j-->0;) {
	  f = t->fields[j];
	  off = cot->fields[j]->offset;
	  f->offset = (int)off;
	}
      }
      off = (size_t)a->call_field - (size_t)ext->def;
      at->function_offset = (int)off;
      at->call_function = a->call;
    } else {
      for (j=t->fields_length; j-->0;) {
	ext_f = &(ext->fields[j]);
	f = t->fields[j];
	off = (size_t)ext_f->def - (size_t)ext->def;
	f->offset = (int)off;
      }
      if ((fl & Flexible_flag)==0) {
	for (j=t->routines_length; j-->0;) {
	  r = t->routines[j];
	  r->call = ((GedbRoutine**)ext->routines)[j];
	}
      }
    }
  }
  for (i=rts->all_onces_length; i-->0;) {
    o = rts->all_onces[i];
    addr = geip_o+i;
    o->init_address = *(u_int8_t**)addr;
    addr = geip_ov+i;
    o->value_address = addr!=0 ? *(u_int8_t**)addr : 0;
  }
  for (i=rts->all_constants_length; i-->0;) {
    c = rts->all_constants[i];
    if (((GedbEntity*)c)->type->flags & Basic_expanded_flag) continue;
    addr = geip_ms+i;
    c->ms = addr!=0 ? *(u_int8_t**)addr : 0;
  }
}

static T2* chars_(void* obj, int* nc);
static T3* unichars_(void* obj, int* nc);
static void gedb_wrap_(EIF_NATURAL_32 i,void *call,void *C,void **args,void *R);

typedef struct { char* name; void* addr; } NamedAddress;

static NamedAddress addresses[] = {
  { "rts", &gedb_rts}, 
  { "top", &gedb_top}, 
  { "step", &gedb_step},
  { "inter", &gedb_inter},
  { "results", &results_}, 
  { "markers", &markers_}, 
  { "set_offsets", set_offsets_}, 
  { "wrap", gedb_wrap_}, 
  { "realloc", realloc_}, 
  { "free", free_}, 
  { "longjmp", longjmp_}, 
  { "jmp_buffer", jmp_buffer_}, 
  { "chars", chars_}, 
  { "unichars", unichars_}, 
  { "set_bp_pos", set_bp_pos_},
  { "set_limits", set_limits_},
  { "main", GE_main},
  { "raise", GE_raise},
  {0}
};

void* gedb_address_by_name(const char* name) {
  const char* ni;
  int i;
  for (i=0; ; ++i) {
    ni = addresses[i].name;
    if (ni==0) return 0;
    if (strcmp(name,ni)==0) return addresses[i].addr;
  }
  return 0;
}

/* 
  Eiffel system dependent part of the system description. 
 */
