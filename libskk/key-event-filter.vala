/*
 * Copyright (C) 2011-2017 Daiki Ueno <ueno@gnu.org>
 * Copyright (C) 2011-2017 Red Hat, Inc.
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
         * @param key a key event
         */
        public signal void forwarded (KeyEvent key);

        /**
         * Reset the filter.
         */
        public virtual void reset () {
        }
    }

    /**
     * Simple implementation of a key event filter.
     *
     * This class is rarely used in programs but specified as "filter"
     * property in rule metadata.
     *
     * @see Rule
     */
    class SimpleKeyEventFilter : KeyEventFilter {
        /**
         * {@inheritDoc}
         */
        public override KeyEvent? filter_key_event (KeyEvent key) {
            // ignore key release event
            if ((key.modifiers & ModifierType.RELEASE_MASK) != 0)
                return null;
            // clear shift mask
            key.modifiers &= ~ModifierType.SHIFT_MASK;
            return key;
        }
    }
}