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
    enum InputMode {
        HIRAGANA = KanaMode.HIRAGANA,
        KATAKANA = KanaMode.KATAKANA,
        HANKAKU_KATAKANA = KanaMode.HANKAKU_KATAKANA,
        LATIN,
        WIDE_LATIN,
        DEFAULT = HIRAGANA
    }

    class State : Object {
        internal Type handler_type;
        internal InputMode input_mode;

        internal ArrayList<Candidate> candidates = new ArrayList<Candidate> ();
        internal int candidate_index;

        internal RomKanaConverter rom_kana_converter;
        internal RomKanaConverter okuri_rom_kana_converter;

        internal StringBuilder output = new StringBuilder ();

        internal State () {
            reset ();
        }

        internal void reset () {
            handler_type = typeof (NoneStateHandler);
            input_mode = InputMode.DEFAULT;
            rom_kana_converter = new RomKanaConverter ();
            okuri_rom_kana_converter = new RomKanaConverter ();
            candidates.clear ();
            candidate_index = -1;
            output.erase ();
        }
    }
    
    abstract class StateHandler : Object {
        internal abstract bool append (State state, unichar c);
        internal abstract bool delete (State state);
        internal abstract bool cancel (State state);
        internal abstract bool commit (State state);
        internal abstract string get_preedit (State state);
        internal virtual string get_output (State state) {
            return state.output.str;
        }
    }

    class NoneStateHandler : StateHandler {
        internal override bool append (State state, unichar c) {
            state.rom_kana_converter.append ((char)c);
            state.output.append (state.rom_kana_converter.output);
            state.rom_kana_converter.output = "";
            return true;
        }

        internal override bool delete (State state) {
            if (state.rom_kana_converter.is_active ()) {
                return state.rom_kana_converter.delete ();
            }
            return false;
        }

        internal override bool cancel (State state) {
            return false;
        }

        internal override bool commit (State state) {
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

    class StartStateHandler : StateHandler {
        internal override bool append (State state, unichar c) {
            if (state.okuri_rom_kana_converter.is_active () ||
                (state.rom_kana_converter.is_active () &&
                 c.isalpha () && c.isupper ()))
                state.okuri_rom_kana_converter.append ((char)c.tolower ());
            else
                state.rom_kana_converter.append ((char)c.tolower ());
            return true;
        }

        internal override bool delete (State state) {
            if (state.okuri_rom_kana_converter.is_active ())
                return state.okuri_rom_kana_converter.delete ();
            else
                return state.rom_kana_converter.delete ();
        }

        internal override bool cancel (State state) {
            return false;
        }

        internal override bool commit (State state) {
            return false;
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
        internal override bool append (State state, unichar c) {
            return false;
        }

        internal override bool delete (State state) {
            return false;
        }

        internal override bool cancel (State state) {
            return false;
        }

        internal override bool commit (State state) {
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
