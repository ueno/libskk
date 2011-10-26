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
            }
        }

        internal Dict[] dictionaries;
        internal ArrayList<Candidate> candidates = new ArrayList<Candidate> ();
        internal int candidate_index;

        internal RomKanaConverter rom_kana_converter;
        internal RomKanaConverter okuri_rom_kana_converter;

        internal StringBuilder output = new StringBuilder ();

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
            candidates.clear ();
            candidate_index = -1;
        }

        internal void lookup (string midasi, bool okuri = false) {
            candidates.clear ();
            candidate_index = -1;
            foreach (var dict in dictionaries) {
                var _candidates = dict.lookup (midasi, okuri);
                foreach (var c in _candidates) {
                    candidates.add (c);
                }
            }
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
            // check the mode switch first
            switch (state.input_mode) {
            case InputMode.HIRAGANA:
                if (key.modifiers == 0 && key.code == 'q') {
                    state.input_mode = InputMode.KATAKANA;
                    return true;
                } else if ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                           key.code == 'q') {
                    state.input_mode = InputMode.HANKAKU_KATAKANA;
                    return true;
                } else if (key.modifiers == 0 && key.code == 'l') {
                    state.input_mode = InputMode.LATIN;
                    return true;
                } else if (key.modifiers == 0 && key.code == 'L') {
                    state.input_mode = InputMode.WIDE_LATIN;
                    return true;
                }
                break;
            case InputMode.KATAKANA:
                if (key.modifiers == 0 && key.code == 'q') {
                    state.input_mode = InputMode.HIRAGANA;
                    return true;
                } else if ((key.modifiers & ModifierType.CONTROL_MASK) != 0 &&
                           key.code == 'q') {
                    state.input_mode = InputMode.HANKAKU_KATAKANA;
                    return true;
                } else if (key.modifiers == 0 && key.code == 'l') {
                    state.input_mode = InputMode.LATIN;
                    return true;
                } else if (key.modifiers == 0 && key.code == 'L') {
                    state.input_mode = InputMode.WIDE_LATIN;
                    return true;
                }
                break;
            case InputMode.HANKAKU_KATAKANA:
                if ((key.modifiers == 0 ||
                     (key.modifiers & ModifierType.CONTROL_MASK) != 0) &&
                    key.code == 'q') {
                    state.input_mode = InputMode.HIRAGANA;
                    return true;
                } else if (key.modifiers == 0 && key.code == 'l') {
                    state.input_mode = InputMode.LATIN;
                    return true;
                } else if (key.modifiers == 0 && key.code == 'L') {
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

            switch (state.input_mode) {
            case InputMode.HIRAGANA:
            case InputMode.KATAKANA:
            case InputMode.HANKAKU_KATAKANA:
                if (key.code.isalpha () && key.code.isupper ()) {
                    state.handler_type = typeof (StartStateHandler);
                    return false;
                }
                state.rom_kana_converter.append ((char)key.code);
                state.output.append (state.rom_kana_converter.output);
                state.rom_kana_converter.output = "";
                break;
            case InputMode.LATIN:
                state.output.append_c ((char)key.code);
                break;
            case InputMode.WIDE_LATIN:
                state.output.append_unichar (Util.get_wide_latin_char ((char)key.code));
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
            if (key.code == ' ') {
                if (!state.rom_kana_converter.is_active ()) {
                    state.reset ();
                    return true;
                }
                state.handler_type = typeof (SelectStateHandler);
                return false;
            } else if (key.code == '\n') {
                state.output.append (state.rom_kana_converter.output);
                state.reset ();
                return true;
            } else if (key.code.isalpha () && key.code.isupper ()) {
                // the first letter in this state is uppercase
                if (!state.rom_kana_converter.is_active ())
                    state.rom_kana_converter.append ((char)key.code.tolower ());
                else {
                    state.okuri_rom_kana_converter.append ((char)key.code.tolower ());
                    if (state.okuri_rom_kana_converter.preedit.length == 0) {
                        state.handler_type = typeof (SelectStateHandler);
                        return false;
                    }
                }
                return true;
            } else {
                state.rom_kana_converter.append ((char)key.code.tolower ());
                return true;
            }
        }

        internal override string get_preedit (State state) {
            StringBuilder builder = new StringBuilder ("▽");
            if (state.okuri_rom_kana_converter.is_active ()) {
                builder.append (state.rom_kana_converter.output);
                builder.append ("*");
                builder.append (state.okuri_rom_kana_converter.output);
                builder.append (state.okuri_rom_kana_converter.preedit);
            } else {
                builder.append (state.rom_kana_converter.output);
                builder.append (state.rom_kana_converter.preedit);
            }
            return builder.str;
        }
    }

    class SelectStateHandler : StateHandler {
        internal override bool process_key_event (State state, KeyEvent key) {
            if (key.code == 'x') {
                state.candidate_index--;
                if (state.candidate_index >= 0) {
                    // state.preedit_updated ();
                    return true;
                } else {
                    state.handler_type = typeof (StartStateHandler);
                    return true;
                }
            } else if (key.code == '\n') {
                var c = state.candidates.get (state.candidate_index);
                state.output.append (c.text);
                state.reset ();
                return true;
            } else {
                if (state.candidate_index < 0) {
                    StringBuilder builder = new StringBuilder (state.rom_kana_converter.output);
                    bool okuri = false;
                    if (state.okuri_rom_kana_converter.is_active ()) {
                        builder.append_unichar (state.okuri_rom_kana_converter.input[0]);
                        okuri = true;
                    }
                    // FIXME check okuri-kana
                    state.lookup (builder.str, okuri);
                }

                if (state.candidate_index < state.candidates.size - 1) {
                    state.candidate_index++;
                    // state.preedit_updated ();
                    return true;
                } else {
                    // state.candidates_end ();
                    return true;
                }
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
