using Gtk;
using Gedb;

public class ExpressionChecker : Expander {

	private ComboBoxText? combo;
	private Label msg;
	private bool as_static;

	public bool do_filter_type_name(EntryCompletion compl, 
									string key, TreeIter iter, 
									System* s, TypeFilter? tf=null) {
		TreeModel model = compl.get_model();
		GLib.Regex regex;
		string name;
		uint tid;
		label = "";
		msg.set_markup("");
		expanded = false;
		model.@get(iter, TypeEnum.TYPE_NAME, out name, 
				   TypeEnum.TYPE_IDENT, out tid, -1);
		if (tf!=null && !tf(s.type_at(tid))) return false;
		try {
			regex = new GLib.Regex(key, GLib.RegexCompileFlags.CASELESS, 0);
			return regex.match(name);
		} catch (GLib.RegexError e) {
			string str, head, good, bad;
			int l, n;
			head = "Invalid REGEX";
			str = e.message;
			good = "expression ";
			bad = " at char ";
			l = str.index_of(good);
			n = str.index_of(bad); 
			if (l>=0 && n>=0) {
				head = "Regular expression error" + str.substring(n);
				l += good.length;
				n += bad.length;
				good = str.substring(n);
				l = int.parse(good);
				good = key.substring(0, l);
				bad = GLib.Markup.escape_text(key.substring(l));
				str = good + "<span foreground='red'>" + bad +"</span>";
				label = head;
				msg.set_markup(str);
				expanded = true;
				return false;
			}
		}
		return false;
	} 
	
	public ExpressionChecker() {
		use_markup = true;
		msg = new Label("");
		add(msg);
		msg.set_alignment(0.0F, 0.5F);
		msg.selectable = true;
		expanded = true;
		parser = new Eval.Parser();
	}

	public void reset() {
		parser.reset();
		parsed = null;
		label = "";
		msg.set_text("");
		expanded = false;
	}

	public void set_message(string head, string message) {
		label = head;
		msg.set_markup(message);
		expanded = true;
	}

	public Expression? parsed { get; private set; }

	public Expression? expression_at(int pos, bool with_range) { 
		if (parser==null)  return null;
		var val = parser.value_at(pos, with_range);
		return val!=null ? val.expr : null;
	}

	public Eval.Parser? parser;// {get; private set; }

	public bool check_syntax(string query, 
							 Gee.Map<string,Expression> list, System* s) {
		as_static = true;
		parser.init_syntax(s);
		parser.set_aliases(list);
		return check(query, parser, false);
	}

	public bool check_static(string query, uint tid, uint cid, uint pos, 
							 Gee.Map<string,Expression> list, System* s,
							 bool as_bool)
	requires (tid>0 || cid>0) {
		Gedb.Type* t = tid>0 ? s.type_at(tid) : null;
		if (cid==0 && t!=null && t.is_normal()) {
			var nt = (NormalType*)t;
			cid = nt.base_class.ident;
		}
		ClassText* ct = s.class_at(cid);
		RoutineText* rt = null;
		if (pos>0) {
			FeatureText* ft = ct.feature_by_line((int)pos/256);
			if (ft!=null && ft.is_routine_text())  rt = (RoutineText*)ft;
		}
		parser.init_typed(t, ct, rt, s, false);
		parser.set_aliases(list);
		as_static = true;
		return check(query, parser, as_bool);
	}

	public bool check_with_idents(string query, StackFrame* frame, System* s, 
								  Gee.Map<string,Expression> list,
								  Eval.IdentToExpression? func=null, 
								  Object? data=null) {
		parser.init_stack(frame, s);
		parser.set_aliases(list);
		parser.set_idents(func, data);
		as_static = false;
		return check(query, parser, false);
	}

	private bool check(string query, Eval.Parser parser, bool as_bool) {
		string str, head=null, good=null, bad=null;
		parser.add_string(query);
		parser.end();
		var res = parser.result;
		var val = parser.last_value;
		var failed = parser.last_token;
		var err = parser.error;
		int n;
		bool ok = false;
		if (res!=null) {
			ok = true;
			parsed = res.expr;
			var ex = res.expr;
			if (as_bool) {
				if (ex.next!=null || ex.range!=null || ex.detail!=null) {
					// issue warning
				}
				ex.cut_children(true);
				var b = ex.bottom();
				ok = b.base_class()._name.fast_name=="BOOLEAN";		
				if (!ok) {
					head = "<i>Result type is not </i><tt>BOOLEAN</tt>.";
					msg.set_markup("");
					parsed = null;
				}
			}
		} else {
			ClassText* ct = null;
			RoutineText* rt = null;	
			head = parser.not_unique ? "<i>Ambigous " : "<i>Unknown ";
			switch (err) {
			case Eval.ErrorCode.UNKNOWN:
				if (val!=null && val.expr!=null) 
					ct = val.expr.base_class();
				if (ct==null) {
					ct = parser.base_class;
					rt = parser.act_text;
				}
				if (ct!=null) {
					if (rt!=null) {
						head += "query/variable in current routine</i>";
/*
						head += "query/variable in </i><tt>";
						head += ct._name.fast_name;
						head += ".";
						head += rt._feature._name.fast_name;
						head += "</tt>";
*/
					} else {
						head += failed.name[0].isalnum() ? "query" : "operator";
						head += " in class </i><tt>";
						head += ct._name.fast_name;
						head += "</tt>";
					}
				} else {
					head += "</i>";
				}
				head += ":";
				break;
			case Eval.ErrorCode.NO_CLASS:
				head += "class name</i>:";
				break;
			case Eval.ErrorCode.NO_TUPLE:
				head += "TUPLE type</i>:";
				break;
			case Eval.ErrorCode.NO_ONCE:
				head += "once function or constant</i>:";
				break;
			case Eval.ErrorCode.NOT_INIT:
				head = "<i>Not yet initialized once function</i>:";
				break;
			case Eval.ErrorCode.NO_ALIAS:
				head += "alias name</i>:";
				break;
			case Eval.ErrorCode.NO_STACK:
				head = "<i>No actual stack</i>:";
				break;
			case Eval.ErrorCode.NO_IDENT:
				if (as_static) 
					head = "<i>Object idents not supported";
				else
					head += "object ident";
				head += "</i>:";
				break;
			case Eval.ErrorCode.BAD_PH_POS:
				head = "<i>Placeholder not allowed there</i>:";
				break;
			case Eval.ErrorCode.BAD_PH_COUNT:
				head = "<i>Too many placeholders</i>:";
				break;
			default:
				head = "<i>Parse error</i>:";
				break;
			}
		}
		if (ok) {
			label = "";
			msg.set_markup("");
			expanded = false;
		} else {
			parsed = null;
			label = head;
			good  = query.substring(0, failed.at);
			string html = GLib.Markup.escape_text(failed.name);
			bad = "<span foreground='red'>"+html+"</span>";
			str = good+bad+query.substring(failed.at+failed.size);
			msg.set_markup(str);
			expanded = true; 
		}
		return ok;
	}

	public void clear_message() {
		label = "";
		msg.set_markup("");
		expanded = false;
	}

	public void show_message(string head, string msg) {
		label = head;
		this.msg.set_markup(msg);
		expanded = true;
	}

	public delegate bool TypeFilter(Gedb.Type* t);

} /* ExpressionChecker */
