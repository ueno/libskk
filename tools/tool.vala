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
    class Tool : Object {
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

            var option_context = new OptionContext ("- skk");
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
                dictionaries.add (new Skk.UserDict (file_dict));
            }

            if (file_dict != null) {
                if (file_dict.has_suffix (".cdb")) {
                    dictionaries.add (new Skk.CdbDict (file_dict));
                } else {
                    dictionaries.add (new Skk.FileDict (file_dict));
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
                dictionaries.add (new Skk.SkkServ (host, port));
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

            string? line;
            while ((line = stdin.read_line ()) != null) {
                context.process_key_events (line);
                var output = context.poll_output ();
                var preedit = context.preedit;
                stdout.printf (
                    "{ \"input\": \"%s\", " +
                    "\"output\": \"%s\", " +
                    "\"preedit\": \"%s\" }\n",
                    line.replace ("\"", "\\\""),
                    output.replace ("\"", "\\\""),
                    preedit.replace ("\"", "\\\""));
                context.reset ();
                context.clear_output ();
            }
            return 0;
        }
    }
}
