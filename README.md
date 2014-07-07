oschema - an XSD schema to validate OSC unit descriptions
---------------------------------------------------------

* http://htmlpreview.github.io/?https://raw.github.com/7890/oschema/master/doc/oschema.html

* http://htmlpreview.github.io/?https://raw.github.com/7890/oschema/master/doc/oschema.svg


```
oschema (OSC Schema, 'oskima') is a proposal for a set of 
tools to to describe OSC units in a standardized way.

A unit in this context is commonly software, a program. 
Hardware devices are also included as subject to describe.

Why describe? Every program already has that (separately)?

If we can create a reasonable standard for the markup of 
OSC capabilities and communication interaction models 
that is able to describe all aspects of interest in a common 
machine readable language, every particle in the ecosystem 
will benefit.

There was a time... when you had that synth or sound 
module with MIDI and on the later pages of the user or 
owner manual, there was (or still is) the MIDI implementation 
chart (or similar). And MIDI has already considered back then 
ways to extend the standard and send custom data. 
However the MIDI domain is easier to overview than OSC 
due to the 0-127 nature and some given controller numbers 
and instrument mappings.

The current initiative does not try to limit OSC 
to a set of commands, but rather keeping the freedom 
OSC offers to define interaction models and "just" 
describe that in a standardized way.

The real work is to create instances of documentations 
for all these great programs that in some sort provide 
OSC control, being OSC controllers or other useful tools 
in the domain.

Since there are similarities in the definition of APIs 
(function/method name, parameters, datatypes basically) it 
will be possible to take advantage of existing structured 
documents or derivates thereof. One example to note are LV2 
turtle .ttl files.

Examples of useful outputs in a scenario from definition to prototype 
to C code:

              (to be)
 My Device (OSC wrapped) | described as oschema doc (XML) --- validated
 ________________________|           |
                                     |
             Transform  --->         \. generated HTML doc
             using reliable          \. text (manpage, plain / asciidoc-like)
             data from one           \. code skeletons
             source file to create   \. -for the unit
             desired output format   \. -for the counterpart (inverted directions)
                                     \. JavaScript prototyping (*1)
                                     \. C skeletons using liblo (the real thing)

*1) With your favourite OSC js "node". See also https://github.com/7890/oscc

The oschema XSD schema should not restrict the expression 
of the API. It helps to keep a common structure for the benefit 
of a chain of post processing. XSL transformations and other 
techniques to work on XML files are ready to get the desired 
result; that is, for all valid oschema instances!

oschema is flexible enough to leave things out or be more 
precise in other areas yet it is relatively strict in the 
validation of element nesting, values and "inter-value" semantics.
This is necessary for processes that work on the instance 
documents. A validated instance can be processed more relaxed, 
rely on certain structural rules and semantics. This means many 
of the assert and verify code that would be needed for a 
moderately stable process is now outsourced to a validation 
process using the schema.

Please note, oschema per se doesn't have any GUI specific 
information attached. It aims to cover all the API 
aspects that make up the OSC functionality of the program.

For the GUI-side of things, where buttons, rotary knobs, 
sliders, selection boxes etc. are of interest, it is obvious 
that a seperate GUI centric definition must be used that 
should not mix with the model (if we believe in the model/view 
principle (does it really *work*?))

An oschema instance document plus a "recipe" will make up 
all the necessary artefacts for the things needed in-between 
the GUI and the model or even directly by the GUI.

Example:
                          program, API, model
 GUI -------------------- described as oschema doc (XML) --- validated
              |                                   /
              |                                  /  generate intermediary with
   intermediary knowing GUI centric, model centric              "receipe"
 (can keep state for dumb GUIs, add abstract GUI functions)     (GUI centric)


Please note, oschema is just the schema and some related 
documentation and does not include any of those output 
formatters. The only existing output format (as of today in 
July 2014) is oscdoc (see https://github.com/7890/oscdoc). 
oscdoc just takes any valid oschema instance and 
creates a HTML page that includes a simple search facility 
on OSC message patterns and displays the contents in a 
per-message view, showing all parameters, ranges, descriptions, 
restrictions and custom data.

Workflow, Chains

1) Write the osctool.xml for unit. See examples and oschema 
   documentation to get started. Please ask if anything 
   is missing or unclear.

2) Validate

               .--- extended tests on xml, using xslt / other
.___         _/ 
| osctool.xml  \
.--            |--- validate xml against xsd
              /              
 oschema.xsd .               -> valid or invalid
                             -> hints on error are given
.______________________
|me@wheel:~/oschema$ oschema_validate osctool.xml
|#choose a better name for the xml file
.---------------------

(No artefacts)


3) Use *any* of the available post-processing chains for 
   oschema docs. Hum, there is currently just *oscdoc* that 
   does that.


               .--- add additional resources for HTML
.___         _/ 
| osctool.xml  \
.--            |--- xsl transform
              /
   index.xsl .
   oschema2html.xsl          -> Easy integration to existing project
                             -> Small distributable
.______________________
|me@wheel:~/oscdoc$ make.sh
|...
.---------------------

Artefacts: index.html, resources folder containing referenced 
css, js etc.
```
