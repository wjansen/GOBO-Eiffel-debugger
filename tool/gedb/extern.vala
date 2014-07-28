public delegate void* ReallocFunc(void* orig, size_t n);
public delegate void FreeFunc(void* orig);
public delegate void WrapFunc(uint i, void *call, void* C, void** args, void* R);
public delegate weak unichar[] UnicharsFunc(void* obj, int *nc);
public delegate weak uint8[] CharsFunc(void* obj, int *nc);

public ReallocFunc realloc_func;
public FreeFunc free_func;
public WrapFunc wrap_func;
public CharsFunc chars_func;
public UnicharsFunc unichars_func;

public void** eif_results;
