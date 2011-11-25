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
    public static const string[] AUTO_START_HENKAN_KEYWORDS = {
        "を", "、", "。", "．", "，", "？", "」",
        "！", "；", "：", ")", ";", ":", "）",
        "”", "】", "』", "》", "〉", "｝", "］",
        "〕", "}", "]", "?", ".", ",", "!"
    };

    class State : Object {
        internal Type handler_type;
        InputMode _input_mode;
        internal InputMode input_mode {
            get {
                return _input_mode;
            }
            set {
                output.append (rom_kana_converter.output);
                reset ();
                _input_mode = value;
                switch (_input_mode) {
                case InputMode.HIRAGANA:
                case InputMode.KATAKANA:
                case InputMode.HANKAKU_KATAKANA:
                    rom_kana_converter.kana_mode = (KanaMode) value;
                    okuri_rom_kana_converter.kana_mode = (KanaMode) value;
                    break;
                default:
                    break;
                }
            }
        }

        internal Dict[] dictionaries;
        internal string midasi;
        internal CandidateList candidates;

        internal RomKanaConverter rom_kana_converter;
        internal RomKanaConverter okuri_rom_kana_converter;

        internal StringBuilder output = new StringBuilder ();
        internal StringBuilder abbrev = new StringBuilder ();
        internal StringBuilder kuten = new StringBuilder ();

        internal Iterator<string>? completion_iterator;

        internal string[] auto_start_henkan_keywords;
        internal string? auto_start_henkan_keyword = null;

        internal bool egg_like_newline = false;

        internal PeriodStyle period_style {
            get {
                return rom_kana_converter.period_style;
            }
            set {
                rom_kana_converter.period_style = value;
                okuri_rom_kana_converter.period_style = value;
            }
        }

        internal string rom_kana_rule {
            get {
                return rom_kana_converter.rule;
            }
            set {
                rom_kana_converter.rule = value;
                okuri_rom_kana_converter.rule = value;
            }
        }
        
        internal State (Dict[] dictionaries, CandidateList candidates) {
            this.dictionaries = dictionaries;
            this.candidates = candidates;
            this.rom_kana_converter = new RomKanaConverter ();
            this.okuri_rom_kana_converter = new RomKanaConverter ();
            this.auto_start_henkan_keywords = AUTO_START_HENKAN_KEYWORDS;
            reset ();
        }

        internal void reset () {
            handler_type = typeof (NoneStateHandler);
            _input_mode = InputMode.DEFAULT;
            rom_kana_converter.reset ();
            okuri_rom_kana_converter.reset ();
            completion_iterator = null;
            candidates.clear ();
            abbrev.erase ();
            kuten.erase ();
            auto_start_henkan_keyword = null;
        }

        internal void lookup (string midasi, bool okuri = false) {
            this.midasi = midasi;
            candidates.clear ();
            foreach (var dict in dictionaries) {
                candidates.add_all (dict.lookup (midasi, okuri));
            }
            candidates.populate ();
        }

        internal void purge_candidate (string midasi, Candidate candidate, bool okuri = false) {
            foreach (var dict in dictionaries) {
                if (!dict.read_only) {
                    dict.purge_candidate (midasi, candidate);
                }
            }
        }

        internal signal bool recursive_edit_abort ();
        internal signal bool recursive_edit_end (string text);
        internal signal void recursive_edit_start (string midasi);

        internal string get_yomi () {
            StringBuilder builder = new StringBuilder ();
            if (abbrev.len > 0) {
                builder.append (abbrev.str);
            }
            else if (okuri_rom_kana_converter.is_active ()) {
                builder.append (rom_kana_converter.output);
                builder.append ("*");
                builder.append (okuri_rom_kana_converter.output);
                builder.append (okuri_rom_kana_converter.preedit);
            }
            else {
                builder.append (rom_kana_converter.output);
                builder.append (rom_kana_converter.preedit);
            }
            return builder.str;
        }
    }

    abstract class StateHandler : Object {
        internal abstract bool process_key_event (State state, KeyEvent key);
        internal abstract string get_preedit (State state);
        internal virtual string get_output (State state) {
            return state.output.str;
        }
    }

    class NoneStateHandler : StateHandler {
        internal override bool process_key_event (State state, KeyEvent key) {
            // check abort and commit event
            if ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                key.code == 'g') {
                bool retval;
                if (state.rom_kana_converter.preedit.length > 0) {
                    retval = true;
                } else {
                    retval = state.recursive_edit_abort ();
                }
                var input_mode = state.input_mode;
                state.reset ();
                state.input_mode = input_mode;
                return retval;
            } else if ((key.modifiers == 0 && key.code == '\n') ||
                       ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                        key.code == 'm')) {
                bool retval;
                if (state.rom_kana_converter.preedit.length > 0) {
                    retval = true;
                }
                else if (state.output.str.length == 0) {
                    retval = state.recursive_edit_abort ();
                }
                else {
                    retval = state.recursive_edit_end (state.output.str);
                }
                var input_mode = state.input_mode;
                state.reset ();
                state.input_mode = input_mode;
                return retval;
            } else if (key.modifiers == 0 && key.code == 'Q') {
                state.handler_type = typeof (StartStateHandler);
                return true;
            }

            // check mode switch events
            switch (state.input_mode) {
            case InputMode.HIRAGANA:
                if (key.modifiers == 0 &&
                    state.rom_kana_converter.is_active () &&
                    state.rom_kana_converter.can_consume (key.code)) {
                    // do nothing and proceed to rom-kana conversion
                }
                else if (key.modifiers == 0 && key.code == 'q') {
                    state.input_mode = InputMode.KATAKANA;
                    return true;
                }
                else if ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                         key.code == 'q') {
                    state.input_mode = InputMode.HANKAKU_KATAKANA;
                    return true;
                }
                else if (key.modifiers == 0 && key.code == 'l') {
                    state.input_mode = InputMode.LATIN;
                    return true;
                }
                else if (key.modifiers == 0 && key.code == 'L') {
                    state.input_mode = InputMode.WIDE_LATIN;
                    return true;
                }
                break;
            case InputMode.KATAKANA:
                if (key.modifiers == 0 &&
                    state.rom_kana_converter.is_active () &&
                    state.rom_kana_converter.can_consume (key.code)) {
                }
                else if (key.modifiers == 0 && key.code == 'q') {
                    state.input_mode = InputMode.HIRAGANA;
                    return true;
                }
                else if ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                         key.code == 'q') {
                    state.input_mode = InputMode.HANKAKU_KATAKANA;
                    return true;
                }
                else if (key.modifiers == 0 && key.code == 'l') {
                    state.input_mode = InputMode.LATIN;
                    return true;
                }
                else if (key.modifiers == 0 && key.code == 'L') {
                    state.input_mode = InputMode.WIDE_LATIN;
                    return true;
                }
                break;
            case InputMode.HANKAKU_KATAKANA:
                if (key.modifiers == 0 &&
                    state.rom_kana_converter.is_active () &&
                    state.rom_kana_converter.can_consume (key.code)) {
                }
                else if ((key.modifiers == 0 && key.code == 'q') ||
                         ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                          key.code == 'q')) {
                    state.input_mode = InputMode.HIRAGANA;
                    return true;
                }
                else if (key.modifiers == 0 && key.code == 'l') {
                    state.input_mode = InputMode.LATIN;
                    return true;
                }
                else if (key.modifiers == 0 && key.code == 'L') {
                    state.input_mode = InputMode.WIDE_LATIN;
                    return true;
                }
                break;
            case InputMode.LATIN:
            case InputMode.WIDE_LATIN:
                if (((key.modifiers & ModifierType.CONTROL_MASK) != 0) &&
                    key.code == 'j') {
                    state.input_mode = InputMode.HIRAGANA;
                    return true;
                }
                break;
            }

            // check editing events
            if ((key.modifiers == 0 && key.code == '\x7F') ||
                ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                 key.code == 'h')) {
                if (state.rom_kana_converter.delete ()) {
                    return true;
                }
                if (state.output.len > 0) {
                    state.output.truncate (
                        state.output.str.index_of_nth_char (
                            state.output.str.char_count () - 1));
                    return true;
                }
                return false;
            }

            switch (state.input_mode) {
            case InputMode.HIRAGANA:
            case InputMode.KATAKANA:
            case InputMode.HANKAKU_KATAKANA:
                if (key.modifiers == 0 && key.code.isalpha () &&
                    key.code.isupper ()) {
                    state.handler_type = typeof (StartStateHandler);
                    return false;
                }
                else if (key.modifiers == 0 &&
                         !state.rom_kana_converter.can_consume (key.code,
                                                                true)) {
                    if (key.code == '/') {
                        state.handler_type = typeof (AbbrevStateHandler);
                        return true;
                    }
                    else if (key.code == '\\') {
                        state.handler_type = typeof (KutenStateHandler);
                        return true;
                    }
                }
                if (key.modifiers == 0) {
                    if (state.rom_kana_converter.append (key.code)) {
                        state.output.append (state.rom_kana_converter.output);
                        state.rom_kana_converter.output = "";
                        return true;
                    }
                    else {
                        state.rom_kana_converter.output = "";
                        return false;
                    }
                }
                break;
            case InputMode.LATIN:
                if (0x20 <= key.code && key.code <= 0x7F) {
                    state.output.append_c ((char)key.code);
                    return true;
                }
                break;
            case InputMode.WIDE_LATIN:
                if (0x20 <= key.code && key.code <= 0x7F) {
                    state.output.append_unichar (
                        Util.get_wide_latin_char ((char)key.code));
                    return true;
                }
                break;
            }
            return false;
        }

        internal override string get_preedit (State state) {
            StringBuilder builder = new StringBuilder ();
            if (state.rom_kana_converter.is_active ()) {
                builder.append (state.rom_kana_converter.preedit);
            }
            return builder.str;
        }
    }

    class KutenStateHandler : StateHandler {
        EncodingConverter converter;

        internal KutenStateHandler () {
            try {
                converter = new EncodingConverter ("EUC-JP");
            } catch (GLib.Error e) {
                converter = null;
            }
        }

        int hex_char_to_int (char hex) {
            if ('0' <= hex && hex <= '9') {
                return hex - '0';
            } else if ('a' <= hex.tolower () && hex.tolower () <= 'f') {
                return hex - 'a' + 10;
            }
            return -1;
        }

        string parse_hex (string hex) {
            var builder = new StringBuilder ();
            for (var i = 0; i < hex.length - 1; i += 2) {
                int c = (hex_char_to_int (hex[i]) << 4) |
                    hex_char_to_int (hex[i + 1]);
                builder.append_c ((char)c);
            }
            return builder.str;
        }

        internal override bool process_key_event (State state, KeyEvent key) {
            if ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                key.code == 'g') {
                var input_mode = state.input_mode;
                state.reset ();
                state.input_mode = input_mode;
                return true;
            }
            else if (key.modifiers == 0 && key.code == '\n' &&
                (state.kuten.len == 4 || state.kuten.len == 6)) {
                if (converter != null) {
                    // FIXME JISX0208 is represented as equivalent
                    // byte sequences in EUC-JP
                    var euc = parse_hex (state.kuten.str);
                    try {
                        state.output.append (converter.decode (euc));
                    } catch (GLib.Error e) {
                    }
                }
                var input_mode = state.input_mode;
                state.reset ();
                state.input_mode = input_mode;
                return true;
            }
            else if ((key.modifiers == 0 && key.code == '\x7F') ||
                     ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                      key.code == 'h') &&
                     state.kuten.len > 0) {
                state.kuten.truncate (state.kuten.len - 1);
                return true;
            }
            else if (key.modifiers == 0 &&
                       (('a' <= key.code && key.code <= 'f') ||
                        ('A' <= key.code && key.code <= 'F') ||
                        ('0' <= key.code && key.code <= '9')) &&
                       state.kuten.len < 6) {
                state.kuten.append_unichar (key.code);
                return true;
            }
            return true;
        }

        internal override string get_preedit (State state) {
            return "Kuten([MM]KKTT) " + state.kuten.str;
        }
    }

    class AbbrevStateHandler : StateHandler {
        internal override bool process_key_event (State state, KeyEvent key) {
            if ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                key.code == 'g') {
                var input_mode = state.input_mode;
                state.reset ();
                state.input_mode = input_mode;
                return true;
            }
            else if (key.modifiers == 0 && key.code == ' ') {
                state.handler_type = typeof (SelectStateHandler);
                return false;
            }
            else if ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                     key.code == 'q') {
                state.output.assign (
                    Util.get_wide_latin (state.abbrev.str));
                var input_mode = state.input_mode;
                state.reset ();
                state.input_mode = input_mode;
                return true;
            }
            else if ((key.modifiers == 0 && key.code == '\x7F') ||
                     ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                      key.code == 'h')) {
                if (state.abbrev.len > 0) {
                    state.abbrev.truncate (state.abbrev.len - 1);
                } else {
                    var input_mode = state.input_mode;
                    state.reset ();
                    state.input_mode = input_mode;
                }
                return true;
            }
            else if (key.modifiers == 0 &&
                     0x20 <= key.code && key.code <= 0x7E) {
                state.abbrev.append_unichar (key.code);
                return true;
            }
            return true;
        }

        internal override string get_preedit (State state) {
            return "▽" + state.abbrev.str;
        }
    }

    class StartStateHandler : StateHandler {
        internal override bool process_key_event (State state, KeyEvent key) {
            if ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                key.code == 'g') {
                var input_mode = state.input_mode;
                state.reset ();
                state.input_mode = input_mode;
                return true;
            }
            else if (key.modifiers == 0 && key.code == 'q' &&
                     (state.input_mode == InputMode.HIRAGANA ||
                      state.input_mode == InputMode.KATAKANA ||
                      state.input_mode == InputMode.HANKAKU_KATAKANA)) {
                state.rom_kana_converter.output_nn_if_any ();
                switch (state.input_mode) {
                case InputMode.HIRAGANA:
                    state.output.assign (
                        Util.get_katakana (state.rom_kana_converter.output));
                    state.rom_kana_converter.reset ();
                    state.input_mode = InputMode.KATAKANA;
                    state.handler_type = typeof (NoneStateHandler);
                    break;
                case InputMode.KATAKANA:
                    state.output.assign (
                        Util.get_hiragana (state.rom_kana_converter.output));
                    state.rom_kana_converter.reset ();
                    state.input_mode = InputMode.HIRAGANA;
                    state.handler_type = typeof (NoneStateHandler);
                    break;
                case InputMode.HANKAKU_KATAKANA:
                    state.output.assign (
                        Util.get_hiragana (state.rom_kana_converter.output));
                    state.rom_kana_converter.reset ();
                    state.handler_type = typeof (NoneStateHandler);
                    break;
                }
                return true;
            }
            else if (key.modifiers == 0 && key.code == ' ') {
                if (!state.rom_kana_converter.is_active ()) {
                    state.reset ();
                    return true;
                }
                state.handler_type = typeof (SelectStateHandler);
                return false;
            }
            else if ((key.modifiers == 0 && key.code == '\n') ||
                     ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                      key.code == 'j')) {
                state.output.append (state.rom_kana_converter.output);
                state.reset ();
                return true;
            }
            else if ((key.modifiers == 0 && key.code == '\x7F') ||
                     ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                      key.code == 'h')) {
                if (state.okuri_rom_kana_converter.delete () ||
                    state.rom_kana_converter.delete ()) {
                    return true;
                }
                if (state.output.len > 0) {
                    state.output.truncate (
                        state.output.str.index_of_nth_char (
                            state.output.str.char_count () - 1));
                    return true;
                }
                state.handler_type = typeof (NoneStateHandler);
                return true;
            }
            else if ((key.modifiers == 0 && key.code == '\t') ||
                     ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                      key.code == 'i')) {
                if (state.completion_iterator == null) {
                    var completion = new TreeSet<string> ();
                    foreach (var dict in state.dictionaries) {
                        string[] _completion = dict.complete (state.rom_kana_converter.output);
                        foreach (var c in _completion) {
                            completion.add (c);
                        }
                    }
                    if (!completion.is_empty) {
                        state.completion_iterator = completion.iterator_at (completion.first ());
                        state.completion_iterator.next ();
                    }
                }
                if (state.completion_iterator != null) {
                    string midasi = state.completion_iterator.get ();
                    state.rom_kana_converter.reset ();
                    state.rom_kana_converter.output = midasi;
                    if (state.completion_iterator.has_next ()) {
                        state.completion_iterator.next ();
                    }
                }
                return true;
            }
            else if (key.modifiers == 0 && key.code.isalpha ()) {
                // okuri_rom_kana_converter is started or being started
                if (state.okuri_rom_kana_converter.is_active () ||
                    (key.code.isupper () &&
                     state.rom_kana_converter.is_active () &&
                     !state.rom_kana_converter.can_consume (
                         key.code.tolower (), true))) {
                    if (state.rom_kana_converter.preedit.length > 0) {
                        state.rom_kana_converter.append (key.code.tolower ());
                    }
                    state.rom_kana_converter.output_nn_if_any ();
                    state.okuri_rom_kana_converter.append (key.code.tolower ());
                    if (state.okuri_rom_kana_converter.preedit.length == 0) {
                        state.handler_type = typeof (SelectStateHandler);
                        key.code = ' ';
                        return false;
                    }
                    return true;
                }
                else {
                    state.rom_kana_converter.append (key.code.tolower ());
                    if (check_auto_conversion (state, key)) {
                        state.handler_type = typeof (SelectStateHandler);
                        key.code = ' ';
                        return false;
                    }
                    return true;
                }
            }
            else if (key.modifiers == 0 && key.code == '>') {
                if (state.rom_kana_converter.is_active ()) {
                    state.rom_kana_converter.append (key.code.tolower ());
                    state.handler_type = typeof (SelectStateHandler);
                    key.code = ' ';
                    return false;
                }
                else {
                    state.rom_kana_converter.append (key.code);
                    return true;
                }
            }
            else if (key.modifiers == 0) {
                state.rom_kana_converter.append (key.code.tolower ());
                if (check_auto_conversion (state, key)) {
                    state.handler_type = typeof (SelectStateHandler);
                    key.code = ' ';
                    return false;
                }
                return true;
            }
            // mark any other key events are consumed here
            return true;
        }

        internal override string get_preedit (State state) {
            StringBuilder builder = new StringBuilder ("▽");
            builder.append (state.get_yomi ());
            return builder.str;
        }

        bool check_auto_conversion (State state, KeyEvent key) {
            foreach (var keyword in state.auto_start_henkan_keywords) {
                if (state.rom_kana_converter.output.length > keyword.length &&
                    state.rom_kana_converter.output.has_suffix (keyword)) {
                    state.auto_start_henkan_keyword = keyword;
                    state.rom_kana_converter.output = state.rom_kana_converter.output[0:-keyword.length];
                    state.handler_type = typeof (SelectStateHandler);
                    return true;
                }
            }
            return false;
        }
    }

    class SelectStateHandler : StateHandler {
        internal override bool process_key_event (State state, KeyEvent key) {
            if (key.modifiers == 0 && key.code == 'x') {
                state.candidates.cursor_pos--;
                if (state.candidates.cursor_pos < 0) {
                    state.handler_type = typeof (StartStateHandler);
                }
            }
            else if (key.modifiers == 0 && key.code == 'X') {
                state.purge_candidate (state.midasi,
                                       state.candidates.get ());
                state.reset ();
            }
            else if (key.modifiers == 0 && key.code == ' ') {
                if (state.candidates.cursor_pos < 0) {
                    string midasi;
                    bool okuri = false;
                    if (state.abbrev.len > 0) {
                        midasi = state.abbrev.str;
                    }
                    else {
                        StringBuilder builder = new StringBuilder ();
                        state.rom_kana_converter.output_nn_if_any ();
                        builder.append (state.rom_kana_converter.output);
                        if (state.okuri_rom_kana_converter.is_active ()) {
                            builder.append_unichar (
                                state.okuri_rom_kana_converter.input[0]);
                            okuri = true;
                        }
                        midasi = Util.get_hiragana (builder.str);
                    }
                    state.lookup (midasi, okuri);
                }

                if (state.candidates.cursor_pos < state.candidates.size - 1) {
                    state.candidates.cursor_pos++;
                }
                else {
                    state.recursive_edit_start (state.get_yomi ());
                    if (state.candidates.size == 0) {
                        state.handler_type = typeof (StartStateHandler);
                    }
                }
            }
            else if ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                     key.code == 'g') {
                state.candidates.clear ();
                state.handler_type = typeof (StartStateHandler);
            }
            else {
                var c = state.candidates.get ();
                state.output.append (c.text);
                if (state.auto_start_henkan_keyword != null) {
                    state.output.append (state.auto_start_henkan_keyword);
                }
                else if (state.okuri_rom_kana_converter.is_active ()) {
                    state.output.append (state.okuri_rom_kana_converter.output);
                }
                state.reset ();
                if (key.modifiers == 0 && key.code == '>') {
                    state.handler_type = typeof (StartStateHandler);
                    return false;
                }
                else if ((key.modifiers == 0 && key.code.isalpha ()) ||
                         (key.modifiers == 0 && key.code == '\x7F') ||
                         (!state.egg_like_newline &&
                          (key.modifiers == 0 && key.code == '\n'))) {
                    return false;
                }
            }
            // mark any other key events are consumed here
            return true;
        }

        internal override string get_preedit (State state) {
            StringBuilder builder = new StringBuilder ("▼");
            if (state.candidates.cursor_pos >= 0) {
                var c = state.candidates.get ();
                builder.append (c.text);
            } else {
                builder.append (state.rom_kana_converter.output);
            }
            if (state.auto_start_henkan_keyword != null) {
                builder.append (state.auto_start_henkan_keyword);
            }
            else if (state.okuri_rom_kana_converter.is_active ()) {
                builder.append (state.okuri_rom_kana_converter.output);
            }
            return builder.str;
        }
    }
}
