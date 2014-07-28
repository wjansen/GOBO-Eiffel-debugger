#include <inttypes.h>
typedef struct {int id;} T0;
extern typedef int32_t T6;
typedef struct {
  int id;
  T6 item;
  T0* left;
  T0* right;
} T75; /* BI_LINKABLE[INTEGER_32] */
typedef char T1;
typedef struct {
  int id;
  T0* active;
  T1 after;
  T1 before;
  T6 count;
  T0* first_element;
  T0* last_element;
} T31; /* TWO_WAY_LIST[INTEGER_32] */
typedef unsigned char T2;
typedef struct {
  int id;
  T6 count;
  T6 capacity;
  T2 item;
} T15; /* SPECIAL[CHARACTER_8] */
typedef struct {
  int id;
  T0* area;
  T6 count;
  T6 internal_hash_code;
} T17; /* STRING_8 */
typedef struct {
  int id;
  T6 count;
  T6 capacity;
  T0* item;
} T27; /* SPECIAL[STRING_8] */
typedef struct {
  int id;
  T0* area;
  T6 lower;
  T6 upper;
} T28; /* ARRAY[STRING_8] */
typedef double T13;
typedef struct {
  int id;
  T13 d;
  T6 n;
  T0* s;
} T26; /* EMB */
typedef struct {
  int id;
  T0* item_1;
  T0* item_2;
  T0* item_3;
  T26 item_4;
} T32; /* TUPLE[TWO_WAY_LIST[INTEGER_32],FUNCTION[ANY,TUPLE,INTEGER_32],ARRAY[STRING_8],EMB] */
T32 x1;
T32 x1={32,extern T31 x2;
extern typedef struct {
  int id;
  T0* ag;
  T0* array;
  T26 emb;
  T0* list;
} T21; /* TPC */
typedef struct {
  int id;
  T0* op_0;
  T0* op_1;
  T6 op_2;
} T217; /* agent TPC._0default_create(_) */
T217 x3;
extern T28 x4;
{26,3.1415926535897931,-99,extern T17 x5;
},};
T17 x5={17,(T0*)&x3,45,57,};
