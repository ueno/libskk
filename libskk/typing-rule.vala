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
    class KeymapRule : Rule {
        internal Keymap keymap;

        internal KeymapRule (string name, string mode) throws RuleParseError {
            base (name, @"keymap/$mode");
            if (has_map ("keymap")) {
                var map = get ("keymap");
                keymap = new Keymap ();
                foreach (var key in map.keys) {
                    var value = map.get (key);
                    keymap.set (key, value.get_string ());
                }
            } else {
                throw new RuleParseError.FAILED ("no keymap entry");
            }
        }
    }

    class RomKanaRule : Rule {
        internal RomKanaNode root_node;

        RomKanaNode parse_rule (Map<string,Json.Node> map) throws RuleParseError
        {
            var node = new RomKanaNode (null);
            foreach (var key in map.keys) {
                var value = map.get (key);
                if (value.get_node_type () == Json.NodeType.ARRAY) {
                    var components = value.get_array ();
                    var length = components.get_length ();
                    if (2 <= length && length <= 4) {
                        var carryover = components.get_string_element (0);
                        var hiragana = components.get_string_element (1);
                        var katakana = length >= 3 ?
                            components.get_string_element (2) :
                            Util.get_katakana (hiragana);
                        var hankaku_katakana = length == 4 ?
                            components.get_string_element (3) :
                            Util.get_hankaku_katakana (katakana);

                        RomKanaEntry entry = {
                            key,
                            carryover,
                            hiragana,
                            katakana,
                            hankaku_katakana
                        };
                        node.insert (key, entry);
                    }
                    else {
                        throw new RuleParseError.FAILED (
                            "\"rom-kana\" must have two to four elements");
                    }
                } else {
                    throw new RuleParseError.FAILED (
                        "\"rom-kana\" member must be either an array or null");
                }
            }
            return node;
        }

        public RomKanaRule (string name) throws RuleParseError {
            base (name, "rom-kana/default");
            if (has_map ("rom-kana")) {
                root_node = parse_rule (get ("rom-kana"));
            } else {
                throw new RuleParseError.FAILED ("no rom-kana entry");
            }
        }
    }

    class TypingRule : Object {
        internal string name;

        internal KeymapRule[] keymap_rules = new KeymapRule[InputMode.LAST];
        internal RomKanaRule rom_kana_rule;

        internal TypingRule (string name) throws RuleParseError {
            keymap_rules[InputMode.HIRAGANA] =
                new KeymapRule (name, "hiragana");
            keymap_rules[InputMode.KATAKANA] =
                new KeymapRule (name, "katakana");
            keymap_rules[InputMode.HANKAKU_KATAKANA] =
                new KeymapRule (name, "hankaku-katakana");
            keymap_rules[InputMode.LATIN] =
                new KeymapRule (name, "latin");
            keymap_rules[InputMode.WIDE_LATIN] =
                new KeymapRule (name, "wide-latin");
            rom_kana_rule = new RomKanaRule (name);
        }
    }
}
