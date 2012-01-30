/*
 * Copyright (C) 2011-2012 Daiki Ueno <ueno@unixuser.org>
 * Copyright (C) 2011-2012 Red Hat, Inc.
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
namespace Skk {
    class FepTool : Tool {
        Context context;
        Fep.GClient client;

        bool filter_key_event (uint keyval, uint modifiers) {
            KeyEvent key;
            try {
                key = new KeyEvent.from_x_keysym (keyval,
                                                  (ModifierType) modifiers);
            } catch (KeyEventFormatError e) {
                return false;
            }

            return context.process_key_event (key);
        }

        void process_key_event (uint keyval, uint modifiers) {
            var output = context.poll_output ();
            if (output.length > 0) {
                client.send_data (output, output.length);
            }
            if (context.preedit != preedit) {
                client.set_cursor_text (context.preedit);
                preedit = context.preedit;
            }
            if (context.input_mode != input_mode) {
                update_input_mode ();
            }
        }

        struct Entry<K,V> {
            K key;
            V value;
        }

        static const Entry<Skk.InputMode,string>[] input_mode_labels = {
            { Skk.InputMode.HIRAGANA, "あ" },
            { Skk.InputMode.KATAKANA, "ア" },
            { Skk.InputMode.HANKAKU_KATAKANA, "_ｱ" },
            { Skk.InputMode.LATIN, "_A" },
            { Skk.InputMode.WIDE_LATIN, "Ａ" }
        };

        void update_input_mode () {
            input_mode = context.input_mode;
            foreach (var entry in input_mode_labels) {
                if (entry.key == input_mode) {
                    client.set_status_text ("SKK[" + entry.value + "]");
                    break;
                }
            }
        }

        public override bool run () {
            client.filter_key_event.connect ((keyval, _modifiers) => {
                    return filter_key_event (keyval, _modifiers);
                });
            client.process_key_event.connect ((keyval, _modifiers) => {
                    process_key_event (keyval, _modifiers);
                });
            update_input_mode ();
            Posix.pollfd pfds[1];
            pfds[0] = Posix.pollfd () {
                fd = client.get_key_event_poll_fd (),
                events = Posix.POLLIN,
                revents = 0
            };
            while (true) {
                int retval = Posix.poll (pfds, -1);
                if (retval < 0)
                    break;
                if (retval > 0) {
                    client.dispatch_key_event ();
                }
            }
            return true;
        }

        string preedit = "";
        Skk.InputMode input_mode = Skk.InputMode.HIRAGANA;

        public FepTool (Skk.Context context) throws GLib.Error {
            this.context = context;
            this.client = new Fep.GClient (null, null);
        }
    }
}