using GData;

public class Tests
{
static BindingPointer obj;
	public static void test_unref_pointer()
	{
		stdout.printf("test_unref_pointer()\n");
		obj = new BindingPointer();
		obj.weak_ref (() => {
			stdout.printf ("unref\n");
		});
		stdout.printf ("id=@%i\n", obj.id);
		obj = null;
		stdout.printf("test_unref_pointer().out\n");
	}

	public static void test_unref_contract()
	{
		stdout.printf("test_unref_contract()\n");
		BindingContract obj = new BindingContract();
		obj.weak_ref (() => {
			stdout.printf ("unref\n");
		});
		stdout.printf ("id=@%i\n", obj.id);
		obj = null;
		stdout.printf("test_unref_contract().out\n");
	}

	public static void main (string[] args)
	{
		Gtk.init (ref args);
		test_unref_pointer();
		test_unref_contract();
	}
}
