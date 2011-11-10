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
    /**
     * SkkContext:
     *
     * The input context with support for SKK kana-kanji conversion method.
     */
    public class Context : Object {
        Dict[] dictionaries;
        SList<State> state_stack;
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
         * skk_context_new:
         * @dictionaries: an array of #SkkDict
         *
         * Create a new #SkkContext.
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
        }

        public bool complete () {
            // FIXME not implemented
            return false;
        }

        uint dict_edit_level () {
            return state_stack.length () - 1;
        }

        bool enter_dict_edit () {
            // FIXME not implemented
            return false;
        }

        bool leave_dict_edit () {
            // FIXME not implemented
            return false;
        }

        bool abort_dict_edit () {
            // FIXME not implemented
            return false;
        }

        /**
         * skk_context_process_key_events:
         * @self: an #SkkContext
         * @keys: a string representing key events, seperated by " "
         *
         * Feed key events to the context.  This function is only used
         * in unit tests.
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
         * skk_context_process_key_event:
         * @self: an #SkkContext
         * @key: a string representing a key event
         *
         * Feed a key event to the context.
         */
        public bool process_key_event (string key) {
            var state = state_stack.data;
            var ev = new KeyEvent (key);
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
         * skk_context_reset:
         * @self: an #SkkContext
         *
         * Reset the context.
         */
        public void reset () {
            var state = state_stack.data;
            state_stack = null;
            state_stack.prepend (state);
            state.reset ();
        }

        /**
         * skk_context_get_output:
         * @self: an #SkkContext
         *
         * Get the current output string.  This will clear the current
         * output after calling.
         */
        public string get_output () {
            var state = state_stack.data;
            var handler = handlers.get (state.handler_type);
            var output = handler.get_output (state);
            state.output.erase ();
            return output;
        }

        /**
         * skk_context_get_preedit:
         * @self: an #SkkContext
         *
         * Get the current preedit string.
         */
        public string get_preedit () {
            var state = state_stack.data;
            var handler = handlers.get (state.handler_type);
            return handler.get_preedit (state);
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
