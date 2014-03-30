/*
 * ЮТФ
 * jQuery sprintf - perl based functionallity for sprintf and friends.
 *
 * Copyright © 2008 Carl Furstenberg
 *
 * Released under GPL, BSD, or MIT license.
 * ---------------------------------------------------------------------------
 *  GPL:
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright (c) The Regents of the University of California.
 * All rights reserved.
 *
 * ---------------------------------------------------------------------------
 *  BSD:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 °* OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 * ---------------------------------------------------------------------------
 *  MIT:
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 * ---------------------------------------------------------------------------
 *
 *  Version: 0.0.6
 */

/** 
 * Inserts the arguments into the format and returns the formated string
 *
 * @example alert($.vsprintf( "%s %s", [ "Hello", "world" ] ));
 *
 * @param String format the format to use
 * @param Array args the arguments to insert into the format
 * @return String the formated string
 */
jQuery.vsprintf = function jQuery_vsprintf( format, args ) {
  if( format == null ) {
    throw "Not enough arguments for vsprintf";
  }
  if( args == null ) {
    args = [];
  }

  function _sprintf_format( type, value, flags ) {

    // Similar to how perl printf works
    if( value == undefined ) {
      if( type == 's' ) {
        return '';
      } else {
        return '0';
      }
    }

    var result;
    var prefix = '';
    var fill = '';
    var fillchar = ' ';
    if( flags['short'] || flags['long'] || flags['long_long'] ) {
      /* This is pretty ugly, but as JS ignores bit lengths except 
       * somewhat when working with bit operators. 
       * So we fake a bit :) */
      switch( type ) {
      case 'e':
      case 'f':
      case 'G':
      case 'E':
      case 'G':
      case 'd': /* signed */
        if( flags['short'] ) {
          if( value >= 32767 ) {
            value = 32767;
          } else if( value <= -32767-1 ) {
            value = -32767-1;
          }
        } else if ( flags['long'] ) {
          if( value >= 2147483647 ) {
            value = 2147483647;
          } else if( value <= -2147483647-1 ) {
            value = -2147483647-1;
          }
        } else /*if ( flags['long_long'] )*/ {
          if( value >= 9223372036854775807 ) {
            value = 9223372036854775807;
          } else if( value <= -9223372036854775807-1 ) {
            value = -9223372036854775807-1;
          }
        }
        break;
      case 'X':
      case 'B':
      case 'u':
      case 'o':
      case 'x': 
      case 'b': /* unsigned */
        if( value < 0 ) {
          /* Pretty ugly, but one only solution */
          value = Math.abs( value ) - 1;
        }
        if( flags['short'] ) {
          if( value >= 65535 ) {
            value = 65535;
          } 
        } else if ( flags['long'] ) {
          if( value >= 4294967295 ) {
            value = 4294967295;
          } 

        } else /*if ( flags['long_long'] )*/ {
          if( value >= 18446744073709551615 ) {
            value = 18446744073709551615;
          } 

        }
        break;
      }
    }
    switch( type ) {
    case 'c':
      result = String.fromCharCode( parseInt( value ) );
      break;
    case 's':
      result = value.toString();
      break;
    case 'd':
      result = (new Number( parseInt( value ) ) ).toString();
      break;
    case 'u':
      result = (new Number( parseInt( value ) ) ).toString();
      break;
    case 'o':
      result = (new Number( parseInt( value ) ) ).toString(8);
      break;
    case 'x':
      result = (new Number( parseInt( value ) ) ).toString(16);
      break;
    case 'B':
    case 'b':
      result = (new Number( parseInt( value ) ) ).toString(2);
      break;
    case 'e':
      var digits = flags['precision'] ? flags['precision'] : 6;
      result = (new Number( value ) ).toExponential( digits ).toString();
      break;
    case 'f':
      var digits = flags['precision'] ? flags['precision'] : 6;
      result = (new Number( value ) ).toFixed( digits ).toString();
      break;
    case 'g':
      var digits = flags['precision'] ? flags['precision'] : 6;
      result = (new Number( value ) ).toPrecision( digits ).toString();
      break;
    case 'X':
      result = (new Number( parseInt( value ) ) ).toString(16).toUpperCase();
      break;
    case 'E':
      var digits = flags['precision'] ? flags['precision'] : 6;
      result = (new Number( value ) ).toExponential( digits ).toString().toUpperCase();
      break;
    case 'G':
      var digits = flags['precision'] ? flags['precision'] : 6;
      result = (new Number( value ) ).toPrecision( digits ).toString().toUpperCase();
      break;
    }

    if(flags['+'] && parseFloat( value ) > 0 && ['d','e','f','g','E','G'].indexOf(type) != -1 ) {
      prefix = '+';
    }

    if(flags[' '] && parseFloat( value ) > 0 && ['d','e','f','g','E','G'].indexOf(type) != -1 ) {
      prefix = ' ';
    }

    if( flags['#'] && parseInt( value ) != 0 ) {
      switch(type) {
      case 'o':
        prefix = '0';
        break;
      case 'x':
      case 'X':
        prefix = '0x';
        break;
      case 'b':
        prefix = '0b';
        break;
      case 'B':
        prefix = '0B';
        break;
      }
    }

    if( flags['0'] && !flags['-'] ) {
      fillchar = '0';
    }

    if( flags['width'] && flags['width'] > ( result.length + prefix.length ) ) {
      var tofill = flags['width'] - result.length - prefix.length;
      for( var i = 0; i < tofill; ++i ) {
        fill += fillchar;
      }
    }

    if( flags['-'] && !flags['0'] ) {
      result += fill;
    } else {
      result = fill + result;
    }

    return prefix + result;
  };

  var result = "";

  var index = 0;
  var current_index = 0;
  var flags = {
    'long': false,
    'short': false,
    'long_long': false
  };
  var in_operator = false;
  var relative = false;
  var precision = false;
  var fixed = false;
  var vector = false;
  var bitwidth = false;
  var vector_delimiter = '.';

  for( var i = 0; i < format.length; ++i ) {
    var current_char = format.charAt(i);
    if( in_operator ) {
      // backward compat
      switch( current_char ) {
      case 'i':
        current_char = 'd';
        break;
      case 'D':
        flags['long'] = true;
        current_char = 'd';
        break;
      case 'U':
        flags['long'] = true;
        current_char = 'u';
        break;
      case 'O':
        flags['long'] = true;
        current_char = 'o';
        break;
      case 'F':
        current_char = 'f';
        break;
      }
      switch( current_char ) {
      case 'c':
      case 's':
      case 'd':
      case 'u':
      case 'o':
      case 'x':
      case 'e':
      case 'f':
      case 'g':
      case 'X':
      case 'E':
      case 'G':
      case 'b':
      case 'B':
        var value = args[current_index];
        if( vector ) {
          var fixed_value = value;
          if( value instanceof Array ) {
            // if the value is an array, assume to work on it directly
            fixed_value = value;
          } else if ( typeof(value) == 'string' || value instanceof String ) {
            // normal behavour, assume string is a bitmap
            fixed_value = value.split('').map( function( value ) { return value.charCodeAt(); } );
          } else if ( ( typeof(value) == 'number' || value instanceof Number ) && flags['bitwidth'] ) {
            // if we defined a width, assume we want to vectorize the bits directly
            fixed_value = [];
            do {
              fixed_value.unshift( value & ~(~0 << flags['bitwidth'] ) );
            } while( value >>>= flags['bitwidth'] );
          } else {
            fixed_value = value.toString().split('').map( function( value ) { return value.charCodeAt(); } );

          }
          result += fixed_value.map( function( value ) {
              return _sprintf_format( current_char, value, flags );
            }).join( vector_delimiter );
        } else {
          result += _sprintf_format( current_char, value, flags );
        }
        if( !fixed ) {
          ++index;
        }
        current_index = index;
        flags = {};
        relative = false;
        in_operator = false;
        precision = false;
        fixed = false;
        vector = false;
        bitwidth = false;
        vector_delimiter = '.';
        break;
      case 'v':
        vector = true;
        break;
      case ' ':
      case '0':
      case '-':
      case '+':
      case '#':
        flags[current_char] = true;
        break;
      case '*':
        relative = true;
        break;
      case '.':
        precision = true;
        break;
      case '@':
        bitwidth = true;
        break;
      case 'l':
        if( flags['long'] ) {
          flags['long_long'] = true;
          flags['long'] = false;
        } else {
          flags['long'] = true;
          flags['long_long'] = false;
        }
        flags['short'] = false;
        break;
      case 'q':
      case 'L':
        flags['long_long'] = true;
        flags['long'] = false;
        flags['short'] = false;
        break;
      case 'h':
        flags['short'] = true;
        flags['long'] = false;
        flags['long_long'] = false;
        break;
      }
      if( /\d/.test( current_char ) ) {
        var num = parseInt( format.substr( i ) );
        var len = num.toString().length;
        i += len - 1;
        var next = format.charAt( i  + 1 );
        if( next == '$' ) {
          if( num < 0 || num > args.length ) {
            throw "out of bound";
          }
          if( relative ) {
            if( precision ) {
              flags['precision'] = args[num - 1];
              precision = false;
            } else if( format.charAt( i + 2 ) == 'v' ) {
              vector_delimiter = args[num - 1];
            }else {
              flags['width'] = args[num - 1];
            }
            relative = false;
          } else {
            fixed = true;
            current_index = num - 1;
          }
          ++i;
        } else if( precision ) {
          flags['precision'] = num;
          precision = false;
        } else if( bitwidth ) {
          flags['bitwidth'] = num;
          bitwidth = false;
        } else {
          flags['width'] = num;
        }
      } else if ( relative && !/\d/.test( format.charAt( i + 1 ) ) ) {
        if( precision ) {
          flags['precision'] = args[current_index];
          precision = false;
        } else if( format.charAt( i + 1 ) == 'v' ) {
          vector_delimiter = args[current_index];
        } else {
          flags['width'] = args[current_index];
        }
        ++index;
        if( !fixed ) {
          current_index++;
        }
        relative = false;
      }
    } else {
      if( current_char == '%' ) {
        // If the next character is an %, then we have an escaped %, 
        // we'll take this as an exception to the normal lookup, as
        // we don't want/need to process this.
        if( format.charAt(i+1) == '%' ) {
          result += '%';
          ++i;
          continue;
        }
        in_operator = true;
        continue;
      } else {
        result += current_char;
        continue;
      }
    }
  }
  return result;
};

