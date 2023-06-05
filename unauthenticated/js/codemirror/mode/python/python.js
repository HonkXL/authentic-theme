!function(e){"object"==typeof exports&&"object"==typeof module?e(require("../../lib/codemirror")):"function"==typeof define&&define.amd?define(["../../lib/codemirror"],e):e(CodeMirror)}(function(e){function t(e){return new RegExp("^(("+e.join(")|(")+"))\\b")}function n(e){return e.scopes[e.scopes.length-1]}var r=t(["and","or","not","is"]),i="as assert break class continue def del elif else except finally for from global if import lambda pass raise return try while with yield in False True".split(" "),o="abs all any bin bool bytearray callable chr classmethod compile complex delattr dict dir divmod enumerate eval filter float format frozenset getattr globals hasattr hash help hex id input int isinstance issubclass iter len list locals map max memoryview min next object oct open ord pow property range repr reversed round set setattr slice sorted staticmethod str sum super tuple type vars zip __import__ NotImplemented Ellipsis __debug__".split(" ");e.registerHelper("hintWords","python",i.concat(o).concat(["exec","print"])),e.defineMode("python",function(a,s){function l(e,t){var r=e.sol()&&"\\"!=t.lastToken;if(r&&(t.indent=e.indentation()),r&&"py"==n(t).type){if(r=n(t).offset,e.eatSpace()){var i=e.indentation();return i>r?f(t):i<r&&u(e,t)&&"#"!=e.peek()&&(t.errorToken=!0),null}return i=c(e,t),0<r&&u(e,t)&&(i+=" error"),i}return c(e,t)}function c(e,t,n){if(e.eatSpace())return null;if(!n&&e.match(/^#.*/))return"comment";if(e.match(/^[0-9\.]/,!1)){var i=!1;if(e.match(/^[\d_]*\.\d+(e[\+\-]?\d+)?/i)&&(i=!0),e.match(/^[\d_]+\.\d*/)&&(i=!0),e.match(/^\.\d+/)&&(i=!0),i)return e.eat(/J/i),"number";if(i=!1,e.match(/^0x[0-9a-f_]+/i)&&(i=!0),e.match(/^0b[01_]+/i)&&(i=!0),e.match(/^0o[0-7_]+/i)&&(i=!0),e.match(/^[1-9][\d_]*(e[\+\-]?[\d_]+)?/)&&(e.eat(/J/i),i=!0),e.match(/^0(?![\dx])/i)&&(i=!0),i)return e.eat(/L/i),"number"}if(e.match(k))return-1===e.current().toLowerCase().indexOf("f")?t.tokenize=function(e,t){function n(n,i){for(;!n.eol();)if(n.eatWhile(/[^'"\\]/),n.eat("\\")){if(n.next(),r&&n.eol())return"string"}else{if(n.match(e))return i.tokenize=t,"string";n.eat(/['"]/)}if(r){if(s.singleLineStringErrors)return"error";i.tokenize=t}return"string"}for(;0<="rubf".indexOf(e.charAt(0).toLowerCase());)e=e.substr(1);var r=1==e.length;return n.isString=!0,n}(e.current(),t.tokenize):t.tokenize=function(e,t){function n(e){return function(t,i){var o=c(t,i,!0);return"punctuation"==o&&("{"==t.current()?i.tokenize=n(e+1):"}"==t.current()&&(i.tokenize=1<e?n(e-1):r)),o}}function r(r,o){for(;!r.eol();)if(r.eatWhile(/[^'"\{\}\\]/),r.eat("\\")){if(r.next(),i&&r.eol())return"string"}else{if(r.match(e))return o.tokenize=t,"string";if(r.match("{{"))return"string";if(r.match("{",!1))return o.tokenize=n(0),r.current()?"string":o.tokenize(r,o);if(r.match("}}"))return"string";if(r.match("}"))return"error";r.eat(/['"]/)}if(i){if(s.singleLineStringErrors)return"error";o.tokenize=t}return"string"}for(;0<="rubf".indexOf(e.charAt(0).toLowerCase());)e=e.substr(1);var i=1==e.length;return r.isString=!0,r}(e.current(),t.tokenize),t.tokenize(e,t);for(i=0;i<d.length;i++)if(e.match(d[i]))return"operator";return e.match(p)?"punctuation":"."==t.lastToken&&e.match(y)?"property":e.match(x)||e.match(r)?"keyword":e.match(v)?"builtin":e.match(/^(self|cls)\b/)?"variable-2":e.match(y)?"def"==t.lastToken||"class"==t.lastToken?"def":"variable":(e.next(),n?null:"error")}function f(e){for(;"py"!=n(e).type;)e.scopes.pop();e.scopes.push({offset:n(e).offset+a.indentUnit,type:"py",align:null})}function u(e,t){for(var r=e.indentation();1<t.scopes.length&&n(t).offset>r;){if("py"!=n(t).type)return!0;t.scopes.pop()}return n(t).offset!=r}for(var p=s.delimiters||s.singleDelimiters||/^[\(\)\[\]\{\}@,:`=;\.\\]/,d=[s.singleOperators,s.doubleOperators,s.doubleDelimiters,s.tripleDelimiters,s.operators||/^([-+*/%\/&|^]=?|[<>=]+|\/\/=?|\*\*=?|!=|[~!@]|\.\.\.)/],m=0;m<d.length;m++)d[m]||d.splice(m--,1);var h=s.hangingIndent||a.indentUnit;m=i;var b=o;void 0!=s.extra_keywords&&(m=m.concat(s.extra_keywords)),void 0!=s.extra_builtins&&(b=b.concat(s.extra_builtins));var g=!(s.version&&3>Number(s.version));if(g){var y=s.identifiers||/^[_A-Za-z\u00A1-\uFFFF][_A-Za-z0-9\u00A1-\uFFFF]*/;m=m.concat("nonlocal None aiter anext async await breakpoint match case".split(" ")),b=b.concat(["ascii","bytes","exec","print"]);var k=RegExp("^(([rbuf]|(br)|(rb)|(fr)|(rf))?('{3}|\"{3}|['\"]))","i")}else y=s.identifiers||/^[_A-Za-z][_A-Za-z0-9]*/,m=m.concat(["exec","print"]),b=b.concat("apply basestring buffer cmp coerce execfile file intern long raw_input reduce reload unichr unicode xrange None".split(" ")),k=RegExp("^(([rubf]|(ur)|(br))?('{3}|\"{3}|['\"]))","i");var x=t(m),v=t(b);return{startState:function(e){return{tokenize:l,scopes:[{offset:e||0,type:"py",align:null}],indent:e||0,lastToken:null,lambda:!1,dedent:0}},token:function(e,t){var r=t.errorToken;r&&(t.errorToken=!1);e:{e.sol()&&(t.beginningOfLine=!0,t.dedent=!1);var i=t.tokenize(e,t),o=e.current();if(t.beginningOfLine&&"@"==o)i=e.match(y,!1)?"meta":g?"operator":"error";else{if(/\S/.test(o)&&(t.beginningOfLine=!1),"variable"!=i&&"builtin"!=i||"meta"!=t.lastToken||(i="meta"),"pass"!=o&&"return"!=o||(t.dedent=!0),"lambda"==o&&(t.lambda=!0),":"==o&&!t.lambda&&"py"==n(t).type&&e.match(/^\s*(?:#|$)/,!1)&&f(t),1==o.length&&!/string|comment/.test(i)){var a="[({".indexOf(o);if(-1!=a){a="])}".slice(a,a+1);var s=e.match(/^[\s\[\{\(]*(?:#|$)/,!1)?null:e.column()+1;t.scopes.push({offset:t.indent+h,type:a,align:s})}if(-1!=(a="])}".indexOf(o))){if(n(t).type!=o){i="error";break e}t.indent=t.scopes.pop().offset-h}}t.dedent&&e.eol()&&"py"==n(t).type&&1<t.scopes.length&&t.scopes.pop()}}return i&&"comment"!=i&&(t.lastToken="keyword"==i||"punctuation"==i?e.current():i),"punctuation"==i&&(i=null),e.eol()&&t.lambda&&(t.lambda=!1),r?i+" error":i},indent:function(t,r){if(t.tokenize!=l)return t.tokenize.isString?e.Pass:0;var i=n(t),o=i.type==r.charAt(0)||"py"==i.type&&!t.dedent&&/^(else:|elif |except |finally:)/.test(r);return null!=i.align?i.align-(o?1:0):i.offset-(o?h:0)},electricInput:/^\s*([\}\]\)]|else:|elif |except |finally:)$/,closeBrackets:{triples:"'\""},lineComment:"#",fold:"indent"}}),e.defineMIME("text/x-python","python"),e.defineMIME("text/x-cython",{name:"python",extra_keywords:"by cdef cimport cpdef ctypedef enum except extern gil include nogil property public readonly struct union DEF IF ELIF ELSE".split(" ")})});