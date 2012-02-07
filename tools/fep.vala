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
using Gee;

namespace Skk {
    abstract class Tool : Object {
        static string file_dict;
        static string user_dict;
        static string skkserv;
        static string typing_rule;
        static bool list_typing_rules;

        const OptionEntry[] options = {
            {"file-dict", 'f', 0, OptionArg.STRING, ref file_dict,
             N_("Path to a file dictionary"), null },
            {"user-dict", 'u', 0, OptionArg.STRING, ref user_dict,
             N_("Path to a user dictionary"), null },
            {"skkserv", 's', 0, OptionArg.STRING, ref skkserv,
             N_("Host and port running skkserv (HOST:PORT)"), null }, 
            {"rule", 'r', 0, OptionArg.STRING, ref typing_rule,
             N_("Typing rule (default: \"default\")"), null },
            {"list-rules", 'l', 0, OptionArg.NONE, ref list_typing_rules,
             N_("List typing rules"), null },
            { null }
        };

        public static int main (string[] args) {
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
            Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
            Intl.textdomain (Config.GETTEXT_PACKAGE);

            var option_context = new OptionContext (
                _("- emulate SKK input method on the command line"));
            option_context.add_main_entries (options, "libskk");
            try {
                option_context.parse (ref args);
            } catch (OptionError e) {
                stderr.printf ("%s\n", e.message);
                return 1;
            }

            Skk.init ();

            if (list_typing_rules) {
                var rules = Skk.Rule.list ();
                foreach (var rule in rules) {
                    stdout.printf ("%s - %s: %s\n",
                                   rule.name,
                                   rule.label,
                                   rule.description);
                }
                return 0;
            }

            ArrayList<Skk.Dict> dictionaries = new ArrayList<Skk.Dict> ();
            if (user_dict != null) {
                try {
                    dictionaries.add (new Skk.UserDict (user_dict));
                } catch (GLib.Error e) {
                    stderr.printf ("can't open user dict %s: %s",
                                   user_dict, e.message);
                    return 1;
                }
            }

            if (file_dict != null) {
                if (file_dict.has_suffix (".cdb")) {
                    try {
                        dictionaries.add (new Skk.CdbDict (file_dict));
                    } catch (GLib.Error e) {
                        stderr.printf ("can't open CDB dict %s: %s",
                                       file_dict, e.message);
                        return 1;
                    }
                } else {
                    try {
                        dictionaries.add (new Skk.FileDict (file_dict));
                    } catch (GLib.Error e) {
                        stderr.printf ("can't open file dict %s: %s",
                                       file_dict, e.message);
                        return 1;
                    }
                }
            } else {
                dictionaries.add (
                    new Skk.FileDict (
                        Path.build_filename (Config.DATADIR,
                                             "skk", "SKK-JISYO.L")));
            }

            if (skkserv != null) {
                var index = skkserv.last_index_of (":");
                string host;
                uint16 port;
                if (index < 0) {
                    host = skkserv;
                    port = 1178;
                } else {
                    host = skkserv[0:index];
                    port = (uint16) int.parse (
                        skkserv[index + 1:skkserv.length]);
                }
                try {
                    dictionaries.add (new Skk.SkkServ (host, port));
                } catch (GLib.Error e) {
                    stderr.printf ("can't connect to skkserv at %s:%d: %s",
                                   host, port, e.message);
                        return 1;
                }
            }

            var context = new Skk.Context (dictionaries.to_array ());

            if (typing_rule != null) {
                try {
                    context.typing_rule = new Rule (typing_rule);
                } catch (RuleParseError e) {
                    stderr.printf ("can't load rule \"%s\": %s\n",
                                   typing_rule,
                                   e.message);
                    return 1;
                }
            }
            var tool = new FepTool (context);
            if (!tool.run ())
                return 1;
            return 0;
        }

        public abstract bool run ();
    }

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

            bool retval = context.process_key_event (key);
            var output = context.poll_output ();
            if (output.length > 0) {
                client.send_data (output, output.length);
            }
            return retval;
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

        void update_preedit () {
            preedit = context.preedit;
            client.set_cursor_text (preedit);
        }

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
            context.notify["preedit"].connect (() => {
                    if (context.preedit != preedit) {
                        update_preedit ();
                    }
                });
            context.notify["input-mode"].connect (() => {
                    if (context.input_mode != input_mode) {
                        update_input_mode ();
                    }
                });
            update_preedit ();
            update_input_mode ();
            Posix.pollfd pfds[1];
            pfds[0] = Posix.pollfd () {
                fd = client.get_poll_fd (),
                events = Posix.POLLIN,
                revents = 0
            };
            while (true) {
                int retval = Posix.poll (pfds, -1);
                if (retval < 0)
                    break;
                if (retval > 0) {
                    client.dispatch ();
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
