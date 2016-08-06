using GData;
using Demo;

public class Tests
{
	static BindingPointer obj;

	private static void method(string method_name, string parameters = "", bool start = true)
	{
		stdout.printf ("%sMethod: %s(%s)\n", (start == false) ? "End " : "", method_name, parameters);
	}

	private static void method_end(string method_name, string parameters = "", bool start = true)
	{
		method(method_name, parameters, false);
	}

	private static string _get_ptr_str (BindingPointer? pointer)
	{
		return ((pointer == null) ? "null" : "id=@%i".printf(pointer.id));
	}

	private static string __get_ptr_str (StrictWeakRef pointer)
	{
		return (_get_ptr_str(as_pointer(pointer.target)));
	}

	private static string _int_equal (string text, int i1, int i2)
	{
		return ("[%s/%s]=>%i(exp:%i) ".printf (text, ((i1 == i2) ? "PASS" : "FAIL"), i1, i2));
	}

	private static void info (string text)
	{
		stdout.printf ("-> %s\n", text);
	}
	private static void test_reference (StrictWeakRef pointer, int expected_ptr_count, int expected_data_count, int expected_source_count)
	{
		int pointer_ref_count, data_ref_count, source_ref_count;
		_get_reference_count (pointer, out pointer_ref_count, out data_ref_count, out source_ref_count);
		stdout.printf ("\tReference test(%s) ", __get_ptr_str(pointer));
		stdout.printf ("%s", _int_equal ("ptr", pointer_ref_count, expected_ptr_count));
		stdout.printf ("%s", _int_equal ("data", data_ref_count, expected_data_count));
		stdout.printf ("%s\n", _int_equal ("src", source_ref_count, expected_source_count));
		assert (pointer_ref_count == expected_ptr_count);
		assert (data_ref_count == expected_data_count);
		assert (source_ref_count == expected_source_count);
	}

	public static void ref_pointer (BindingPointer? ptr)
	{
		ptr.weak_ref (() => {
			stdout.printf ("\tunref pointer(id=@0)\n");
		});
	}

	public static void test_unref_pointer()
	{
		string _METHOD_ = "test_unref_pointer";
		method(_METHOD_);
		obj = new BindingPointer();
		ref_pointer (obj);
		info ("basic pointer");
		StrictWeakRef wr = new StrictWeakRef(obj);
		test_reference (wr, 1, -1, -1);
		info ("hold");
		obj.hold(obj);
		test_reference (wr, 2, -1, -1);
		info ("storage.add");
		PointerStorage.get_default().add ("my_pointer", obj);
		test_reference (wr, 3, -1, -1);
		info ("storage.remove");
		PointerStorage.get_default().remove ("my_pointer");
		test_reference (wr, 2, -1, -1);
		info ("release");
		obj.release(obj);
		test_reference (wr, 1, -1, -1);
		obj = null;
		method_end(_METHOD_);
	}

	public static void test_unref_contract()
	{
		string _METHOD_ = "test_unref_contract";
		method(_METHOD_);
		BindingContract obj = new BindingContract();
		ref_pointer (obj);
		info ("basic contract");
		StrictWeakRef wr = new StrictWeakRef(obj);
		test_reference (wr, 1, -1, -1);
		info ("hold");
		obj.hold(obj);
		test_reference (wr, 2, -1, -1);
		info ("storage.add");
		PointerStorage.get_default().add ("my_pointer", obj);
		test_reference (wr, 3, -1, -1);
		info ("storage.remove");
		PointerStorage.get_default().remove ("my_pointer");
		test_reference (wr, 2, -1, -1);
		info ("release");
		obj.release(obj);
		test_reference (wr, 1, -1, -1);
		obj = null;
		method_end(_METHOD_);
	}

	public static void main (string[] args)
	{
		Gtk.init (ref args);
		test_unref_pointer();
		test_unref_contract();
	}
}

