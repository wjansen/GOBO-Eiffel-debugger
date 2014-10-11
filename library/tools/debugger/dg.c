/* 
  Constant part of the system description. 
 */

extern GedbSystem* GE_zrts;

void* GE_zresults = 0;
void* GE_zmarkers = 0;
GE_jmp_buf GE_zbuf0;

void* GE_zroutine(int t_id, int r_id) {
  GedbType* t = GE_zrts->all_types[t_id];
  return t->routines[r_id];
}

void GE_zlocal_offset(void* r, int off, int l_id) {
  GedbRoutine* routine = (GedbRoutine*)r;
  GedbLocal* local = routine->vars[l_id];
  local->offset = off;
}

static void free_(void* p) {
#ifndef EIF_BOEHM_GC
  if (p) free(p);
#endif
}
void (*GE_zfree)(void*) = free_;

static void* realloc_(void* p, size_t n) {
  if (n==0) (free_)(p);
  return GE_null(GE_realloc(p, n));
}
void* (*GE_zrealloc)(void*, size_t) = realloc_;

static void* jmp_buffer_() {
  return (GE_zrealloc)(0, sizeof(GE_jmp_buf));
}
void* (*GE_zjmp_buffer)() = jmp_buffer_;

static void longjmp_(void* buf, int jmp) {
  GE_longjmp(*(GE_jmp_buf*)buf,jmp);
}
void (*GE_zlongjmp)(void*,int) = longjmp_;

void* GE_ztype(int t_id) {
  return GE_zrts->all_types[t_id];
}

void GE_zfield_offset_(void* t, int off, int f_id) {
  GedbType* type = (GedbType*)t;
  GedbField* field = type->fields[f_id];
  field->offset = off;
}

static T2* chars_(void* obj, int* nc) {
  *nc = 0;
  if (obj==0) return 0;
  if (*(int*)obj!=17) return 0;
  if (((T17*)obj)->a1==0) return 0;
  *nc = ((T17*)obj)->a2;
  return ((T15*)((T17*)obj)->a1)->z2;
}
T2* (*GE_zchars)(void*,int*) = chars_;

static T3* unichars_(void* obj, int* nc) {
  *nc = 0;
  if (obj==0) return 0;
  if (*(int*)obj!=18) return 0;
  if (((T18*)obj)->a1==0) return 0;
  *nc = ((T18*)obj)->a2;
  return ((T16*)((T18*)obj)->a1)->z2;
}
T3* (*GE_zunichars)(void*,int*) = unichars_;

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

void set_offsets_(void) {
  GedbSystem* rts = (GedbSystem*)GE_zrts;
  GedbField* f;
  GedbRoutine* r;
  GedbType* t;
  GedbType* dt;
  GedbOnce* o;
  GedbConstant* c;
  void** addr;
  GE_ZT* ext;
  GE_ZF* ext_f;
  size_t off;
  u_int32_t i, j, n=rts->all_types_length;
  u_int32_t fl;
  for (i=0; i<n; ++i) {
    t = rts->all_types[i];
    if (t==0) continue;
    fl = t->flags;
    ext = GE_zt[i];
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
      GE_ZTb* b = (GE_ZTb*)ext;
      GedbExpandedType* et = (GedbExpandedType*)t;
      et->boxed_bytes = b->boxed_size;
      off = (size_t)b->subobject - (size_t)b->boxed_def;
      et->boxed_offset = (int)off;
    }
    if (fl & Agent_flag) { 
      GE_ZA* a = (GE_ZA*)ext;
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
    addr = GE_zo+i;
    o->init_address = *(u_int8_t**)addr;
    addr = GE_zov+i;
    o->value_address = addr!=0 ? *(u_int8_t**)addr : 0;
  }
  for (i=rts->all_constants_length; i-->0;) {
    c = rts->all_constants[i];
    if (((GedbEntity*)c)->type->flags & Basic_expanded_flag) continue;
    addr = GE_zms+i;
    c->ms = addr!=0 ? *(u_int8_t**)addr : 0;
  }
}
void (*GE_zset_offsets)(void) = set_offsets_;

void * GE_zmake_gedb() {
  int pma = 0;
#if ( GedbD == 2 )
  GE_zmake_gedb();
#else
  pma = 1;
  GE_zmake_pma(GE_argv, GE_argc, GE_zrts, &GE_ztop, &GE_zresults, 
	       set_offsets_, realloc_, free_, chars_, unichars_);
#endif
}

/* 
  Eiffel system dependent part of the system description. 
 */
