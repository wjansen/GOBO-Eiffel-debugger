using Gtk;
using Gedb;

public class ExpressionChecker : Expander {

	private ComboBoxText? combo;
	private Label msg;
	private bool as_static;

	public bool do_filter_type_name(EntryCompletion compl, 
									string key, TreeIter iter, System* s) {
		TreeModel model = compl.get_model();
		GLib.Regex regex;
		string name;
		uint tid;
		label = "";
		msg.set_markup("");
		expanded = false;
		model.@get(iter, TypeEnum.TYPE_NAME, out name, 
				   TypeEnum.TYPE_IDENT, out tid, -1);
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
				show_message(head, good, key.substring(l));
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

	public Expression? parsed { get; private set; }

	public Expression? expression_at(int pos, bool with_range) { 
		if (parser==null) return null;
		var val = parser.value_at(pos, with_range);
		return val!=null ? val.expr : null;
	}

	public Eval.Parser? parser;// {get; private set; }

	public void set_placeholder_prefix(Gee.List<Expression> prefix) { 
		parser.set_prefix(prefix);
	}

	public bool check_syntax(string query, System* s,
							 Gee.Map<string,Expression>? alias=null, 
							 Gee.List<Expression>? prefix=null) {
		as_static = true;
		parser.init_syntax(s);
		parser.set_aliases(alias);
		parser.set_prefix(prefix);
		return check(query, parser, false);
	}

	public bool check_static(string query, uint cid, uint pos, System* s,
							 bool as_bool,
							 Gee.Map<string,Expression>? alias=null, 
							 Gee.List<Expression>? prefix=null)
	requires (cid>0) {
		ClassText* ct = s.class_at(cid);
		RoutineText* rt = null;
		if (pos>0) {
			FeatureText* ft = ct.feature_by_line((int)pos/256);
			if (ft!=null && ft.is_routine()) rt = (RoutineText*)ft;
		}
		parser.init_text(ct, rt, s);
		parser.set_aliases(alias);
		parser.set_prefix(prefix);
		as_static = true;
		return check(query, parser, as_bool);
	}

	public bool check_dynamic(string query, 
							  Gedb.Type* home, StackFrame* f, System* s, 
							  bool to_compute,
							  Gee.Map<string,Expression>? alias=null,
							  Gee.List<Expression>? prefix=null,
							  Eval.IdentToExpression? id_func=null, 
							  Object? data=null) {
		parser.init_typed(home, f, s, to_compute);
		parser.set_aliases(alias);
		parser.set_idents(id_func, data);
		parser.set_prefix(prefix);
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
					head = "<i>Invalid object ident";
				head += "</i>:";
				break;
			case Eval.ErrorCode.BAD_PH_POS:
				head = "<i>Placeholder not allowed there</i>:";
				break;
			case Eval.ErrorCode.BAD_PH_COUNT:
				head = "<i>Too many placeholders</i>:";
				break;
			case Eval.ErrorCode.NOT_COMPUTED:
				head = "<i>Not computable</i>:";
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
			show_message(head, 
						query.substring(0, failed.at), 
						failed.name, 
						query.substring(failed.at+failed.size));
		}
		return ok;
	}

	public void clear_message() {
		label = "";
		msg.set_markup("");
		expanded = false;
	}

	public void show_message(string head, string good, 
							string? bad=null, string? rest=null) {
		label = head;
		string str = GLib.Markup.escape_text(good);
		if (bad!=null) {
			str += "<span foreground='red'>"; 
			str += GLib.Markup.escape_text(bad);
			str += "</span>";
		}
		if (rest!=null) 
			str += GLib.Markup.escape_text(rest);
		msg.set_markup(str);
		expanded = true;
	}

	public delegate bool TypeFilter(Gedb.Type* t);

} /* ExpressionChecker */
