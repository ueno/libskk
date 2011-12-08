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
namespace Skk {
    static const KeymapEntry[] KEYMAP = {
        { null, 'g', ModifierType.CONTROL_MASK, "abort" },
        { null, '\n', ModifierType.NONE, "enter" },
        { null, 'm', ModifierType.CONTROL_MASK, "enter" },
        { null, 'Q', ModifierType.NONE, "start-preedit" },
        { null, '\x7f', ModifierType.NONE, "delete" },
        { null, 'h', ModifierType.CONTROL_MASK, "delete" },
        // { null, 'A', ModifierType.NONE, "start-and-insert-preedit" },
        { null, '/', ModifierType.NONE, "abbrev" },
        { null, '\\', ModifierType.NONE, "kuten" },
        { null, ' ', ModifierType.NONE, "next-candidate" },
        { null, '\t', ModifierType.NONE, "complete" },
        { null, 'i', ModifierType.CONTROL_MASK, "complete" },
        { null, '>', ModifierType.NONE, "special-midasi" },
        { null, 'x', ModifierType.NONE, "previous-candidate" },
        { null, 'X', ModifierType.NONE, "purge-candidate" }
    };

    static const KeymapEntry[] HIRAGANA_KEYMAP = {
        { null, 'q', ModifierType.NONE, "set-input-mode-katakana" },
        { null, 'L', ModifierType.NONE, "set-input-mode-wide-latin" },
        { null, 'l', ModifierType.NONE, "set-input-mode-latin" },
        { null, 'q', ModifierType.CONTROL_MASK,
          "set-input-mode-hankaku-katakana" }
    };

    static const KeymapEntry[] KATAKANA_KEYMAP = {
        { null, 'q', ModifierType.NONE, "set-input-mode-hiragana" },
        { null, 'L', ModifierType.NONE, "set-input-mode-wide-latin" },
        { null, 'l', ModifierType.NONE, "set-input-mode-latin" },
        { null, 'q', ModifierType.CONTROL_MASK,
          "set-input-mode-hankaku-katakana" }
    };

    static const KeymapEntry[] HANKAKU_KATAKANA_KEYMAP = {
        { null, 'q', ModifierType.NONE, "set-input-mode-hiragana" },
        { null, 'L', ModifierType.NONE, "set-input-mode-wide-latin" },
        { null, 'l', ModifierType.NONE, "set-input-mode-latin" },
        { null, 'q', ModifierType.CONTROL_MASK, "set-input-mode-hiragana" }
    };

    static const KeymapEntry[] WIDE_LATIN_KEYMAP = {
        { null, 'j', ModifierType.CONTROL_MASK, "set-input-mode-hiragana" }
    };

    static const KeymapEntry[] LATIN_KEYMAP = {
        { null, 'j', ModifierType.CONTROL_MASK, "set-input-mode-hiragana" }
    };

    struct KeymapEntry {
        string name;
        unichar code;
        ModifierType modifiers;

        string command;

        public KeyEvent to_key_event () {
            return new KeyEvent (name, code, modifiers);
        }
    }

    class Keymap : Object {
        KeymapEntry[] entries;

        public Keymap (KeymapEntry[] entries) {
            this.entries = entries;
        }

        public string? lookup_key (KeyEvent key) {
            foreach (var entry in entries) {
                if ((entry.name == null || entry.name == key.name) &&
                    (entry.code == '\0' || entry.code == key.code) &&
                    entry.modifiers == key.modifiers) {
                    return entry.command;
                }
            }
            return null;
        }

        public KeyEvent? where_is (string command) {
            foreach (var entry in entries) {
                if (entry.command == command) {
                    return entry.to_key_event ();
                }
            }
            return null;
        }
    }
}
