# Data binding library in Vala (GLib)

[Main project and documentation page](https://therebedragons101.github.io/g_data_binding_lib/)

**Scroll down for videos and screenshots**

License (GPL/LGPL)

**IMPORTANT!
Currently there is a bug in Vala that needs patch in order to compile
https://bugzilla.gnome.org/show_bug.cgi?id=769903 or anything related to flags
just crashes application

To get as simple and best possible overview running "demo_and_tutorial" is
probably by far best method as tutorial not only shows how to do bindings,
it also taps into innards to visually represent whole design. Difference in
needed time to understand logic by looking at tutorial (Note that demo
consists of following**
- Demo page where everything is thrown into your face (Demo). This is 
  not the page where one would want to learn from, its only purpose is 
  showing HOW MUCH CAN ONE SINGLE LINE MEAN gui wise when mapping is done
  well
- Demo map - picture representing mapping on Demo page
- Tutorial (basic usage)
       NOTE THAT BASIC IS FAR FROM BASIC. BASIC IS USED AS FAR AS IMPLEMENTATIONS
       IN DEMO GO THIS IS MOST VALUABLE LEARNING POINT AS IT EXPLAINS EVERYTHING
       STEP BY STEP AND VISUALLY SHOWS INTERNALS IN ORDER TO BE REALLY EASY TO
       UNDERSTAND
- Rest of demo and tutorial is still on TODO
- Note that demo seems simple, but it is absolute nightmare scenario of
  crosslinking and multi edit access that can be encountered. Whole demo only
  deals with 3 person objects, where they also contain parent relationships

**HOW TO COMPILE/RUN DEMO AND TUTORIAL**

The demo/tutorial is a fully working GTK+ front end showing how g_data_binding_lib can be used, with code snippets and API documentation.

Binding inspector in action (inspecting demo, no code is necessary for this)
**click on screenshot to see video**
[![ScreenShot](https://github.com/therebedragons101/g_data_binding_lib/blob/master/src/demos/demo_and_tutorial/inspector-screenshot.png)](https://youtu.be/ua8IgmbfRqA)
- still missing things (full source map draw)

Object inspector in action (inspecting demo, no code is necessary for this and if wanted can be usable for any purpose since it can be extended in any way)
**click on screenshot to see video**
[![ScreenShot](https://github.com/therebedragons101/g_data_binding_lib/blob/master/src/demos/demo_and_tutorial/object-inspector-screenshot.png)](https://youtu.be/d9vSbwbvdBI)

Demo in action
**click on screenshot to see video**
[![ScreenShot](https://github.com/therebedragons101/g_data_binding_lib/blob/master/src/demos/demo_and_tutorial/screenshot.png)](https://youtu.be/wh50UUniBk0)

```bash
cd src
make
./run_demo_and_tutorial.sh
# note last step is temporarily hackish and requires to be run when in src
# This is it and build should produce
#             - shared library g_data_bindings_libX 
#                    for g-object-introspection and for use everywhere
#                    only depends on GLib
#             - shared library g_data_bindings_generics_libX 
#                    provides extended capabilities for use with vala
#                    only depends on GLib
#             - shared library g_data_bindings_gtk_libX
#                    for g-object-introspection and for use everywhere
#                    depends on GLib and Gtk
#             - vapi file
#             - c header
#             - gir file
#             - typedir file (bugged out until all generics are moved out)
#             - demo_and_tutorial
```

- Property binding is now more or less near 100% complete and this is time for
  0.2 release which will focus mainly on row bindings (active and inactive)

NOTE! at this stage i would strongly advise running demo and look trough its
tutorial as this aproach takes very different and unique way.
i will most pobably will just ignore people if i detect that they talk about
something different and they lack understanding the basic direction of this
project

TODO

- Row models

- Binding loader and designer like Glade (not gui, just mappings. Glade is
  pretty much everything needed)

- Advanced binding demos

- Fix comments in demo

What is handled?

Beside the obvious as having single place to rebind same widgets to new
source object this also handles most corner case scenarios that show up once
you really dig into databinding application design

NOTE! You shoud run demo before coming to conclusions

- PropertyBinding which is upgraded GBinding that allows missing features
  in GBinding: FLOOD_DETECTION, MANUAL_UPDATE, REVERSE_DIRECTION and INACTIVE
  and DELAYED
  This will now enable simple implementation of better BindingPointer
  extensions. (Inclusion in BindingInformation is still on TODO list)

- Binding flood detection (optional and disabled by default). When enabled it
  can detect flood of data change per property so it doesn't spam GUI redraw
  (Look at demo>Tutorial(Binding)>Basic binding for example of implementation
  as well as code example). (Flood relay to contract example is still on
  TODO)

- MANUAL binding update (optional and disabled by default). Does nothing but
  disables default property notify binding and waits for update_from_source()
  and update_from_parent() to be triggered. This enables custom refresh, but
  more importantly it makes BindingPointer MANUAL_UPDATE really viable
  (BindingPointer still needs to include this, TODO) (Look at
  demo>Tutorial(Binding)>Basic binding for example of implementation as well
  as code example)

- REVERSE direction support. While useless by it self in PropertyBinding,
  this comes in play when taken from group view where you sometimes need
  different direction of data flow for certain binding and this just removes
  need for extra contract that would be needed otherwise. It also controls
  direction of SYNC_CREATE

- INACTIVE provides access to current state of binding.

- freeze()/unfreeze() where freeze(bool) can specify hard or soft unfreeze 
  depending on what is more suitable. soft freeze just avoids processing
  of notifications, while hard freeze disables signals temporarily until
  unfreeze(). After unfreeze binding processes SYNC_CREATE again if 
  specified

- DELAYED property binding allows binding where updates are throtled.
  example case for that is search functionality where it is better to 
  apply delay after each update in order to remove as many events as
  possible

-- end of PropertyBinding --

- Binder class which is used to define PropertyBinding creation for different
  purposes or just to enable debugging of data flow in easy way. (Binder is
  still on TODO list as far as inclusion in contract goes)

- Binding pointers can specify how data they point to is handled. By default
  they are set to PROPERTY

- BindingPointerFromPropertyValue handles one of pointer relay options. It
  handles case where source needed is not actual object, but rather its
  property which makes it available to create complex data maps

- Group handling of bindings handled by locking. If specified binding 
  information already exists, it increments lock counter which makes it safe
  to have overlapping BindingInformationInterface between groups without
  worry

- Control over who is keeping objects alive. BindingContract by default uses
  BindingReferenceType.WEAK which means that it is up to application to keep
  objects alive and in this case not single reference is installed. For
  cases where one needs to bind to weak objects BindingContract can be
  created with BindingReferenceType.STRONG which causes BindingContract to
  install hard reference on source object which keeps it alive until either
  contract is destroyed or contract changes its binding source

- Temporary contract suspending where contract disbands all its bindings to
  widgets until suspending is out of effect

- Source validation tracking with BindingContract.is_valid where each added
  binding can specify its own case for its value validity and then adjust
  BindingContract.is_valid to represent cumulative state of that source
  object so application only needs to bind to that. Note that validation is
  based on "per-property" specifications on contract, not global. There is
  a high possibility that is_valid requirements are not the same for all
  contracts that connect to same object with same conditions. Global check
  is simply not needed as it is much better to use custom state object for
  that purpose. Making it available on contract would just clutter API, while
  "per-property" also just makes sense when it is considered bindings can be
  added/removed on the fly and at the same time always keep perfect condition

  Usage example:
  binding Apply button "sensitive" to contract for whole lifetime of window 
  no matter how source object changes. As such it is just normal to simply 
  use PropertyBinding without slightest care. 

- Complete required notification mechanism for creation of "rebuild-per-case"
  scenario as when source changes first one being dispatched is 
  "before_source_change" which provides type equality of current and next
  source as well as reference for next source. This signal is followed by
  "source_changed" which means contract at this point already points to 
  new source object. The fact that application can be aware of next type
  makes it easy to either drop/rebuild or just leave the widgets and bindings
  without any unnecesary flickering or strain. Contract it self also provides
  "contract-changed" which is triggered when bindings are added/removed to
  the contract

  Usage example:
  Property editor like functionality where whole contents and widgets get
  replaced by contents that are related to new source object. While rebuild
  per case needs similar interaction as without data binding (drop
  widgets/create widgets) case for this is simple. Application can take
  consistent approach no matter what and there are reliable notifications it
  can rely on  

- Availability of chaining contracts as source object where object being
  bound to is not contract, but rather source object it points to or in
  case of multiple chaining... source of last link in the chain. This it
  self will come even more in play with BindingSubContract (WIP).
  BindingSubContract will serve as redirection to particular data inside
  source object and it allows application to design whole databinding 
  pipeline as predictable plan as well as makes it possible to integrate
  it in Glade or similar application that is designed to plan data binding
  pipeline across the application

- Availability of using manager objects to handle/group contracts by name so
  application can avoid tracking references. This guarantees that contract
  will always have minimal reference count which will be dropped as soon
  as contract is removed

- This said, PropertyBinding becomes really functional when application
  follows correct design path. Using contracts where data changes and using
  bind_property where it doesn't.

  Usage example:
  If you bind_model to list_box data object will be fixed. In this case it
  is much more appropriate to use PropertyBinding when creating widgets trough
  model as it will be much more efficient than applying contract for each
  item

- Each contract has default_target as well as custom targets per binding.
  The distinction is in what job binding contract will entail. There are
  two kinds of bindings that contract can offer. One is binding with GUI,
  second is creating contract between two objects and multiple properties.
  In both cases source is the same, while target won't be. In case of GUI
  most probably there will be different widgets as target objects, while
  in object<>object contract, both will be kept the same. In second case
  it is much more beneficial if target can have same single point of handling
  as source does.

  This is why BindingContract offers bind(...) and bind_default(...).
  bind(...) offers specification of custom target per binding, while
  bind_default(...) always points to default target which is stored as
  BindingPointer and as such contains all the messaging requirements to
  automatically rebind to correct target that can be set at anytime with
  default_target property in BindingContract.

  This design offers having simplified complex pipeline with least amount
  of contracts. Note that specifiying same target as default_target with
  bind(...) does not result same as calling bind_default(...) because that
  would remove ability to refer to one object as stable and moving target
  per need.

  NOTE! default_target is just convenience over creating
  ContractedBindingPointer and then setting it as target in all bind calls
  made per contract. Only difference is that application code will be much
  less readable

NOTE! Up from here is handling of corner scenarios that always prove to be
the most annoying missing part for real usage. Main problem is that they only
become obvious when one has done data binding extensively in real world use
and had a serious thought about the problem

Availability of state/value objects on binding source
=====================================================

Main case for both is having stable fixed points of connection to binding
sources reflecting changes in order to simplify binding for stable parts
of GUI/application 

- State objects are simple case of bool value where value represents state
  of specified condition per binding source. State is not only reflected when
  source changes, it can also specify which property notifications to connect
  to in order to provide accurate state. In this case PropertyBinding
  can be reliably used to have it as fixed and stable point of application

  Usage example:
  Much like previously described validation with apply, this enables imposing
  custom conditions like being able to set visible/sensitive to certain
  widgets when Person is male or female or something similar.

- Value objects are much like state objects with 2 differences. One is that
  they can represent any value type which comes with a little more complexity
  as in order to know how to check if value has changed application must
  specify CompareFunc or handle notification internally in value assignment.
  Another difference is that they allow for live resoving without caching of
  value which effectively removes the need to specify property change
  notifications value depends on

 * - Add safe pointing to it self in BindingPointer

 * NOTE! While state and value objects are very similar, it still makes sense
 * to differentiate between them as setting state has much simpler API and more
 * fixed requirements than custom value. One could as well always just create
 * value objects <bool> and treat them as such, only differnce is simplicity and
 * readability of code in application.

This is all in one file for the moment only because it is simpler to hack on
it this way. Normally, this would be separated.
