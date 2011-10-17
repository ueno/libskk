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
    public class Context {
        Dict[] dictionaries;
        SList<State> state_stack;
        HashMap<Type, StateHandler> handlers =
            new HashMap<Type, StateHandler> ();

        public Context (Dict[] dictionaries) {
            this.dictionaries = dictionaries;
            handlers.set (typeof (NoneStateHandler),
                          new NoneStateHandler ());
            handlers.set (typeof (StartStateHandler),
                          new StartStateHandler ());
            handlers.set (typeof (SelectStateHandler),
                          new SelectStateHandler ());
            this.state_stack.prepend (new State ());
        }

        public bool complete () {
            // FIXME not implemented
            return false;
        }

        uint dict_edit_level () {
            return state_stack.length () - 1;
        }

        bool leave_dict_edit () {
            // FIXME not implemented
            return false;
        }

        bool abort_dict_edit () {
            // FIXME not implemented
            return false;
        }

        public bool append_text (string text) {
            bool retval = false;
            int index = 0;
            unichar c;
            while (text.get_next_char (ref index, out c)) {
                if (append (c) && !retval)
                    retval = true;
            }
            return retval;
        }

        public bool append (unichar c) {
            var state = state_stack.data;
            if (state.handler_type == typeof (NoneStateHandler)) {
                if (c.isalpha () && c.isupper ())
                    state.handler_type = typeof (StartStateHandler);
            } else if (state.handler_type == typeof (StartStateHandler)) {
                if (c == ' ') {
                    state.handler_type = typeof (SelectStateHandler);
                    return true;
                }
            } else if (state.handler_type == typeof (SelectStateHandler)) {
                return commit ();
            }

            var handler = handlers.get (state.handler_type);
            return handler.append (state, c);
        }

        public bool commit () {
            if (dict_edit_level () > 0)
                return leave_dict_edit ();
            var state = state_stack.data;
            var handler = handlers.get (state.handler_type);
            bool retval = handler.commit (state);
            state.handler_type = typeof (NoneStateHandler);
            return retval;
        }

        public bool cancel () {
            if (dict_edit_level () > 0)
                return abort_dict_edit ();
            var state = state_stack.data;
            var handler = handlers.get (state.handler_type);
            return handler.cancel (state);
        }

        public bool delete () {
            var state = state_stack.data;
            var handler = handlers.get (state.handler_type);
            return handler.delete (state);
        }

        public void reset () {
            var state = state_stack.data;
            state_stack = null;
            state_stack.prepend (state);
            state.reset ();
        }

        public string get_output () {
            var state = state_stack.data;
            var handler = handlers.get (state.handler_type);
            return handler.get_output (state);
        }

        public string get_preedit () {
            var state = state_stack.data;
            var handler = handlers.get (state.handler_type);
            return handler.get_preedit (state);
        }
    }
}
