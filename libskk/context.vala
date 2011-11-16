/* 
 * Copyright (C) 2011 Daiki Ueno <ueno@unixuser.org>
 * Copyright (C) 2011 Red Hat, Inc.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301 USA
 */
using Gee;

namespace Skk {
    public enum InputMode {
        HIRAGANA = KanaMode.HIRAGANA,
        KATAKANA = KanaMode.KATAKANA,
        HANKAKU_KATAKANA = KanaMode.HANKAKU_KATAKANA,
        LATIN,
        WIDE_LATIN,
        DEFAULT = HIRAGANA
    }

    /**
     * The input context with support for SKK kana-kanji conversion method.
     */
    public class Context : Object {
        Dict[] dictionaries;
        SList<State> state_stack;
        SList<string> midasi_stack;
        HashMap<Type, StateHandler> handlers =
            new HashMap<Type, StateHandler> ();
        public InputMode input_mode {
            get {
                return state_stack.data.input_mode;
            }
            set {
                state_stack.data.input_mode = value;
            }
        }

        /**
         * Create a new Context.
         *
         * @param dictionaries an array of Dict
         *
         * @return a new Context
         */
        public Context (Dict[] dictionaries) {
            this.dictionaries = dictionaries;
            handlers.set (typeof (NoneStateHandler),
                          new NoneStateHandler ());
            handlers.set (typeof (StartStateHandler),
                          new StartStateHandler ());
            handlers.set (typeof (SelectStateHandler),
                          new SelectStateHandler ());
            this.state_stack.prepend (new State (dictionaries));
            this.state_stack.data.enter_dict_edit.connect ((midasi) => {
                    this.enter_dict_edit (midasi);
                });
        }

        public bool complete () {
            // FIXME not implemented
            return false;
        }

        uint dict_edit_level () {
            return state_stack.length () - 1;
        }

        bool enter_dict_edit (string midasi) {
            this.midasi_stack.prepend (midasi);
            this.state_stack.prepend (new State (dictionaries));
            this.state_stack.data.enter_dict_edit.connect ((midasi) => {
                    this.enter_dict_edit (midasi);
                });
            return true;
        }

        bool leave_dict_edit () {
            if (dict_edit_level () > 0) {
                this.midasi_stack.delete_link (this.midasi_stack);
                this.state_stack.delete_link (this.state_stack);
                return true;
            }
            return false;
        }

        /**
         * Pass key events to the context.  This function is only used
         * in unit tests.
         *
         * @param keys a string representing key events, seperated by " "
         *
         * @return `true` if any of key events are handled, `false` otherwise
         */
        public bool process_key_events (string keys) {
            var _keys = keys.split (" ");
            bool retval = false;
            foreach (var key in _keys) {
                if (key == "SPC")
                    key = " ";
                if (process_key_event (key) && !retval)
                    retval = true;
            }
            return retval;
        }

        /**
         * Pass one key event to the context.
         *
         * @param key a string representing a key event
         *
         * @return `true` if the key event is handled, `false` otherwise
         */
        public bool process_key_event (string key) {
            var state = state_stack.data;
            var ev = new KeyEvent (key);
            if (dict_edit_level () > 0 &&
                state.handler_type == typeof (NoneStateHandler)) {
                if ((ev.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                    ev.code == 'g') {
                    return leave_dict_edit ();
                }
                else if (ev.modifiers == 0 && ev.code == '\n') {
                    return leave_dict_edit ();
                }
            }
            while (true) {
                var handler_type = state.handler_type;
                var handler = handlers.get (handler_type);
                if (handler.process_key_event (state, ev))
                    return true;
                // state.handler_type may change if handler cannot
                // handle the event.  In that case retry with the new
                // handler.  Otherwise exit the loop.
                if (handler_type == state.handler_type)
                    return false;
            }
        }

        /**
         * Reset the context.
         */
        public void reset () {
            var state = state_stack.data;
            state_stack = null;
            state_stack.prepend (state);
            state.reset ();
        }

        /**
         * Get the current output string.  This will clear the current
         * output after calling.
         *
         * @return an output string
         */
        public string get_output () {
            var state = state_stack.data;
            var handler = handlers.get (state.handler_type);
            if (dict_edit_level () > 0) {
                return "";
            } else {
                var output = handler.get_output (state);
                state.output.erase ();
                return output;
            }
        }

        /**
         * Get the current preedit string.
         *
         * @return the preedit string
         */
        public string get_preedit () {
            var state = state_stack.data;
            var handler = handlers.get (state.handler_type);
            var builder = new StringBuilder ();
            if (dict_edit_level () > 0) {
                var level = dict_edit_level ();
                for (var i = 0; i < level; i++) {
                    builder.append_c ('[');
                }
                builder.append ("DictEdit");
                for (var i = 0; i < level; i++) {
                    builder.append_c (']');
                }
                builder.append (" ");
                builder.append (midasi_stack.data);
                builder.append (" ");
                builder.append (handler.get_output (state));
            }
            builder.append (handler.get_preedit (state));
            return builder.str;
        }

        public void save_dictionaries () {
            foreach (var dict in dictionaries) {
                if (!dict.read_only) {
                    dict.save ();
                }
            }
        }
    }
}
