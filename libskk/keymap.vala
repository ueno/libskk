/*
 * Copyright (C) 2011 Daiki Ueno <ueno@unixuser.org>
 * Copyright (C) 2011 Red Hat, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using Gee;

namespace Skk {
    class Keymap : Object {
        Map<string,string> entries = new HashMap<string,string> ();

        public new void @set (string key, string command) {
            entries.set (new KeyEvent.from_string (key).to_string (),
                         command);
        }

        public string? lookup_key (KeyEvent key) {
            return entries.get (key.to_string ());
        }

        public KeyEvent? where_is (string command) {
            var iter = entries.map_iterator ();
            if (iter.first ()) {
                do {
                    if (iter.get_value () == command) {
                        return new KeyEvent.from_string (iter.get_key ());
                    }
                } while (iter.next ());
            }
            return null;
        }
    }
}
