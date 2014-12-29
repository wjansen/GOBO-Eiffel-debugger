using Gedb;

public interface ComputeEnviron : Object {

	public abstract StackFrame* frame();
	public abstract System* system();

	public abstract void compute(Expression ex, bool with_parent=false)
	throws ExpressionError ;

	public abstract string format(Expression ex, bool ranges, uint fmt)
	throws ExpressionError ;

}
