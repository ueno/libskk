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
    enum ConvState {
        NONE,
        START,
        SELECT
    }

    enum InputMode {
        HIRAGANA = KanaMode.HIRAGANA,
        KATAKANA = KanaMode.KATAKANA,
        HANKAKU_KATAKANA = KanaMode.HANKAKU_KATAKANA,
        LATIN,
        WIDE_LATIN,
        DEFAULT = HIRAGANA
    }

    class State : Object {
        internal ConvState conv_state;
        internal InputMode input_mode;

        internal ArrayList<Candidate> candidates = new ArrayList<Candidate> ();
        internal int candidate_index;

        internal RomKanaConverter rom_kana_converter;
        internal RomKanaConverter okuri_rom_kana_converter;

        internal StringBuilder preedit = new StringBuilder ();
        internal StringBuilder output = new StringBuilder ();

        internal State () {
            reset ();
        }

        internal void reset () {
            conv_state = ConvState.NONE;
            input_mode = InputMode.DEFAULT;

            rom_kana_converter = new RomKanaConverter ();
            okuri_rom_kana_converter = new RomKanaConverter ();
        }

        internal bool delete () {
            if (okuri_rom_kana_converter.is_active ()) {
                return okuri_rom_kana_converter.delete ();
            }
            if (rom_kana_converter.is_active ()) {
                return rom_kana_converter.delete ();
            }
            return false;
        }

        internal string to_string () {
            StringBuilder builder = new StringBuilder ();
            switch (conv_state) {
            case ConvState.NONE:
                break;
            case ConvState.START:
                builder.append ("▽");
                if (okuri_rom_kana_converter.is_active ()) {
                    builder.append (rom_kana_converter.output);
                    builder.append ("*");
                    builder.append (okuri_rom_kana_converter.output);
                    builder.append (okuri_rom_kana_converter.preedit);
                } else {
                    builder.append (rom_kana_converter.output);
                    builder.append (rom_kana_converter.preedit);
                }
                break;
            case ConvState.SELECT:
                builder.append ("▼");
                if (candidate_index >= 0) {
                    builder.append (candidates.get (candidate_index).text);
                } else {
                    builder.append (rom_kana_converter.output);
                }
                if (okuri_rom_kana_converter.is_active ()) {
                    builder.append (okuri_rom_kana_converter.output);
                }
                break;
            }
            return builder.str;
        }

        internal bool append_c (unichar c) {
            // FIXME not implemented
            return false;
        }
    }
}
