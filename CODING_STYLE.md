Few coding rules for this project

# Conditions

Conditions MUST always be full and separated into lines, code is longer
but in long term it is far easier to read. As such this is accepted
```csharp
	if (((myvar == true) ||
	     (myvar2 < 4)) &&
	    (myvar3 == "something"))
```

it is all well and swell that one can fit as much as possible in one 
line, but to read that after some time or if this is code from someone
else... pure nightmare




# Properties (only properties with simple declaration)

Declaration of property in form of 
```csharp
    public int myvar { get; private set; default = 0; }
```
or
```csharp
    public int myvar { get; set; default = 0; }
```
is not allowed unless property fullfils two conditions. 
- is not used frequently
- notify signal is always wanted

This generates much less efficient code than
```csharp
    private int _myvar = 0;
    public int myvar {
        get { return (_myvar); }
    }
```
and at the same time it is easy to control when notification is 
dispatched since this requires manual call to notify_property()
since this declaration only allows assignment trough _myvar which
when compiled to c generates direct assignment one liner

second example
```csharp
	private int _myvar = 0;
	public int myvar {
		get { return (_myvar); }
		set { _myvar = value; }
	}
```
is again much better code as it allows full control of what is 
happening underneath and how. at this point reading and writing
data from _myvar 
```csharp
	_myvar =+_myvar;
```
will be much faster while not dispatching property notifications.

when dispatching property notification is wanted then
```csharp
	myvar += _myvar;
```
is required. This guarantees that produced code will be as 
efficient as possible.




# Weak references

weak is not really tractable as well as it can be annoying to
maintain

instead WeakReference<T> or StrictWeakReference<T> should be
used. not only they allow use in persistent hashing, they are
also always available

differences between WeakReference<T> and StrictWeakReference<T>

WeakReference does not track validity while StrictWeakReference
does. once object is unrefed WeakReference can still point at
now non existent object, while StrictWeakReference tracks that
and at that point its "target" is automatically set to null.
Other thing that StrictWeakReference allows is default and 
maintained connection to targets weak_unref where it allows to
specify handler on creation.




# Tab and space use

Tabs are must. When line is split in more than one like some if
condition then Tabs can only be until if start and then followed
by spaces. This guarantees correct showing no matter the tab or
space settings

Correct use of spaces
```csharp
[tab]void method()
[tab]{
[tab][tab]if ((somecondition == true) ||
[tab][tab]    (othercondition == true))
[tab][tab][tab]execute_this();
```

By using spaces and tabulators in this way it is guaranteed to look
correctly no matter what kind of setting editor has. Tabs only suck
because people don't combine them with spaces correctly. The other
side of saying "screw tabs" and go with spaces only is just about
as bad as improper tab use.


# Strings

Avoid
```csharp
str = @"$myvar some text $myvar"
```
use
```csharp
str = "%s some text %s".printf (myvar, myvar);
```

as it is much more readable.