/** 
 * Inserts the arguments§ into the format and returns the formated string
 *
 * @example alert($.sprintf( "%s %s", "Hello", "world" ));
 *
 * @param String format the format to use
 * @param Object args... the arguments to insert into the format
 * @return String the formated string
 */

jQuery.sprintf = function jQuery_sprintf() {
  if( arguments.length == 0 ) {
    throw "Not enough arguments for sprintf";
  }

  var args = Array.prototype.slice.call(arguments);
  var format = args.shift();

  return jQuery.vsprintf( format, args ); 
};

/** 
 * Inserts the arguments into the format and appends the formated string
 * to the objects in question.
 *
 * @example $('p').printf( "%d <strong>%s</strong>", 2, "world" );
 *
 * @before <p>Hello</p>
 *
 * @after <p>Hello2 <strong>world</strong></p>
 *
 * @param String format the format to use
 * @param Object args... the arguments to insert into the format
 */

jQuery.fn.printf = function jQuery_fn_printf() {
  if( arguments.length == 0 ) {
    throw "Not enough arguments for sprintf";
  }
  var args = Array.prototype.slice.call(arguments);
  var format = args.shift();

  return this.append( jQuery.vsprintf( format, args ) );
};

/** 
 * Inserts the arguments into the format and appends the formated string
 * to the objects in question.
 *
 * @example $('p').vprintf( "%d <strong>%s</strong>", [ 2, "world" ] );
 *
 * @before <p>Hello</p>
 *
 * @after <p>Hello2 <strong>world</strong></p>
 *
 * @param String format the format to use
 * @param Array args the arguments to insert into the format
 */
