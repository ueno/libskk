/*
 * Copyright (C) 2011-2014 Daiki Ueno <ueno@gnu.org>
 * Copyright (C) 2011-2014 Red Hat, Inc.
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

static string opt_file_dict;
static string opt_user_dict;
static string opt_skkserv;
static string opt_typing_rule;
static bool opt_list_typing_rules;

static const OptionEntry[] options = {
    { "file-dict", 'f', 0, OptionArg.STRING, ref opt_file_dict,
      N_("Path to a file dictionary"), null },
    { "user-dict", 'u', 0, OptionArg.STRING, ref opt_user_dict,
      N_("Path to a user dictionary"), null },
    { "skkserv", 's', 0, OptionArg.STRING, ref opt_skkserv,
      N_("Host and port running skkserv (HOST:PORT)"), null },
    { "rule", 'r', 0, OptionArg.STRING, ref opt_typing_rule,
      N_("Typing rule (default: \"default\")"), null },
    { "list-rules", 'l', 0, OptionArg.NONE, ref opt_list_typing_rules,
      N_("List typing rules"), null },
    { null }
};

static int main (string[] args) {
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

    if (opt_list_typing_rules) {
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
    if (opt_user_dict != null) {
        try {
            dictionaries.add (new Skk.UserDict (opt_user_dict));
        } catch (GLib.Error e) {
            stderr.printf ("can't open user dict %s: %s",
                           opt_user_dict, e.message);
            return 1;
        }
    }

    if (opt_file_dict == null) {
        opt_file_dict = Path.build_filename (Config.DATADIR,
                                             "skk", "SKK-JISYO.L");
    }

    if (opt_file_dict.has_suffix (".cdb")) {
        try {
            dictionaries.add (new Skk.CdbDict (opt_file_dict));
        } catch (GLib.Error e) {
            stderr.printf ("can't open CDB dict %s: %s",
                           opt_file_dict, e.message);
            return 1;
        }
    } else {
        try {
            dictionaries.add (new Skk.FileDict (opt_file_dict));
        } catch (GLib.Error e) {
            stderr.printf ("can't open file dict %s: %s",
                           opt_file_dict, e.message);
            return 1;
        }
    }

    if (opt_skkserv != null) {
        var index = opt_skkserv.last_index_of (":");
        string host;
        uint16 port;
        if (index < 0) {
            host = opt_skkserv;
            port = 1178;
        } else {
            host = opt_skkserv[0:index];
            port = (uint16) int.parse (
                opt_skkserv[index + 1:opt_skkserv.length]);
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

    if (opt_typing_rule != null) {
        try {
            context.typing_rule = new Skk.Rule (opt_typing_rule);
        } catch (Skk.RuleParseError e) {
            stderr.printf ("can't load rule \"%s\": %s\n",
                           opt_typing_rule,
                           e.message);
            return 1;
        }
    }

    var repl = new Repl (context);
    if (!repl.run ())
        return 1;
    return 0;
}

class Repl : Object {
    Skk.Context context;

    public bool run () {
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
        return true;
    }

    public Repl (Skk.Context context) {
        this.context = context;
    }
}
