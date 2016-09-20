# Data binding library in Vala (GLib)

[Main project and documentation page](https://therebedragons101.github.io/g_data_binding_lib/)

**Scroll down for videos and screenshots**

License (GPL/LGPL)

**IMPORTANT!
Currently as of 0.32 there is a bug in Vala that needs patch in order to compile
https://bugzilla.gnome.org/show_bug.cgi?id=769903 or anything related to flags
just crashes application. Patch is now upstream, but it will only take effect in
next release. (It should probably be noted that since this is a vapi patch it
doesn't require new vala, all that is needed is editing that api file in your
version of vala)

To get as simple and best possible overview running "demo_and_tutorial" is
probably by far best method as tutorial not only shows how to do bindings,
it also taps into innards to visually represent whole design. Difference in
needed time to understand logic by looking at tutorial (Note that demo
consists of following**
- Demo page where everything is thrown into your face (Demo). This is 
  not the page where one would want to learn from, its only purpose is 
  showing HOW MUCH CAN ONE SINGLE LINE MEAN gui wise when mapping is done
  well
- Links to Documentation for the topic, both API and explanation
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

Another way to delve into it as fast as possible is going with step-by-step
examples which are as well part of this project

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
#             - step_by_step examples
#             - API documentation
#             - documentation website
```

- Property binding is now more or less near 100% complete and this is time for
  0.2 release which will focus mainly on row bindings (active and inactive)

NOTE! at this stage i would strongly advise running demo and look trough its
tutorial as this aproach takes very different and unique way.
i will most pobably will just ignore people if i detect that they talk about
something different and they lack understanding the basic direction of this
project
