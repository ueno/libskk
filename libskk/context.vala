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

        public bool process_key_events (string text) {
            bool retval = false;
            int index = 0;
            unichar c;
            while (text.get_next_char (ref index, out c)) {
                if (process_key_event (c) && !retval)
                    retval = true;
            }
            return retval;
        }

        public bool process_key_event (unichar c) {
            var state = state_stack.data;
            bool retval = false;
            var handler_type = state.handler_type;
            do {
                handler_type = state.handler_type;
                var handler = handlers.get (handler_type);
                retval = handler.process_key_event (state, c);
                if (retval)
                    break;
            } while (handler_type != state.handler_type);
            return retval;
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
