using GData;
using GData.Generics;

namespace Demo
{
	public class PersonInfo : Object, ObjectInformation
	{
		public int some_num { get; set; }

		public string get_info()
		{
			return ("some_num=%i".printf(some_num));
		}

		public PersonInfo (int num)
		{
			some_num = num;
		}
	}

	public class Person : Object, ObjectInformation
	{
		public string name { get; set; }
		public string surname { get; set; }
		public string required { get; set; }

		public PersonInfo info { get; set; }

		private Person? _parent = null;
		public Person? parent { 
			get { return (_parent); }
			set { _parent = value; }
		}

		public string get_info()
		{
			return (fullname());
		}

		public string fullname()
		{
			return ("%s %s".printf(name, surname));
		}

		public Person (string name, string surname, string required = "")
		{
			this.name = name;
			this.surname = surname;
			this.required = required;
			info = new PersonInfo((int) GLib.Random.int_range(1,10));
		}
	}

	private static ObjectArray<Person>? persons = null;
	private static Person? john_doe = null;
	private static Person? unnamed_person = null;

/*	public static ObjectArray<Person> persons {
		get {
			if (_persons == null)
				init_persons(); 
			return (_persons); 
		}
	}*/

	//TODO, Once RowModel is done, rebase it on that
	// ignore fucked up alignment until then as it will be fixed when moving
	// to row model
	public void bind_person_model (Gtk.ListBox listbox, GLib.ListModel model, BindingPointer pointer)
	{
		listbox.bind_model (model, ((o) => {
			Gtk.ListBoxRow r = new Gtk.ListBoxRow();
			r.set_data<WeakReference<Person?>>("person", new WeakReference<Person?>((Person) o));
			r.visible = true;
			Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
			box.visible = true;
			r.add (box);
			Gtk.Label name = new Gtk.Label("");
			name.visible = true;
			Gtk.Label surname = new Gtk.Label("");
			surname.visible = true;
			box.pack_start (name);
			box.pack_start (surname);

			// This would be much more suitable in this use case
			PropertyBinding.bind (o, "name", name, "label", BindFlags.SYNC_CREATE);
			PropertyBinding.bind (o, "surname", surname, "label", BindFlags.SYNC_CREATE);
			return (r);
		}));
		listbox.row_selected.connect ((r) => {
			pointer.data = (r != null) ? (r.get_data<WeakReference<Person?>>("person")).target : null;
		});
	}

	public static void init_demo_persons()
	{
		persons = new ObjectArray<Person>();
		persons.add (new Person("John", "Doe"));
		persons.add (new Person("Somebody", "Nobody"));
		persons.add (new Person("Intentionally_Invalid_State", "", "Nobody"));
		persons.data[0].parent = persons.data[1];
		persons.data[2].parent = persons.data[0];

		john_doe = new Person("John", "Doe", "ABC");
		unnamed_person = new Person("Unnamed", "Person", "DEF");
	}
}

