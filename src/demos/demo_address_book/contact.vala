namespace DemoAddressBook
{
	[Flags]
	public enum WebFlags
	{
		HAS_ONLINE_PROFILE,
		HAS_WEBPAGE,
		HAS_ONLINE_BOOKMARKS,
		HAS_ALL = HAS_ONLINE_BOOKMARKS | HAS_ONLINE_PROFILE | HAS_WEBPAGE;
	}

	public enum EmploymentStatus
	{
		STUDENT,
		EMPLOYED,
		UNEMPLOYED,
		RETIRED
	}

	public enum Gender
	{
		MALE,
		FEMALE
	}

	public class Contact : Object
	{
		[Description (nick="First name", blurb="Enter first name")]
		public string first_name { get; set; default = ""; }

		[Description (nick="Middle name", blurb="Enter middle name")]
		public string middle_name { get; set; default = ""; }

		[Description (nick="Last name", blurb="Enter last name")]
		public string last_name { get; set; default = ""; }

		[Description (nick="Name", blurb="Full name")]
		public string full_name {
			owned get { return ("%s %s%s".printf(first_name, (middle_name != "") ? middle_name.substring(0,1) + ". " : "", last_name)); }
		}

		[Description (nick="Year of birth", blurb="Enter year of birth")]
		public int year_of_birth { get; set; default = 1980; }

		[Description (nick="Gender", blurb="Select gender")]
		public Gender gender { get; set; default = Gender.MALE; }

		[Description (nick="Employment status", blurb="Select employment status")]
		public EmploymentStatus employment_status { get; set; default = EmploymentStatus.EMPLOYED; }

		[Description (nick="Street", blurb="Enter street")]
		public string street { get; set; default = ""; }

		[Description (nick="House number", blurb="Enter house number")]
		public string house_number { get; set; default = ""; }

		[Description (nick="City", blurb="Enter city")]
		public string city { get; set; default = ""; }

		[Description (nick="Zip", blurb="Enter zip code")]
		public string zip { get; set; default = ""; }

		[Description (nick="Phone number", blurb="Enter phone number")]
		public string phone { get; set; default = ""; }

		[Description (nick="Website", blurb="Enter website")]
		public string website { get; set; default = ""; }

		[Description (nick="Website status", blurb="Select website status")]
		public WebFlags website_status { get; set; default = (WebFlags) ((uint) 0); }
		
		public Contact()
		{
			this.notify["first-name"].connect (() => { this.notify_property("full-name"); });
			this.notify["middle-name"].connect (() => { this.notify_property("full-name"); });
			this.notify["last-name"].connect (() => { this.notify_property("full-name"); });
		}
	}
}
