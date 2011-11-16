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
    public enum InputMode {
        HIRAGANA = KanaMode.HIRAGANA,
        KATAKANA = KanaMode.KATAKANA,
        HANKAKU_KATAKANA = KanaMode.HANKAKU_KATAKANA,
        LATIN,
        WIDE_LATIN,
        DEFAULT = HIRAGANA
    }

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
        internal ArrayList<Candidate> candidates = new ArrayList<Candidate> ();
        internal int candidate_index;

        internal RomKanaConverter rom_kana_converter;
        internal RomKanaConverter okuri_rom_kana_converter;

        internal StringBuilder output = new StringBuilder ();

        internal bool in_abbrev = false;
        internal StringBuilder abbrev = new StringBuilder ();

        internal Iterator<string>? completion_iterator;

        internal State (Dict[] dictionaries) {
            this.dictionaries = dictionaries;
            this.rom_kana_converter = new RomKanaConverter ();
            this.okuri_rom_kana_converter = new RomKanaConverter ();
            reset ();
        }

        internal void reset () {
            handler_type = typeof (NoneStateHandler);
            _input_mode = InputMode.DEFAULT;
            rom_kana_converter.reset ();
            okuri_rom_kana_converter.reset ();
            completion_iterator = null;
            candidates.clear ();
            candidate_index = -1;
            in_abbrev = false;
            abbrev.erase ();
        }

        internal void lookup (string midasi, bool okuri = false) {
            this.midasi = midasi;
            candidates.clear ();
            candidate_index = -1;
            foreach (var dict in dictionaries) {
                var _candidates = dict.lookup (midasi, okuri);
                foreach (var c in _candidates) {
                    candidates.add (c);
                }
            }
        }

        internal signal void enter_dict_edit (string midasi);
        internal signal void leave_dict_edit ();
        internal signal void abort_dict_edit ();
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
            if ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                key.code == 'g') {
                bool handled = true;
                if (state.rom_kana_converter.preedit == "") {
                    handled = false;
                }
                var input_mode = state.input_mode;
                state.reset ();
                state.input_mode = input_mode;
                return handled;
            } else if (key.modifiers == 0 && key.code == 'Q') {
                state.handler_type = typeof (StartStateHandler);
                return true;
            }
            // check the mode switch first
            switch (state.input_mode) {
            case InputMode.HIRAGANA:
                if (key.modifiers == 0 &&
                    state.rom_kana_converter.is_active () &&
                    state.rom_kana_converter.can_consume (key.code)) {
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

            if ((key.modifiers == 0 && key.code == '\x7F') ||
                (key.modifiers & ModifierType.CONTROL_MASK) != 0) {
                if (state.rom_kana_converter.delete ()) {
                    return true;
                }
                if (state.output.len > 0) {
                    state.output.truncate (
                        state.output.str.index_of_nth_char (
                            state.output.str.char_count () - 1));
                    return true;
                }
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
                else if (key.modifiers == 0 && key.code == '/' &&
                         !state.rom_kana_converter.can_consume (
                             key.code, true)) {
                    state.handler_type = typeof (StartStateHandler);
                    state.in_abbrev = true;
                    return true;
                }
                state.rom_kana_converter.append (key.code);
                state.output.append (state.rom_kana_converter.output);
                state.rom_kana_converter.output = "";
                break;
            case InputMode.LATIN:
                state.output.append_c ((char)key.code);
                break;
            case InputMode.WIDE_LATIN:
                state.output.append_unichar (
                    Util.get_wide_latin_char ((char)key.code));
                break;
            }
            return true;
        }

        internal override string get_preedit (State state) {
            StringBuilder builder = new StringBuilder ();
            if (state.rom_kana_converter.is_active ()) {
                builder.append (state.rom_kana_converter.preedit);
            }
            return builder.str;
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
            else if (state.in_abbrev &&
                     (key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                     key.code == 'q') {
                state.output.assign (
                    Util.get_wide_latin (state.abbrev.str));
                var input_mode = state.input_mode;
                state.reset ();
                state.input_mode = input_mode;
                return true;
            }
            else if (!state.in_abbrev &&
                     key.modifiers == 0 && key.code == 'q' &&
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
                if (!state.in_abbrev &&
                    !state.rom_kana_converter.is_active ()) {
                    state.reset ();
                    return true;
                }
                state.handler_type = typeof (SelectStateHandler);
                return false;
            }
            else if (key.modifiers == 0 && key.code == '\n') {
                state.output.append (state.rom_kana_converter.output);
                state.reset ();
                return true;
            }
            else if ((key.modifiers == 0 && key.code == '\x7F') ||
                     (key.modifiers & ModifierType.CONTROL_MASK) != 0) {
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
                     (key.modifiers & ModifierType.CONTROL_MASK) != 0) {
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
            else if (key.modifiers == 0 &&
                     0x20 <= key.code && key.code <= 0x7E &&
                     state.in_abbrev) {
                state.abbrev.append_unichar (key.code);
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
                    return true;
                }
            }
            else if (state.rom_kana_converter.is_active () &&
                     (key.modifiers == 0 && key.code == '>')) {
                state.rom_kana_converter.append (key.code.tolower ());
                state.handler_type = typeof (SelectStateHandler);
                key.code = ' ';
                return false;
            }
            else {
                state.rom_kana_converter.append (key.code.tolower ());
                return true;
            }
            return false;
        }

        internal override string get_preedit (State state) {
            StringBuilder builder = new StringBuilder ("▽");
            if (state.in_abbrev) {
                builder.append (state.abbrev.str);
            }
            else if (state.okuri_rom_kana_converter.is_active ()) {
                builder.append (state.rom_kana_converter.output);
                builder.append ("*");
                builder.append (state.okuri_rom_kana_converter.output);
                builder.append (state.okuri_rom_kana_converter.preedit);
            }
            else {
                builder.append (state.rom_kana_converter.output);
                builder.append (state.rom_kana_converter.preedit);
            }
            return builder.str;
        }
    }

    class SelectStateHandler : StateHandler {
        internal override bool process_key_event (State state, KeyEvent key) {
            if (key.modifiers == 0 && key.code == 'x') {
                state.candidate_index--;
                if (state.candidate_index >= 0) {
                    // state.preedit_updated ();
                    return true;
                } else {
                    state.handler_type = typeof (StartStateHandler);
                    return true;
                }
            }
            else if (key.modifiers == 0 && key.code == ' ') {
                if (state.candidate_index < 0) {
                    StringBuilder builder = new StringBuilder (state.rom_kana_converter.output);
                    bool okuri = false;
                    if (state.in_abbrev) {
                        builder.append (state.abbrev.str);
                    }
                    else if (state.okuri_rom_kana_converter.is_active ()) {
                        builder.append_unichar (
                            state.okuri_rom_kana_converter.input[0]);
                        okuri = true;
                    }
                    state.lookup (builder.str, okuri);
                }

                if (state.candidate_index < state.candidates.size - 1) {
                    state.candidate_index++;
                    // state.preedit_updated ();
                    return true;
                } else {
                    state.enter_dict_edit (state.midasi);
                    if (state.candidates.size == 0) {
                        state.handler_type = typeof (StartStateHandler);
                    }
                    return true;
                }
            }
            else {
                var c = state.candidates.get (state.candidate_index);
                state.output.append (c.text);
                if (state.okuri_rom_kana_converter.is_active ()) {
                    state.output.append (state.okuri_rom_kana_converter.output);
                }
                state.reset ();
                if (key.modifiers == 0 && key.code == '>') {
                    state.handler_type = typeof (StartStateHandler);
                    return false;
                }
                else if ((key.modifiers == 0 && key.code.isalpha ()) ||
                         (key.modifiers == 0 && key.code == '\x7F') ||
                         (key.modifiers & ModifierType.CONTROL_MASK) != 0) {
                    state.handler_type = typeof (NoneStateHandler);
                    return false;
                }
                return true;
            }
            return false;
        }

        internal override string get_preedit (State state) {
            StringBuilder builder = new StringBuilder ("▼");
            if (state.candidate_index >= 0) {
                var c = state.candidates.get (state.candidate_index);
                builder.append (c.text);
            } else {
                builder.append (state.rom_kana_converter.output);
            }                    
            if (state.okuri_rom_kana_converter.is_active ()) {
                builder.append (state.okuri_rom_kana_converter.output);
            }
            return builder.str;
        }
    }
}
