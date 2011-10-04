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
namespace Skk {
    public class Context {
        Dict[] dictionaries;
        SList<State> states;

        public Context (Dict[] dictionaries) {
            this.dictionaries = dictionaries;
            this.states.prepend (new State ());
        }

        public bool append (string text) {
            bool handled = false;
            int index = 0;
            unichar c;
            while (text.get_next_char (ref index, out c)) {
                if (!handled)
                    handled = append_c (c);
            }
            return handled;
        }

        public bool append_c (unichar c) {
            if (states.data.conv_state == ConvState.NONE) {
                states.data.append_c (c);
            }
            return false;
        }

        public bool complete () {
            // FIXME not implemented
            return false;
        }

        uint dict_edit_level () {
            return states.length () - 1;
        }

        bool leave_dict_edit () {
            // FIXME not implemented
            return false;
        }

        bool abort_dict_edit () {
            // FIXME not implemented
            return false;
        }

        public bool commit () {
            if (dict_edit_level () > 0)
                return leave_dict_edit ();
            // FIXME not implemented
            return false;
        }

        public bool cancel () {
            if (dict_edit_level () > 0)
                return abort_dict_edit ();
            // FIXME not implemented
            return false;
        }

        public bool delete () {
            return states.data.delete ();
        }
    }
}
