/*
 * Copyright (C) 2011-2026 Daiki Ueno <ueno@gnu.org>
 * Copyright (C) 2011-2026 Red Hat, Inc.
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

enum PreeditStyle {
    OVER_THE_SPOT,
    ROOT,
    DEFAULT = OVER_THE_SPOT
}

static string opt_file_dict;
static string opt_user_dict;
static string opt_skkserv;
static string opt_typing_rule;
static bool opt_list_typing_rules;
static string opt_preedit_style;

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
    { "preedit-style", 'p', 0, OptionArg.STRING, ref opt_preedit_style,
      N_("Preedit style"), null },
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

    Options opts = Options () { preedit_style = PreeditStyle.DEFAULT };
    if (opt_preedit_style != null) {
        EnumClass eclass = (EnumClass) typeof(PreeditStyle).class_ref ();
        EnumValue? evalue = eclass.get_value_by_nick (opt_preedit_style);
        if (evalue == null) {
            stderr.printf (_("unknown preedit style %s"),
                           opt_preedit_style);
            return 1;
        }
        opts.preedit_style = (PreeditStyle) evalue.value;
    }

    string[]? argv;
    if (args.length > 1) {
        argv = args[1 : args.length];
    } else {
        argv = { Environment.get_variable ("SHELL") };
    }

    try {
        Pid pid;
        if (Process.spawn_async (
                null, argv, null,
                SpawnFlags.DO_NOT_REAP_CHILD |
                SpawnFlags.CHILD_INHERITS_STDIN |
                SpawnFlags.SEARCH_PATH,
                null, out pid))
            ChildWatch.add (pid, (p, s) => {
                    Process.close_pid (pid);
                    Process.exit (s);
                });
    } catch (SpawnError e) {
        stderr.printf ("%s\n", e.message);
        return 1;
    }

    Client client;
    try {
        client = new Client (context, opts);
    } catch (Error e) {
        stderr.printf ("can't create client: %s", e.message);
        return 1;
    }

    if (!client.run ())
        return 1;
    return 0;
}

struct Options {
    PreeditStyle preedit_style;
}

class Client : Fep.GClient {
    Skk.Context context;
    Options opts;

    bool process_lookup_table_key_event (uint keyval, uint state) {
        if (state == 0 &&
            ((unichar) keyval).to_string () in LOOKUP_TABLE_LABELS) {
            var label = ((unichar) keyval).tolower ().to_string ();
            var end = int.min ((int)context.candidates.page_size,
                               LOOKUP_TABLE_LABELS.length);
            for (var index = 0; index < end; index++) {
                if (LOOKUP_TABLE_LABELS[index] == label) {
                    return context.candidates.select_at (index);
                }
            }
            return false;
        }

        if (state == 0) {
            bool retval = false;
            switch (keyval) {
            case Skk.Keysyms.Page_Up:
            case Skk.Keysyms.KP_Page_Up:
                retval = context.candidates.page_up ();
                break;
            case Skk.Keysyms.Page_Down:
            case Skk.Keysyms.KP_Page_Down:
                retval = context.candidates.page_down ();
                break;
            case Skk.Keysyms.Up:
            case Skk.Keysyms.Left:
                retval = context.candidates.cursor_up ();
                break;
            case Skk.Keysyms.Down:
            case Skk.Keysyms.Right:
                retval = context.candidates.cursor_down ();
                break;
            default:
                break;
            }

            if (retval) {
                set_lookup_table_cursor_pos ();
                update_preedit ();
                return true;
            }
        }

        return false;
    }

    public override bool filter_key_event (uint keyval, uint modifiers) {
        if (lookup_table_visible &&
            process_lookup_table_key_event (keyval, modifiers))
            return true;

        Skk.KeyEvent key;
        try {
            key = new Skk.KeyEvent.from_x_keysym (keyval,
                                                  (Skk.ModifierType) modifiers);
        } catch (Skk.KeyEventFormatError e) {
            return false;
        }

        var retval = context.process_key_event (key);
        var output = context.poll_output ();
        if (output.length > 0) {
            send_text (output);
        }
        return retval;
    }

    // We can't use Entry<InputMode,*> here because of Vala bug:
    // https://bugzilla.gnome.org/show_bug.cgi?id=684262
    struct Entry {
        Skk.InputMode key;
        string value;
    }

    static const Entry[] input_mode_labels = {
        { Skk.InputMode.HIRAGANA, "あ" },
        { Skk.InputMode.KATAKANA, "ア" },
        { Skk.InputMode.HANKAKU_KATAKANA, "_ｱ" },
        { Skk.InputMode.LATIN, "_A" },
        { Skk.InputMode.WIDE_LATIN, "Ａ" }
    };

    void update_preedit () {
        preedit = context.preedit;
        if (opts.preedit_style == PreeditStyle.ROOT) {
            if (preedit == "")
                update_status ();
            else {
                set_status_text (preedit, null);
                status = preedit;
                status_attr = null;
            }
        }
        else
            set_cursor_text (preedit, null);
    }

    string[] LOOKUP_TABLE_LABELS = {"a", "s", "d", "f", "j", "k", "l",
                                    "q", "w", "e", "r", "u", "i", "o"};

    void update_status () {
        var builder = new StringBuilder ();
        Fep.GAttribute? attr = null;
        input_mode = context.input_mode;
        foreach (var entry in input_mode_labels) {
            if (entry.key == input_mode) {
                builder.append ("[" + entry.value + "] ");
                break;
            }
        }
        if (lookup_table_visible) {
            var pages = (context.candidates.cursor_pos - context.candidates.page_start) / context.candidates.page_size;
            var start = pages * context.candidates.page_size + context.candidates.page_start;
            var end = uint.min (start + context.candidates.page_size,
                                context.candidates.size);
            for (var index = start; index < end; index++) {
                var candidate = context.candidates.get ((int) index);
                var text = "%s: %s".printf (
                    LOOKUP_TABLE_LABELS[index - start],
                    candidate.text);
                if (index == context.candidates.cursor_pos) {
                    var start_index = builder.str.char_count ();
                    attr = Fep.GAttribute () {
                        type = Fep.GAttrType.STANDOUT,
                        value = 1,
                        start_index = start_index,
                        end_index = start_index + text.char_count ()
                    };
                }
                builder.append (text);
                if (index < end - 1)
                    builder.append_c (' ');
            }
        }
        if (status != builder.str || status_attr != attr) {
            set_status_text (builder.str, attr);
            status = builder.str;
            status_attr = attr;
        }
    }

    void populate_lookup_table () {
    }

    void set_lookup_table_cursor_pos () {
        if (context.candidates.page_visible) {
            lookup_table_visible = true;
        } else if (lookup_table_visible) {
            lookup_table_visible = false;
        }
        update_status ();

        // When root style, need to recover the previous preedit text
        // shown at the status area.
        if (!lookup_table_visible && opts.preedit_style == PreeditStyle.ROOT)
            update_preedit ();
    }

    bool watch_func (IOChannel source, IOCondition condition) {
        dispatch ();
        return true;
    }

    bool lookup_table_visible = false;

    public bool run () {
        context.notify["preedit"].connect (() => {
                if (context.preedit != preedit) {
                    update_preedit ();
                }
            });
        context.notify["input-mode"].connect (() => {
                if (context.input_mode != input_mode) {
                    update_status ();
                }
            });
        context.candidates.populated.connect (() => {
                populate_lookup_table ();
            });
        context.candidates.notify["cursor-pos"].connect (() => {
                set_lookup_table_cursor_pos ();
            });
        context.candidates.selected.connect (() => {
                var output = context.poll_output ();
                if (output.length > 0) {
                    send_text (output);
                }
                lookup_table_visible = false;
                update_status ();
                // When root style, need to recover the previous preedit text
                // shown at the status area.
                if (opts.preedit_style == PreeditStyle.ROOT)
                    update_preedit ();
            });

        update_preedit ();
        update_status ();

        var channel = new IOChannel.unix_new (get_poll_fd ());
        channel.add_watch (IOCondition.IN, watch_func);

        var loop = new MainLoop (null, true);
        loop.run ();

        return true;
    }

    string preedit = "";
    string status = "";
    Fep.GAttribute? status_attr = null;
    Skk.InputMode input_mode = Skk.InputMode.HIRAGANA;

    public Client (Skk.Context context, Options opts) throws GLib.Error {
        Object (address: null);
        init (null);

        this.context = context;
        this.opts = opts;
    }
}