jQuery.fn.vprintf = function jQuery_fn_vprintf( format, args ) {
  if( arguments.length == 0 ) {
    throw "Not enough arguments for sprintf";
  }

  return this.append( jQuery.vsprintf( format, args  ) );
};

/** 
 * Formats the objects html in question and replaces the content 
 * with the formated content
 *
 * @example $('p').vformat( [ "Hello", "world" ] );
 *
 * @before <p>%s %s</p>
 *
 * @after <p>Hello world</p>
 *
 * @param Array args the arguments to insert into the format
 */

jQuery.fn.vformat = function jQuery_fn_vformat( args ) {
  if( arguments.length == 0 ) {
    throw "Not enough arguments for sprintf";
  }
  return this.each( function() { 
      self = jQuery(this);
      self.html(  jQuery.vsprintf( self.html(), args ) )
    }
  ); 
}

/** 
 * Formats the objects html in question and replaces the content 
 * with the formated content
 *
 * @example $('p').format( "Hello", "world" );
 *
 * @before <p>%s %s</p>
 *
 * @after <p>Hello world</p>
 *
 * @param Object args... the arguments to insert into the format
 */
jQuery.fn.format = function jQuery_fn_format() {
  if( arguments.length == 0 ) {
    throw "Not enough arguments for sprintf";
  }
  var args = Array.prototype.slice.call(arguments);
  return this.each( function() { 
      self = jQuery(this);
      self.html(  jQuery.vsprintf( self.html(), args ) )
    }
  ); 
}
