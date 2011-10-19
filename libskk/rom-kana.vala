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
    struct RomKanaEntry {
        string rom;
        string carryover;

        // we can't simply use string kana[3] here because initializer
        // does not support it
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

    // FIXME: define hankaku_katakana
    static const RomKanaEntry[] ROM_KANA_RULE = {
        { "a", "", "あ", "ア", "" },
        { "bb", "b", "っ", "ッ", "" },
        { "ba", "", "ば", "バ", "" },
        { "be", "", "べ", "ベ", "" },
        { "bi", "", "び", "ビ", "" },
        { "bo", "", "ぼ", "ボ", "" },
        { "bu", "", "ぶ", "ブ", "" },
        { "bya", "", "びゃ", "ビャ", "" },
        { "bye", "", "びぇ", "ビェ", "" },
        { "byi", "", "びぃ", "ビィ", "" },
        { "byo", "", "びょ", "ビョ", "" },
        { "byu", "", "びゅ", "ビュ", "" },
        { "cc", "c", "っ", "ッ", "" },
        { "cha", "", "ちゃ", "チャ", "" },
        { "che", "", "ちぇ", "チェ", "" },
        { "chi", "", "ち", "チ", "" },
        { "cho", "", "ちょ", "チョ", "" },
        { "chu", "", "ちゅ", "チュ", "" },
        { "cya", "", "ちゃ", "チャ", "" },
        { "cye", "", "ちぇ", "チェ", "" },
        { "cyi", "", "ちぃ", "チィ", "" },
        { "cyo", "", "ちょ", "チョ", "" },
        { "cyu", "", "ちゅ", "チュ", "" },
        { "dd", "d", "っ", "ッ", "" },
        { "da", "", "だ", "ダ", "" },
        { "de", "", "で", "デ", "" },
        { "dha", "", "でゃ", "デャ", "" },
        { "dhe", "", "でぇ", "デェ", "" },
        { "dhi", "", "でぃ", "ディ", "" },
        { "dho", "", "でょ", "デョ", "" },
        { "dhu", "", "でゅ", "デュ", "" },
        { "di", "", "ぢ", "ヂ", "" },
        { "do", "", "ど", "ド", "" },
        { "du", "", "づ", "ヅ", "" },
        { "dya", "", "ぢゃ", "ヂャ", "" },
        { "dye", "", "ぢぇ", "ヂェ", "" },
        { "dyi", "", "ぢぃ", "ヂィ", "" },
        { "dyo", "", "ぢょ", "ヂョ", "" },
        { "dyu", "", "ぢゅ", "ヂュ", "" },
        { "e", "", "え", "エ", "" },
        { "ff", "f", "っ", "ッ", "" },
        { "fa", "", "ふぁ", "ファ", "" },
        { "fe", "", "ふぇ", "フェ", "" },
        { "fi", "", "ふぃ", "フィ", "" },
        { "fo", "", "ふぉ", "フォ", "" },
        { "fu", "", "ふ", "フ", "" },
        { "fya", "", "ふゃ", "フャ", "" },
        { "fye", "", "ふぇ", "フェ", "" },
        { "fyi", "", "ふぃ", "フィ", "" },
        { "fyo", "", "ふょ", "フョ", "" },
        { "fyu", "", "ふゅ", "フュ", "" },
        { "gg", "g", "っ", "ッ", "" },
        { "ga", "", "が", "ガ", "" },
        { "ge", "", "げ", "ゲ", "" },
        { "gi", "", "ぎ", "ギ", "" },
        { "go", "", "ご", "ゴ", "" },
        { "gu", "", "ぐ", "グ", "" },
        { "gya", "", "ぎゃ", "ギャ", "" },
        { "gye", "", "ぎぇ", "ギェ", "" },
        { "gyi", "", "ぎぃ", "ギィ", "" },
        { "gyo", "", "ぎょ", "ギョ", "" },
        { "gyu", "", "ぎゅ", "ギュ", "" },
        // { "h", "", "お", "オ", "" },
        { "ha", "", "は", "ハ", "" },
        { "he", "", "へ", "ヘ", "" },
        { "hh", "h", "っ", "ッ", "" }, // skk-rom-kana-list
        { "hi", "", "ひ", "ヒ", "" },
        { "ho", "", "ほ", "ホ", "" },
        { "hu", "", "ふ", "フ", "" },
        { "hya", "", "ひゃ", "ヒャ", "" },
        { "hye", "", "ひぇ", "ヒェ", "" },
        { "hyi", "", "ひぃ", "ヒィ", "" },
        { "hyo", "", "ひょ", "ヒョ", "" },
        { "hyu", "", "ひゅ", "ヒュ", "" },
        { "i", "", "い", "イ", "" },
        { "jj", "j", "っ", "ッ", "" },
        { "ja", "", "じゃ", "ジャ", "" },
        { "je", "", "じぇ", "ジェ", "" },
        { "ji", "", "じ", "ジ", "" },
        { "jo", "", "じょ", "ジョ", "" },
        { "ju", "", "じゅ", "ジュ", "" },
        { "jya", "", "じゃ", "ジャ", "" },
        { "jye", "", "じぇ", "ジェ", "" },
        { "jyi", "", "じぃ", "ジィ", "" },
        { "jyo", "", "じょ", "ジョ", "" },
        { "jyu", "", "じゅ", "ジュ", "" },
        { "kk", "k", "っ", "ッ", "" },
        { "ka", "", "か", "カ", "" },
        { "ke", "", "け", "ケ", "" },
        { "ki", "", "き", "キ", "" },
        { "ko", "", "こ", "コ", "" },
        { "ku", "", "く", "ク", "" },
        { "kya", "", "きゃ", "キャ", "" },
        { "kye", "", "きぇ", "キェ", "" },
        { "kyi", "", "きぃ", "キィ", "" },
        { "kyo", "", "きょ", "キョ", "" },
        { "kyu", "", "きゅ", "キュ", "" },
        { "ma", "", "ま", "マ", "" },
        { "me", "", "め", "メ", "" },
        { "mi", "", "み", "ミ", "" },
        { "mm", "m", "っ", "ッ", "" }, // skk-rom-kana-list
        { "mo", "", "も", "モ", "" },
        { "mu", "", "む", "ム", "" },
        { "mya", "", "みゃ", "ミャ", "" },
        { "mye", "", "みぇ", "ミェ", "" },
        { "myi", "", "みぃ", "ミィ", "" },
        { "myo", "", "みょ", "ミョ", "" },
        { "myu", "", "みゅ", "ミュ", "" },
        // { "n", "", "ん", "ン", "" },
        { "n\'", "", "ん", "ン", "" },
        { "na", "", "な", "ナ", "" },
        { "ne", "", "ね", "ネ", "" },
        { "ni", "", "に", "ニ", "" },
        { "nn", "", "ん", "ン", "" },
        { "no", "", "の", "ノ", "" },
        { "nu", "", "ぬ", "ヌ", "" },
        { "nya", "", "にゃ", "ニャ", "" },
        { "nye", "", "にぇ", "ニェ", "" },
        { "nyi", "", "にぃ", "ニィ", "" },
        { "nyo", "", "にょ", "ニョ", "" },
        { "nyu", "", "にゅ", "ニュ", "" },
        { "o", "", "お", "オ", "" },
        { "pp", "p", "っ", "ッ", "" },
        { "pa", "", "ぱ", "パ", "" },
        { "pe", "", "ぺ", "ペ", "" },
        { "pi", "", "ぴ", "ピ", "" },
        { "po", "", "ぽ", "ポ", "" },
        { "pu", "", "ぷ", "プ", "" },
        { "pya", "", "ぴゃ", "ピャ", "" },
        { "pye", "", "ぴぇ", "ピェ", "" },
        { "pyi", "", "ぴぃ", "ピィ", "" },
        { "pyo", "", "ぴょ", "ピョ", "" },
        { "pyu", "", "ぴゅ", "ピュ", "" },
        { "rr", "r", "っ", "ッ", "" },
        { "ra", "", "ら", "ラ", "" },
        { "re", "", "れ", "レ", "" },
        { "ri", "", "り", "リ", "" },
        { "ro", "", "ろ", "ロ", "" },
        { "ru", "", "る", "ル", "" },
        { "rya", "", "りゃ", "リャ", "" },
        { "rye", "", "りぇ", "リェ", "" },
        { "ryi", "", "りぃ", "リィ", "" },
        { "ryo", "", "りょ", "リョ", "" },
        { "ryu", "", "りゅ", "リュ", "" },
        { "ss", "s", "っ", "ッ", "" },
        { "sa", "", "さ", "サ", "" },
        { "se", "", "せ", "セ", "" },
        { "sha", "", "しゃ", "シャ", "" },
        { "she", "", "しぇ", "シェ", "" },
        { "shi", "", "し", "シ", "" },
        { "sho", "", "しょ", "ショ", "" },
        { "shu", "", "しゅ", "シュ", "" },
        { "si", "", "し", "シ", "" },
        { "so", "", "そ", "ソ", "" },
        { "su", "", "す", "ス", "" },
        { "sya", "", "しゃ", "シャ", "" },
        { "sye", "", "しぇ", "シェ", "" },
        { "syi", "", "しぃ", "シィ", "" },
        { "syo", "", "しょ", "ショ", "" },
        { "syu", "", "しゅ", "シュ", "" },
        { "tt", "t", "っ", "ッ", "" },
        { "ta", "", "た", "タ", "" },
        { "te", "", "て", "テ", "" },
        { "tha", "", "てぁ", "テァ", "" },
        { "the", "", "てぇ", "テェ", "" },
        { "thi", "", "てぃ", "ティ", "" },
        { "tho", "", "てょ", "テョ", "" },
        { "thu", "", "てゅ", "テュ", "" },
        { "ti", "", "ち", "チ", "" },
        { "to", "", "と", "ト", "" },
        { "tsu", "", "つ", "ツ", "" },
        { "tu", "", "つ", "ツ", "" },
        { "tya", "", "ちゃ", "チャ", "" },
        { "tye", "", "ちぇ", "チェ", "" },
        { "tyi", "", "ちぃ", "チィ", "" },
        { "tyo", "", "ちょ", "チョ", "" },
        { "tyu", "", "ちゅ", "チュ", "" },
        { "u", "", "う", "ウ", "" },
        { "vv", "v", "っ", "ッ", "" },
        { "va", "", "う゛ぁ", "ヴァ", "" },
        { "ve", "", "う゛ぇ", "ヴェ", "" },
        { "vi", "", "う゛ぃ", "ヴィ", "" },
        { "vo", "", "う゛ぉ", "ヴォ", "" },
        { "vu", "", "う゛", "ヴ", "" },
        { "ww", "w", "っ", "ッ", "" },
        { "wa", "", "わ", "ワ", "" },
        { "we", "", "うぇ", "ウェ", "" },
        { "wi", "", "うぃ", "ウィ", "" },
        { "wo", "", "を", "ヲ", "" },
        { "wu", "", "う", "ウ", "" },
        { "xx", "x", "っ", "ッ", "" },
        { "xa", "", "ぁ", "ァ", "" },
        { "xe", "", "ぇ", "ェ", "" },
        { "xi", "", "ぃ", "ィ", "" },
        { "xka", "", "か", "ヵ", "" },
        { "xke", "", "け", "ヶ", "" },
        { "xo", "", "ぉ", "ォ", "" },
        { "xtsu", "", "っ", "ッ", "" },
        { "xtu", "", "っ", "ッ", "" },
        { "xu", "", "ぅ", "ゥ", "" },
        { "xwa", "", "ゎ", "ヮ", "" },
        { "xwe", "", "ゑ", "ヱ", "" },
        { "xwi", "", "ゐ", "ヰ", "" },
        { "xya", "", "ゃ", "ャ", "" },
        { "xyo", "", "ょ", "ョ", "" },
        { "xyu", "", "ゅ", "ュ", "" },
        { "yy", "y", "っ", "ッ", "" },
        { "ya", "", "や", "ヤ", "" },
        { "ye", "", "いぇ", "イェ", "" },
        { "yo", "", "よ", "ヨ", "" },
        { "yu", "", "ゆ", "ユ", "" },
        { "zz", "z", "っ", "ッ", "" },
        { "z,", "", "‥", "‥", "" },
        { "z-", "", "〜", "〜", "" },
        { "z.", "", "…", "…", "" },
        { "z/", "", "・", "・", "" },
        { "z[", "", "『", "『", "" },
        { "z]", "", "』", "』", "" },
        { "za", "", "ざ", "ザ", "" },
        { "ze", "", "ぜ", "ゼ", "" },
        { "zh", "", "←", "←", "" },
        { "zi", "", "じ", "ジ", "" },
        { "zj", "", "↓", "↓", "" },
        { "zk", "", "↑", "↑", "" },
        { "zl", "", "→", "→", "" },
        { "zo", "", "ぞ", "ゾ", "" },
        { "zu", "", "ず", "ズ", "" },
        { "zya", "", "じゃ", "ジャ", "" },
        { "zye", "", "じぇ", "ジェ", "" },
        { "zyi", "", "じぃ", "ジィ", "" },
        { "zyo", "", "じょ", "ジョ", "" },
        { "zyu", "", "じゅ", "ジュ", "" },
        { "-", "", "ー", "ー", "" },
        { ":", "", "：", "：", "" },
        { ";", "", "；", "；", "" },
        { "?", "", "？", "？", "" },
        { "[", "", "「", "「", "" },
        { "]", "", "」", "」", "" }
    };

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

    public enum KanaMode {
        HIRAGANA,
        KATAKANA,
        HANKAKU_KATAKANA
    }

    public enum PeriodStyle {
        JA_JA,
        EN_EN,
        JA_EN,
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
            set {
                _input.assign (value);
            }
        }
        public string output {
            get {
                return _output.str;
            }
            set {
                _output.assign (value);
            }
        }
        public string preedit {
            get {
                return _preedit.str;
            }
        }

        public RomKanaConverter () {
            root_node = new RomKanaNode (null);
            foreach (var entry in ROM_KANA_RULE) {
                root_node.insert (entry.rom, entry);
            }
            current_node = root_node;
        }

        static const string[] NN = { "ん", "ン", "ﾝ" };

        /**
         * skk_rom_kana_converter_output_nn_if_any:
         * @self: an #SkkRomKanaConverter
         *
         * Process "nn" if preedit ends with "n".
         */
        public void output_nn_if_any () {
            if (_preedit.str.has_suffix ("n")) {
                _input.append ("n");
                _output.append (NN[kana_mode]);
                _preedit.truncate (_preedit.len - 1);
            }
        }

        /**
         * skk_rom_kana_converter_append_text:
         * @self: an #SkkRomKanaConverter
         * @text: a string
         *
         * Append @text to the internal buffer.
         */
        public void append_text (string text) {
            int index = 0;
            unichar c;
            while (text.get_next_char (ref index, out c)) {
                append (c);
            }
        }

        /**
         * skk_rom_kana_converter_append:
         * @self: an #SkkRomKanaConverter
         * @letter: an ASCII character
         *
         * Append @letter to the internal buffer.
         */
        public void append (unichar letter) {
            var child_node = current_node.children[letter];
            if (child_node == null) {
                output_nn_if_any ();
                // no such transition path in trie
                var index = ".,".index_of_char ((char)letter);
                if (index >= 0) {
                    index = PERIOD_RULE[period_style].index_of_nth_char (index);
                    unichar period = PERIOD_RULE[period_style].get_char (index);
                    _input.append_unichar (letter);
                    _output.append_unichar (period);
                    _preedit.erase ();
                    current_node = root_node;
                } else if (root_node.children[letter] == null) {
                    _input.append_unichar (letter);
                    _output.append_unichar (letter);
                    _preedit.erase ();
                    current_node = root_node;
                    return;
                } else {
                    // abondon current preedit and restart lookup from
                    // the root with letter
                    _input.erase ();
                    _preedit.erase ();
                    current_node = root_node;
                    append (letter);
                }
            } else if (child_node.entry == null) {
                // node is not a terminal
                _preedit.append_unichar (letter);
                _input.append_unichar (letter);
                current_node = child_node;
            } else {
                _input.append_unichar (letter);
                _output.append (child_node.entry.get_kana (kana_mode));
                _preedit.erase ();
                for (int i = 0; i < child_node.entry.carryover.length; i++) {
                    append (child_node.entry.carryover[i]);
                }
            }
        }

        /**
         * skk_rom_kana_converter_reset:
         * @self: an #SkkRomKanaConverter
         *
         * Reset the internal state of @self.
         */
        public void reset () {
            _input.erase ();
            _output.erase ();
            _preedit.erase ();
            current_node = root_node;
        }

        /**
         * skk_rom_kana_delete:
         * @self: an #SkkRomKanaConverter
         *
         * Delete the trailing character from the internal buffer.
         */
        public bool delete () {
            if (_preedit.len > 0) {
                current_node = current_node.parent;
                if (current_node == null)
                    current_node = root_node;
                _preedit.truncate (_preedit.len - 1);
                return true;
            }
            if (_output.len > 0) {
                _output.truncate (_output.len - 1);
                return true;
            }
            return false;
        }

        /**
         * skk_rom_kana_is_active:
         * @self: an #SkkRomKanaConverter
         *
         * Return %TRUE if @self is active, otherwise %FALSE.
         */
        public bool is_active () {
            return _output.len > 0 || _preedit.len > 0;
        }
    }
}
