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
    /**
     * A set of bit-flags to indicate the state of modifier keys.
     */
    public enum ModifierType {
        NONE = 0,
        SHIFT_MASK = 1 << 0,
        LOCK_MASK = 1 << 1,
        CONTROL_MASK = 1 << 2,
        MOD1_MASK = 1 << 3,
        MOD2_MASK = 1 << 4,
        MOD3_MASK = 1 << 5,
        MOD4_MASK = 1 << 6,
        MOD5_MASK = 1 << 7,
        SUPER_MASK = 1 << 26,
        HYPER_MASK = 1 << 27,
        META_MASK = 1 << 28,
        RELEASE_MASK = 1 << 30
    }

    /**
     * Object representing a key event.
     */
    public class KeyEvent {
        public uint keyval;
        public uint keycode;
        public ModifierType modifiers;

        public unichar code;

        /**
         * Create a key event.
         *
         * @param keyval a keysym value
         * @param keycode a key code value
         * @param modifiers state of modifier keys
         *
         * @return a new KeyEvent
         */
        public KeyEvent (uint keyval, uint keycode, ModifierType modifiers) {
            this.keyval = keyval;
            this.keycode = keycode;
            this.modifiers = modifiers;

            // FIXME: should add more precise mapping functions
            // between keyval and code
            if (0x20 <= keyval && keyval < 0x7F) {
                code = (unichar) keyval;
            }
        }

        /**
         * Create a key event from string.
         *
         * @param key a string representation of a key event
         *
         * @return a new KeyEvent
         */
        public KeyEvent.from_string (string key) {
            int index = key.last_index_of ("-");
            if (index > 0) {
                string[] modifiers = key.substring (0, index).split ("-");
                foreach (var mod in modifiers) {
                    if (mod == "C") {
                        this.modifiers |= ModifierType.CONTROL_MASK;
                    } else if (mod == "A") {
                        this.modifiers |= ModifierType.MOD1_MASK;
                    } else if (mod == "M") {
                        this.modifiers |= ModifierType.META_MASK;
                    } else if (mod == "G") {
                        this.modifiers |= ModifierType.MOD5_MASK;
                    } else if (mod == "S") {
                        this.modifiers |= ModifierType.SUPER_MASK;
                    } else if (mod == "H") {
                        this.modifiers |= ModifierType.HYPER_MASK;
                    } else if (mod == "R") {
                        this.modifiers |= ModifierType.RELEASE_MASK;
                    }
                }
                this.code = key.substring (index + 1).get_char ();
            } else {
                this.modifiers = ModifierType.NONE;
                this.code = key.get_char ();
            }
        }
    }

    /**
     * Base class of a key event filter.
     */
    public abstract class KeyEventFilter : Object {
        /**
         * Convert a key event to another.
         *
         * @param key a key event
         *
         * @return a KeyEvent or `null` if the result cannot be
         * fetched immediately
         */
        public abstract KeyEvent? filter_key_event (KeyEvent key);

        /**
         * Signal emitted when a new key event is generated in the filter.
         *
         * @param a key event
         */
        public signal void forwarded (KeyEvent key);
    }

    /**
     * Simple implementation of a key event filter.
     */
    public class SimpleKeyEventFilter : KeyEventFilter {
        /**
         * {@inheritDoc}
         */
        public override KeyEvent? filter_key_event (KeyEvent key) {
            // ignore key release event
            if ((key.modifiers & ModifierType.RELEASE_MASK) != 0)
                return null;
            return key;
        }
    }
}
