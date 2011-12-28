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
    /**
     * Initialize libskk.
     *
     * Must be called before using any functions in libskk.
     */
    public static void init () {
        // needed to use static methods defined in some classes
        typeof (Util).class_ref ();
        typeof (Rule).class_ref ();
    }

    /**
     * Type to specify input modes.
     */
    public enum InputMode {
        /**
         * Hiragana like "あいう...".
         */
        HIRAGANA = KanaMode.HIRAGANA,

        /**
         * Katakana like "アイウ...".
         */
        KATAKANA = KanaMode.KATAKANA,

        /**
         * Half-width katakana like "ｱｲｳ...".
         */
        HANKAKU_KATAKANA = KanaMode.HANKAKU_KATAKANA,

        /**
         * Half-width latin like "abc...".
         */
        LATIN,

        /**
         * Full-width latin like "ａｂｃ...".
         */
        WIDE_LATIN,

        LAST,

        /**
         * The default.
         */
        DEFAULT = HIRAGANA,
    }

    /**
     * The main entry point of libskk.
     *
     * Context represents an input context with support for SKK
     * kana-kanji conversion method.
     */
    public class Context : Object {
        ArrayList<Dict> _dictionaries = new ArrayList<Dict> ();

        /**
         * Dictionaries.
         */
        public Dict[] dictionaries {
            owned get {
                return _dictionaries.to_array ();
            }
            set {
                _dictionaries.clear ();
                foreach (var dict in value) {
                    _dictionaries.add (dict);
                }
            }
        }

        /**
         * Current candidates.
         */
        public CandidateList candidates {
            get {
                return state_stack.data.candidates;
            }
        }

        SList<State> state_stack;
        HashMap<Type, StateHandler> handlers =
            new HashMap<Type, StateHandler> ();

        /**
         * Current input mode.
         */
        public InputMode input_mode {
            get {
                return state_stack.data.input_mode;
            }
            set {
                state_stack.data.input_mode = value;
            }
        }

        /**
         * Array of strings which cause automatic conversion.
         */
        public string[] auto_start_henkan_keywords {
            get {
                return state_stack.data.auto_start_henkan_keywords;
            }
            set {
                state_stack.data.auto_start_henkan_keywords = value;
            }
        }

        /**
         * Whether or not consume \n on conversion state.
         */
        public bool egg_like_newline {
            get {
                return state_stack.data.egg_like_newline;
            }
            set {
                state_stack.data.egg_like_newline = value;
            }
        }

        /**
         * Period style used in romaji-to-kana conversion.
         */
        public PeriodStyle period_style {
            get {
                return state_stack.data.period_style;
            }
            set {
                state_stack.data.period_style = value;
            }
        }

        /**
         * The name of typing rule.
         */
        public Rule typing_rule {
            get {
                return state_stack.data.typing_rule;
            }
            set {
                var rule = state_stack.data.typing_rule = value;
                var filter = rule.get_filter ();
                filter.forwarded.connect ((key) => {
                        process_key_event_internal (key);
                    });
            }
        }

        public KeyEventFilter key_event_filter {
            owned get {
                return state_stack.data.typing_rule.get_filter ();
            }
        }

        /**
         * Create a new Context.
         *
         * @param dictionaries an array of Dict
         *
         * @return a new Context
         */
        public Context (Dict[] dictionaries) {
            this.dictionaries = dictionaries;
            handlers.set (typeof (NoneStateHandler),
                          new NoneStateHandler ());
            handlers.set (typeof (StartStateHandler),
                          new StartStateHandler ());
            handlers.set (typeof (SelectStateHandler),
                          new SelectStateHandler ());
            handlers.set (typeof (AbbrevStateHandler),
                          new AbbrevStateHandler ());
            handlers.set (typeof (KutenStateHandler),
                          new KutenStateHandler ());
            state_stack.prepend (new State (_dictionaries));
            connect_state_signals (state_stack.data);
            candidates.notify["cursor-pos"].connect (() => {
                    update_preedit ();
                });
            candidates.selected.connect ((candidate) => {
                    if (select_candidate_in_dictionaries (candidate)) {
                        try {
                            save_dictionaries ();
                        } catch (GLib.Error e) {
                            warning ("error saving dictionaries %s", e.message);
                        }
                    }
                });
        }

        ~Context () {
            _dictionaries.clear ();
        }

        void connect_state_signals (State state) {
            state.recursive_edit_start.connect (start_dict_edit);
            state.recursive_edit_end.connect (end_dict_edit);
            state.recursive_edit_abort.connect (abort_dict_edit);
            state.notify["input-mode"].connect ((s, p) => {
                    notify_property ("input-mode");
                });
            state.retrieve_surrounding_text.connect ((out t, out c) => {
                    return retrieve_surrounding_text (out t, out c);
                });
            state.delete_surrounding_text.connect ((o, n) => {
                    return delete_surrounding_text (o, n);
                });
        }

        /**
         * Signal emitted when the context requires surrounding-text.
         *
         * @param text surrounding text
         * @param cursor_pos cursor position in text
         *
         * @return `true` on success, `false` on failure
         */
        public signal bool retrieve_surrounding_text (out string text,
                                                      out uint cursor_pos);

        /**
         * Signal emitted when the context requests deletion of
         * surrounding-text.
         *
         * @param offset character offset from the cursor position.
         * @param nchars number of characters to delete.
         *
         * @return `true` on success, `false` on failure
         */
        public signal bool delete_surrounding_text (int offset,
                                                    uint nchars);

        bool select_candidate_in_dictionaries (Candidate candidate)
        {
            bool changed = false;
            foreach (var dict in dictionaries) {
                if (!dict.read_only &&
                    dict.select_candidate (candidate)) {
                    changed = true;
                }
            }
            return changed;
        }

        uint dict_edit_level () {
            return state_stack.length () - 1;
        }

        void start_dict_edit (string midasi, bool okuri) {
            var state = new State (_dictionaries);
            state.midasi = midasi;
            state.okuri = okuri;
            state_stack.prepend (state);
            connect_state_signals (state_stack.data);
            update_preedit ();
            notify_property ("candidates");
        }

        bool end_dict_edit (string text) {
            string? midasi;
            bool? okuri;
            if (leave_dict_edit (out midasi, out okuri)) {
                var candidate = new Candidate (midasi, okuri, text);
                if (select_candidate_in_dictionaries (candidate)) {
                    try {
                        save_dictionaries ();
                    } catch (GLib.Error e) {
                        warning ("error saving dictionaries %s", e.message);
                    }
                }
                state_stack.data.reset ();
                state_stack.data.output.assign (text);
                update_preedit ();
                return true;
            }
            return false;
        }

        bool leave_dict_edit (out string? midasi, out bool? okuri) {
            if (dict_edit_level () > 0) {
                midasi = state_stack.data.midasi;
                okuri = state_stack.data.okuri;
                state_stack.delete_link (state_stack);
                state_stack.data.cancel_okuri ();
                notify_property ("candidates");
                return true;
            }
            midasi = null;
            okuri = false;
            return false;
        }

        bool abort_dict_edit () {
            string? midasi;
            bool? okuri;
            if (leave_dict_edit (out midasi, out okuri)) {
                update_preedit ();
                return true;
            }
            return false;
        }

        /**
         * Pass key events (separated by spaces) to the context.  This
         * function is rarely used in programs but in unit tests.
         *
         * @param keyseq a string representing key events, seperated by " "
         *
         * @return `true` if any of key events are handled, `false` otherwise
         */
        public bool process_key_events (string keyseq) {
            ArrayList<string> keys = new ArrayList<string> ();
            var builder = new StringBuilder ();
            bool complex = false;
            bool escaped = false;
            int index = 0;
            unichar uc;
            while (keyseq.get_next_char (ref index, out uc)) {
                if (escaped) {
                    builder.append_unichar (uc);
                    escaped = false;
                    continue;
                }
                switch (uc) {
                case '\\':
                    escaped = true;
                    break;
                case '(':
                    if (complex) {
                        warning ("bare '(' is not allowed in complex keyseq");
                        return false;
                    }
                    complex = true;
                    builder.append_unichar (uc);
                    break;
                case ')':
                    if (!complex) {
                        warning ("bare ')' is not allowed in simple keyseq");
                        return false;
                    }
                    complex = false;
                    builder.append_unichar (uc);
                    keys.add (builder.str);
                    builder.erase ();
                    break;
                case ' ':
                    if (complex) {
                        builder.append_unichar (uc);
                    }
                    else if (builder.len > 0) {
                        keys.add (builder.str);
                        builder.erase ();
                    }
                    break;
                default:
                    builder.append_unichar (uc);
                    break;
                }
            }
            if (complex) {
                warning ("premature end of key events");
                return false;
            }
            if (builder.len > 0) {
                keys.add (builder.str);
            }

            bool retval = false;
            foreach (var key in keys) {
                if (key == "SPC")
                    key = " ";
                else if (key == "TAB")
                    key = "\t";
                else if (key == "RET")
                    key = "\n";
                else if (key == "DEL")
                    key = "\b";
                var ev = new KeyEvent.from_string (key);
                if (process_key_event (ev) && !retval)
                    retval = true;
            }
            return retval;
        }

        /**
         * Pass one key event to the context.
         *
         * @param key a key event
         *
         * @return `true` if the key event is handled, `false` otherwise
         */
        public bool process_key_event (KeyEvent key) {
            KeyEvent? _key = key_event_filter.filter_key_event (key);
            if (_key == null)
                return true;
            return process_key_event_internal (_key);
        }

        bool process_key_event_internal (KeyEvent key) {
            KeyEvent _key = key.copy ();
            var state = state_stack.data;
            while (true) {
                var handler_type = state.handler_type;
                var handler = handlers.get (handler_type);
                if (handler.process_key_event (state, ref _key)) {
                    // FIXME should do this only when preedit is really changed
                    update_preedit ();
                    return true;
                }
                // state.handler_type may change if handler cannot
                // handle the event.  In that case retry with the new
                // handler.  Otherwise exit the loop.
                if (handler_type == state.handler_type) {
                    // consume all events when we are in dict edit mode
                    return dict_edit_level () > 0;
                }
            }
        }

        /**
         * Reset the context.
         */
        public void reset () {
            var state = state_stack.data;
            state_stack = null;
            state_stack.prepend (state);
            state.reset ();
            notify_property ("candidates");
        }

        /**
         * This is replaced with {@link poll_output}.
         *
         * @return an output string
         * @deprecated 0.0.6
         */
        public string get_output () {
            return poll_output ();
        }

        string retrieve_output (bool clear) {
            var state = state_stack.data;
            var handler = handlers.get (state.handler_type);
            if (dict_edit_level () > 0) {
                return "";
            } else {
                var output = handler.get_output (state);
                if (clear) {
                    state.output.erase ();
                }
                return output;
            }
        }

        /**
         * Peek (retrieve, but not remove) the current output string.
         *
         * @return an output string
         * @since 0.0.6
         */
        public string peek_output () {
            return retrieve_output (false);
        }

        /**
         * Poll (retrieve and remove) the current output string.
         *
         * @return an output string
         * @since 0.0.6
         */
        public string poll_output () {
            return retrieve_output (true);
        }

        /**
         * Current preedit string.
         */
        public string preedit { get; private set; default = ""; }

        void update_preedit () {
            var state = state_stack.data;
            var handler = handlers.get (state.handler_type);
            var builder = new StringBuilder ();
            if (dict_edit_level () > 0) {
                var level = dict_edit_level ();
                for (var i = 0; i < level; i++) {
                    builder.append_c ('[');
                }
                builder.append (_("DictEdit"));
                for (var i = 0; i < level; i++) {
                    builder.append_c (']');
                }
                builder.append (" ");
                builder.append (state_stack.data.midasi);
                builder.append (" ");
                builder.append (handler.get_output (state));
            }
            uint offset = (uint) builder.str.char_count ();
            uint underline_offset, underline_nchars;
            builder.append (handler.get_preedit (state,
                                                 out underline_offset,
                                                 out underline_nchars));
            preedit_underline_offset = offset + underline_offset;
            preedit_underline_nchars = underline_nchars;
            preedit = builder.str;
        }

        uint preedit_underline_offset;
        uint preedit_underline_nchars;

        /**
         * Get underlined range of preedit.
         *
         * @param offset starting offset (in chars) of underline
         * @param nchars number of characters to be underlined
         * @since 0.0.6
         */
        public void get_preedit_underline (out uint offset, out uint nchars) {
            offset = preedit_underline_offset;
            nchars = preedit_underline_nchars;
        }

        /**
         * Save dictionaries on to disk.
         */
        public void save_dictionaries () throws GLib.Error {
            foreach (var dict in dictionaries) {
                if (!dict.read_only) {
                    dict.save ();
                }
            }
        }
    }
}
