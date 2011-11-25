// -*- coding: utf-8 -*-
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
namespace Skk {
    errordomain RomKanaRuleParseError {
        FAILED
    }

    struct RomKanaEntry {
        string rom;
        string carryover;

        // we can't simply use string kana[3] here because array
        // initializer in Vala does not support it
        string hiragana;
        string katakana;
        string hankaku_katakana;

        internal string get_kana (KanaMode kana_mode) {
            if (kana_mode == KanaMode.HIRAGANA)
                return hiragana;
            else if (kana_mode == KanaMode.KATAKANA)
                return katakana;
            else if (kana_mode == KanaMode.HANKAKU_KATAKANA)
                return hankaku_katakana;
            return "";
        }
    }

    static const string[] PERIOD_RULE = {"。、", "．，", "。，", "．、"};

    class RomKanaNode {
        internal RomKanaEntry? entry;
        internal RomKanaNode parent;
        internal RomKanaNode children[128];

        internal RomKanaNode (RomKanaEntry? entry) {
            this.entry = entry;
            for (int i = 0; i < children.length; i++) {
                children[i] = null;
            }
        }

        internal void insert (string key, RomKanaEntry entry) {
            var node = this;
            for (var i = 0; i < key.length; i++) {
                if (node.children[key[i]] == null) {
                    var child = node.children[key[i]] = new RomKanaNode (null);
                    child.parent = node;
                }
                node = node.children[key[i]];
            }
            node.entry = entry;
        }

        internal RomKanaEntry? lookup (string key) {
            var node = this;
            for (var i = 0; i < key.length; i++) {
                node = node.children[key[i]];
                if (node == null)
                    return null;
            }
            return node.entry;
        }
    }

    /**
     * Type representing kana scripts.
     */
    public enum KanaMode {
        /**
         * Hiragana like "あいう...".
         */
        HIRAGANA,

        /**
         * Katakana like "アイウ...".
         */
        KATAKANA,

        /**
         * Half-width katakana like "ｱｲｳ...".
         */
        HANKAKU_KATAKANA
    }

    /**
     * Type to specify how "." and "," are converted.
     */
    public enum PeriodStyle {
        /**
         * Use "。" and "、" for "." and ",".
         */
        JA_JA,

        /**
         * Use "．" and "，" for "." and ",".
         */
        EN_EN,

        /**
         * Use "。" and "，" for "." and ",".
         */
        JA_EN,

        /**
         * Use "．" and "、" for "." and ",".
         */
        EN_JA
    }

    public class RomKanaConverter : Object {
        RomKanaNode root_node;
        RomKanaNode current_node;

        public KanaMode kana_mode { get; set; default = KanaMode.HIRAGANA; }
        public PeriodStyle period_style { get; set; default = PeriodStyle.JA_JA; }

        StringBuilder _input = new StringBuilder ();
        StringBuilder _output = new StringBuilder ();
        StringBuilder _preedit = new StringBuilder ();

        public string input {
            get {
                return _input.str;
            }
        }
        public string output {
            get {
                return _output.str;
            }
            internal set {
                _output.assign (value);
            }
        }
        public string preedit {
            get {
                return _preedit.str;
            }
        }

        Json.Parser parser;

        void load_rule (string name) throws RomKanaRuleParseError {
            var path = Path.build_filename (Config.ROMKANADIR, name + ".json");
            try {
                if (!parser.load_from_file (path))
                    throw new RomKanaRuleParseError.FAILED ("");
            } catch (GLib.Error e) {
                throw new RomKanaRuleParseError.FAILED (
                    "%s".printf (e.message));
            }
            var root = parser.get_root ();
            var elements = root.get_array ().get_elements ();
            root_node = new RomKanaNode (null);
            foreach (var element in elements) {
                var components = element.get_array ();
                RomKanaEntry entry = {
                    components.get_string_element (0),
                    components.get_string_element (1),
                    components.get_string_element (2),
                    components.get_string_element (3),
                    components.get_string_element (4)
                };
                root_node.insert (entry.rom, entry);
            }
        }

