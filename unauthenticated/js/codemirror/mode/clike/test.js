!function(){function e(e){test.mode(e,r,Array.prototype.slice.call(arguments,1))}function t(e){test.mode(e,a,Array.prototype.slice.call(arguments,1))}function o(e){test.mode(e,i,Array.prototype.slice.call(arguments,1))}var r=CodeMirror.getMode({indentUnit:2},"text/x-c");e("indent","[type void] [def foo]([type void*] [variable a], [type int] [variable b]) {","  [type int] [variable c] [operator =] [variable b] [operator +]","    [number 1];","  [keyword return] [operator *][variable a];","}"),e("indent_switch","[keyword switch] ([variable x]) {","  [keyword case] [number 10]:","    [keyword return] [number 20];","  [keyword default]:",'    [variable printf]([string "foo %c"], [variable x]);',"}"),e("def","[type void] [def foo]() {}","[keyword struct] [def bar]{}","[keyword enum] [def zot]{}","[keyword union] [def ugh]{}","[type int] [type *][def baz]() {}"),e("def_new_line","::[variable std]::[variable SomeTerribleType][operator <][variable T][operator >]","[def SomeLongMethodNameThatDoesntFitIntoOneLine]([keyword const] [variable MyType][operator &] [variable param]) {}"),e("double_block","[keyword for] (;;)","  [keyword for] (;;)","    [variable x][operator ++];","[keyword return];"),e("preprocessor","[meta #define FOO 3]","[type int] [variable foo];","[meta #define BAR\\]","[meta 4]","[type unsigned] [type int] [variable bar] [operator =] [number 8];","[meta #include <baz> ][comment // comment]"),e("c_underscores","[builtin __FOO];","[builtin _Complex];","[builtin __aName];","[variable _aName];"),e("c_types","[type int];","[type long];","[type char];","[type short];","[type double];","[type float];","[type unsigned];","[type signed];","[type void];","[type bool];","[type foo_t];","[variable foo_T];","[variable _t];");var a=CodeMirror.getMode({indentUnit:2},"text/x-c++src");t("cpp14_literal","[number 10'000];","[number 0b10'000];","[number 0x10'000];","[string '100000'];"),t("ctor_dtor","[def Foo::Foo]() {}","[def Foo::~Foo]() {}"),t("cpp_underscores","[builtin __FOO];","[builtin _Complex];","[builtin __aName];","[variable _aName];");var i=CodeMirror.getMode({indentUnit:2},"text/x-objectivec");o("objc_underscores","[builtin __FOO];","[builtin _Complex];","[builtin __aName];","[variable _aName];"),o("objc_interface","[keyword @interface] [def foo] {","  [type int] [variable bar];","}","[keyword @property] ([keyword atomic], [keyword nullable]) [variable NSString][operator *] [variable a];","[keyword @property] ([keyword nonatomic], [keyword assign]) [type int] [variable b];","[operator -]([type instancetype])[variable initWithFoo]:([type int])[variable a] [builtin NS_DESIGNATED_INITIALIZER];","[keyword @end]"),o("objc_implementation","[keyword @implementation] [def foo] {","  [type int] [variable bar];","}","[keyword @property] ([keyword readwrite]) [type SEL] [variable a];","[operator -]([type instancetype])[variable initWithFoo]:([type int])[variable a] {","  [keyword if](([keyword self] [operator =] [[[keyword super] [variable init] ]])) {}","  [keyword return] [keyword self];","}","[keyword @end]"),o("objc_types","[type int];","[type foo_t];","[variable foo_T];","[type id];","[type SEL];","[type instancetype];","[type Class];","[type Protocol];","[type BOOL];");var n=CodeMirror.getMode({indentUnit:2},"text/x-scala");!function(e){test.mode("scala_"+e,n,Array.prototype.slice.call(arguments,1))}("nested_comments","[comment /*]","[comment But wait /* this is a nested comment */ for real]","[comment /**** let * me * show * you ****/]","[comment ///// let / me / show / you /////]","[comment */]")}();