        string _rule = "standard";
        public string rule {
            get {
                return _rule;
            }
            set {
                if (_rule != value) {
                    load_rule (value);
                    _rule = value;
                }
            }
        }

        public RomKanaConverter () {
            parser = new Json.Parser ();
            load_rule (_rule);
            current_node = root_node;
        }

        static const string[] NN = { "ん", "ン", "ﾝ" };

        /**
         * Output "nn" if preedit ends with "n".
         */
        public void output_nn_if_any () {
            if (_preedit.str.has_suffix ("n")) {
                //_input.append ("n");
                _output.append (NN[kana_mode]);
                _preedit.truncate (_preedit.len - 1);
            }
        }

        /**
         * Append text to the internal buffer.
         *
         * @param text a string
         */
        public void append_text (string text) {
            int index = 0;
            unichar c;
            while (text.get_next_char (ref index, out c)) {
                append (c);
            }
        }

        /**
         * Append a character to the internal buffer.
         *
         * @param uc an ASCII character
         *
         * @return `true` if the character is handled, `false` otherwise
         */
        public bool append (unichar uc) {
            var child_node = current_node.children[uc];
            if (child_node == null) {
                // no such transition path in trie
                output_nn_if_any ();
                var index = ".,".index_of_char ((char)uc);
                if (index >= 0) {
                    index = PERIOD_RULE[period_style].index_of_nth_char (index);
                    unichar period = PERIOD_RULE[period_style].get_char (index);
                    _input.append_unichar (uc);
                    _output.append_unichar (period);
                    _preedit.erase ();
                    current_node = root_node;
                    return true;
                } else if (root_node.children[uc] == null) {
                    _input.append_unichar (uc);
                    _output.append_unichar (uc);
                    _preedit.erase ();
                    current_node = root_node;
                    return false;
                } else {
                    // abondon current preedit and restart lookup from
                    // the root with uc
                    _preedit.erase ();
                    current_node = root_node;
                    return append (uc);
                }
            } else if (child_node.entry == null) {
                // node is not a terminal
                _preedit.append_unichar (uc);
                _input.append_unichar (uc);
                current_node = child_node;
                return true;
            } else {
                _input.append_unichar (uc);
                _output.append (child_node.entry.get_kana (kana_mode));
                _preedit.erase ();
                current_node = root_node;
                for (int i = 0; i < child_node.entry.carryover.length; i++) {
                    append (child_node.entry.carryover[i]);
                }
                return true;
            }
        }

        /**
         * Check if a character will be consumed by the current conversion.
         *
         * @param uc an ASCII character
         * @param preedit_only only checks if preedit is active
         * @return `true` if the character can be consumed
         */
        public bool can_consume (unichar uc, bool preedit_only = false) {
            if (preedit_only && _preedit.len == 0)
                return false;
            var child_node = current_node.children[uc];
            if (child_node == null)
                return false;
            if (child_node.entry == null)
                return false;
            if (child_node.entry.carryover != "")
                return false;
            return true;
        }

        /**
         * Reset the internal state of the converter.
         */
        public void reset () {
            _input.erase ();
            _output.erase ();
            _preedit.erase ();
            current_node = root_node;
        }

        /**
         * Delete the trailing character from the internal buffer.
         *
         * @return `true` if any character is removed, `false` otherwise
         */
        public bool delete () {
            if (_preedit.len > 0) {
                current_node = current_node.parent;
                if (current_node == null)
                    current_node = root_node;
                _preedit.truncate (
                    _preedit.str.index_of_nth_char (
                        _preedit.str.char_count () - 1));
                return true;
            }
            if (_output.len > 0) {
                _output.truncate (
                    _output.str.index_of_nth_char (
                        _output.str.char_count () - 1));
                return true;
            }
            if (_input.len > 0) {
                // _input contains only ASCII characters so no need to
                // count characters
                _input.truncate (_input.len - 1);
            }
            return false;
        }

        /**
         * Check if the converter is active
         *
         * @return `true` if the converter is active, `false` otherwise
         */
        public bool is_active () {
            return _output.len > 0 || _preedit.len > 0;
        }
    }
}
