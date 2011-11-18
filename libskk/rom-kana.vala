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

    // FIXME: define hankaku_katakana
    static const RomKanaEntry[] ROM_KANA_RULE = {
        { "a", "", "あ", "ア", "ｱ" },
        { "bb", "b", "っ", "ッ", "ｯ" },
        { "ba", "", "ば", "バ", "ﾊﾞ" },
        { "be", "", "べ", "ベ", "ﾍﾞ" },
        { "bi", "", "び", "ビ", "ﾋﾞ" },
        { "bo", "", "ぼ", "ボ", "ﾎﾞ" },
        { "bu", "", "ぶ", "ブ", "ﾌﾞ" },
        { "bya", "", "びゃ", "ビャ", "ﾋﾞｬ" },
        { "bye", "", "びぇ", "ビェ", "ﾋﾞｪ" },
        { "byi", "", "びぃ", "ビィ", "ﾋﾞｨ" },
        { "byo", "", "びょ", "ビョ", "ﾋﾞｮ" },
        { "byu", "", "びゅ", "ビュ", "ﾋﾞｭ" },
        { "cc", "c", "っ", "ッ", "ｯ" },
        { "cha", "", "ちゃ", "チャ", "ﾁｬ" },
        { "che", "", "ちぇ", "チェ", "ﾁｪ" },
        { "chi", "", "ち", "チ", "ﾁ" },
        { "cho", "", "ちょ", "チョ", "ﾁｮ" },
        { "chu", "", "ちゅ", "チュ", "ﾁｭ" },
        { "cya", "", "ちゃ", "チャ", "ﾁｬ" },
        { "cye", "", "ちぇ", "チェ", "ﾁｪ" },
        { "cyi", "", "ちぃ", "チィ", "ﾁｨ" },
        { "cyo", "", "ちょ", "チョ", "ﾁｮ" },
        { "cyu", "", "ちゅ", "チュ", "ﾁｭ" },
        { "dd", "d", "っ", "ッ", "ｯ" },
        { "da", "", "だ", "ダ", "ﾀﾞ" },
        { "de", "", "で", "デ", "ﾃﾞ" },
        { "dha", "", "でゃ", "デャ", "ﾃﾞｬ" },
        { "dhe", "", "でぇ", "デェ", "ﾃﾞｪ" },
        { "dhi", "", "でぃ", "ディ", "ﾃﾞｨ" },
        { "dho", "", "でょ", "デョ", "ﾃﾞｮ" },
        { "dhu", "", "でゅ", "デュ", "ﾃﾞｭ" },
        { "di", "", "ぢ", "ヂ", "ﾁﾞ" },
        { "do", "", "ど", "ド", "ﾄﾞ" },
        { "du", "", "づ", "ヅ", "ﾂﾞ" },
        { "dya", "", "ぢゃ", "ヂャ", "ﾁﾞｬ" },
        { "dye", "", "ぢぇ", "ヂェ", "ﾁﾞｪ" },
        { "dyi", "", "ぢぃ", "ヂィ", "ﾁﾞｨ" },
        { "dyo", "", "ぢょ", "ヂョ", "ﾁﾞｮ" },
        { "dyu", "", "ぢゅ", "ヂュ", "ﾁﾞｭ" },
        { "e", "", "え", "エ", "ｴ" },
        { "ff", "f", "っ", "ッ", "ｯ" },
        { "fa", "", "ふぁ", "ファ", "ﾌｧ" },
        { "fe", "", "ふぇ", "フェ", "ﾌｪ" },
        { "fi", "", "ふぃ", "フィ", "ﾌｨ" },
        { "fo", "", "ふぉ", "フォ", "ﾌｫ" },
        { "fu", "", "ふ", "フ", "ﾌ" },
        { "fya", "", "ふゃ", "フャ", "ﾌｬ" },
        { "fye", "", "ふぇ", "フェ", "ﾌｪ" },
        { "fyi", "", "ふぃ", "フィ", "ﾌｨ" },
        { "fyo", "", "ふょ", "フョ", "ﾌｮ" },
        { "fyu", "", "ふゅ", "フュ", "ﾌｭ" },
        { "gg", "g", "っ", "ッ", "ｯ" },
        { "ga", "", "が", "ガ", "ｶﾞ" },
        { "ge", "", "げ", "ゲ", "ｹﾞ" },
        { "gi", "", "ぎ", "ギ", "ｷﾞ" },
        { "go", "", "ご", "ゴ", "ｺﾞ" },
        { "gu", "", "ぐ", "グ", "ｸﾞ" },
        { "gya", "", "ぎゃ", "ギャ", "ｷﾞｬ" },
        { "gye", "", "ぎぇ", "ギェ", "ｷﾞｪ" },
        { "gyi", "", "ぎぃ", "ギィ", "ｷﾞｨ" },
        { "gyo", "", "ぎょ", "ギョ", "ｷﾞｮ" },
        { "gyu", "", "ぎゅ", "ギュ", "ｷﾞｭ" },
        // { "h", "", "お", "オ", "ｵ" },
        { "ha", "", "は", "ハ", "ﾊ" },
        { "he", "", "へ", "ヘ", "ﾍ" },
        { "hh", "h", "っ", "ッ", "ｯ" }, // skk-rom-kana-list
        { "hi", "", "ひ", "ヒ", "ﾋ" },
        { "ho", "", "ほ", "ホ", "ﾎ" },
        { "hu", "", "ふ", "フ", "ﾌ" },
        { "hya", "", "ひゃ", "ヒャ", "ﾋｬ" },
        { "hye", "", "ひぇ", "ヒェ", "ﾋｪ" },
        { "hyi", "", "ひぃ", "ヒィ", "ﾋｨ" },
        { "hyo", "", "ひょ", "ヒョ", "ﾋｮ" },
        { "hyu", "", "ひゅ", "ヒュ", "ﾋｭ" },
        { "i", "", "い", "イ", "ｲ" },
        { "jj", "j", "っ", "ッ", "ｯ" },
        { "ja", "", "じゃ", "ジャ", "ｼﾞｬ" },
        { "je", "", "じぇ", "ジェ", "ｼﾞｪ" },
        { "ji", "", "じ", "ジ", "ｼﾞ" },
        { "jo", "", "じょ", "ジョ", "ｼﾞｮ" },
        { "ju", "", "じゅ", "ジュ", "ｼﾞｭ" },
        { "jya", "", "じゃ", "ジャ", "ｼﾞｬ" },
        { "jye", "", "じぇ", "ジェ", "ｼﾞｪ" },
        { "jyi", "", "じぃ", "ジィ", "ｼﾞｨ" },
        { "jyo", "", "じょ", "ジョ", "ｼﾞｮ" },
        { "jyu", "", "じゅ", "ジュ", "ｼﾞｭ" },
        { "kk", "k", "っ", "ッ", "ｯ" },
        { "ka", "", "か", "カ", "ｶ" },
        { "ke", "", "け", "ケ", "ｹ" },
        { "ki", "", "き", "キ", "ｷ" },
        { "ko", "", "こ", "コ", "ｺ" },
        { "ku", "", "く", "ク", "ｸ" },
        { "kya", "", "きゃ", "キャ", "ｷｬ" },
        { "kye", "", "きぇ", "キェ", "ｷｪ" },
        { "kyi", "", "きぃ", "キィ", "ｷｨ" },
        { "kyo", "", "きょ", "キョ", "ｷｮ" },
        { "kyu", "", "きゅ", "キュ", "ｷｭ" },
        { "ma", "", "ま", "マ", "ﾏ" },
        { "me", "", "め", "メ", "ﾒ" },
        { "mi", "", "み", "ミ", "ﾐ" },
        { "mm", "m", "っ", "ッ", "ｯ" }, // skk-rom-kana-list
        { "mo", "", "も", "モ", "ﾓ" },
        { "mu", "", "む", "ム", "ﾑ" },
        { "mya", "", "みゃ", "ミャ", "ﾐｬ" },
        { "mye", "", "みぇ", "ミェ", "ﾐｪ" },
        { "myi", "", "みぃ", "ミィ", "ﾐｨ" },
        { "myo", "", "みょ", "ミョ", "ﾐｮ" },
        { "myu", "", "みゅ", "ミュ", "ﾐｭ" },
        // { "n", "", "ん", "ン", "ﾝ" },
        { "n\'", "", "ん", "ン", "ﾝ" },
        { "na", "", "な", "ナ", "ﾅ" },
        { "ne", "", "ね", "ネ", "ﾈ" },
        { "ni", "", "に", "ニ", "ﾆ" },
        { "nn", "", "ん", "ン", "ﾝ" },
        { "no", "", "の", "ノ", "ﾉ" },
        { "nu", "", "ぬ", "ヌ", "ﾇ" },
        { "nya", "", "にゃ", "ニャ", "ﾆｬ" },
        { "nye", "", "にぇ", "ニェ", "ﾆｪ" },
        { "nyi", "", "にぃ", "ニィ", "ﾆｨ" },
        { "nyo", "", "にょ", "ニョ", "ﾆｮ" },
        { "nyu", "", "にゅ", "ニュ", "ﾆｭ" },
        { "o", "", "お", "オ", "ｵ" },
        { "pp", "p", "っ", "ッ", "ｯ" },
        { "pa", "", "ぱ", "パ", "ﾊﾟ" },
        { "pe", "", "ぺ", "ペ", "ﾍﾟ" },
        { "pi", "", "ぴ", "ピ", "ﾋﾟ" },
        { "po", "", "ぽ", "ポ", "ﾎﾟ" },
        { "pu", "", "ぷ", "プ", "ﾌﾟ" },
        { "pya", "", "ぴゃ", "ピャ", "ﾋﾟｬ" },
        { "pye", "", "ぴぇ", "ピェ", "ﾋﾟｪ" },
        { "pyi", "", "ぴぃ", "ピィ", "ﾋﾟｨ" },
        { "pyo", "", "ぴょ", "ピョ", "ﾋﾟｮ" },
        { "pyu", "", "ぴゅ", "ピュ", "ﾋﾟｭ" },
        { "rr", "r", "っ", "ッ", "ｯ" },
        { "ra", "", "ら", "ラ", "ﾗ" },
        { "re", "", "れ", "レ", "ﾚ" },
        { "ri", "", "り", "リ", "ﾘ" },
        { "ro", "", "ろ", "ロ", "ﾛ" },
        { "ru", "", "る", "ル", "ﾙ" },
        { "rya", "", "りゃ", "リャ", "ﾘｬ" },
        { "rye", "", "りぇ", "リェ", "ﾘｪ" },
        { "ryi", "", "りぃ", "リィ", "ﾘｨ" },
        { "ryo", "", "りょ", "リョ", "ﾘｮ" },
        { "ryu", "", "りゅ", "リュ", "ﾘｭ" },
        { "ss", "s", "っ", "ッ", "ｯ" },
        { "sa", "", "さ", "サ", "ｻ" },
        { "se", "", "せ", "セ", "ｾ" },
        { "sha", "", "しゃ", "シャ", "ｼｬ" },
        { "she", "", "しぇ", "シェ", "ｼｪ" },
        { "shi", "", "し", "シ", "ｼ" },
        { "sho", "", "しょ", "ショ", "ｼｮ" },
        { "shu", "", "しゅ", "シュ", "ｼｭ" },
        { "si", "", "し", "シ", "ｼ" },
        { "so", "", "そ", "ソ", "ｿ" },
        { "su", "", "す", "ス", "ｽ" },
        { "sya", "", "しゃ", "シャ", "ｼｬ" },
        { "sye", "", "しぇ", "シェ", "ｼｪ" },
        { "syi", "", "しぃ", "シィ", "ｼｨ" },
        { "syo", "", "しょ", "ショ", "ｼｮ" },
        { "syu", "", "しゅ", "シュ", "ｼｭ" },
        { "tt", "t", "っ", "ッ", "ｯ" },
        { "ta", "", "た", "タ", "ﾀ" },
        { "te", "", "て", "テ", "ﾃ" },
        { "tha", "", "てぁ", "テァ", "ﾃｧ" },
        { "the", "", "てぇ", "テェ", "ﾃｪ" },
        { "thi", "", "てぃ", "ティ", "ﾃｨ" },
        { "tho", "", "てょ", "テョ", "ﾃｮ" },
        { "thu", "", "てゅ", "テュ", "ﾃｭ" },
        { "ti", "", "ち", "チ", "ﾁ" },
        { "to", "", "と", "ト", "ﾄ" },
        { "tsu", "", "つ", "ツ", "ﾂ" },
        { "tu", "", "つ", "ツ", "ﾂ" },
        { "tya", "", "ちゃ", "チャ", "ﾁｬ" },
        { "tye", "", "ちぇ", "チェ", "ﾁｪ" },
        { "tyi", "", "ちぃ", "チィ", "ﾁｨ" },
        { "tyo", "", "ちょ", "チョ", "ﾁｮ" },
        { "tyu", "", "ちゅ", "チュ", "ﾁｭ" },
        { "u", "", "う", "ウ", "ｳ" },
        { "vv", "v", "っ", "ッ", "ｯ" },
        { "va", "", "う゛ぁ", "ヴァ", "ｳﾞｧ" },
        { "ve", "", "う゛ぇ", "ヴェ", "ｳﾞｪ" },
        { "vi", "", "う゛ぃ", "ヴィ", "ｳﾞｨ" },
        { "vo", "", "う゛ぉ", "ヴォ", "ｳﾞｫ" },
        { "vu", "", "う゛", "ヴ", "ｳﾞ" },
        { "ww", "w", "っ", "ッ", "ｯ" },
        { "wa", "", "わ", "ワ", "ﾜ" },
        { "we", "", "うぇ", "ウェ", "ｳｪ" },
        { "wi", "", "うぃ", "ウィ", "ｳｨ" },
        { "wo", "", "を", "ヲ", "ｦ" },
        { "wu", "", "う", "ウ", "ｳ" },
        { "xx", "x", "っ", "ッ", "ｯ" },
        { "xa", "", "ぁ", "ァ", "ｧ" },
        { "xe", "", "ぇ", "ェ", "ｪ" },
        { "xi", "", "ぃ", "ィ", "ｨ" },
        { "xka", "", "か", "ヵ", "ｶ" },
        { "xke", "", "け", "ヶ", "ｹ" },
        { "xo", "", "ぉ", "ォ", "ｫ" },
        { "xtsu", "", "っ", "ッ", "ｯ" },
        { "xtu", "", "っ", "ッ", "ｯ" },
        { "xu", "", "ぅ", "ゥ", "ｩ" },
        { "xwa", "", "ゎ", "ヮ", "ﾜ" },
        { "xwe", "", "ゑ", "ヱ", "ｴ" },
        { "xwi", "", "ゐ", "ヰ", "ｲ" },
        { "xya", "", "ゃ", "ャ", "ｬ" },
        { "xyo", "", "ょ", "ョ", "ｮ" },
        { "xyu", "", "ゅ", "ュ", "ｭ" },
        { "yy", "y", "っ", "ッ", "ｯ" },
        { "ya", "", "や", "ヤ", "ﾔ" },
        { "ye", "", "いぇ", "イェ", "ｲｪ" },
        { "yo", "", "よ", "ヨ", "ﾖ" },
        { "yu", "", "ゆ", "ユ", "ﾕ" },
        { "zz", "z", "っ", "ッ", "ｯ" },
        { "z,", "", "‥", "‥", "‥" },
        { "z-", "", "〜", "〜", "~" },
        { "z.", "", "…", "…", "…" },
        { "z/", "", "・", "・", "･" },
        { "z[", "", "『", "『", "『" },
        { "z]", "", "』", "』", "』" },
        { "za", "", "ざ", "ザ", "ｻﾞ" },
        { "ze", "", "ぜ", "ゼ", "ｾﾞ" },
        { "zh", "", "←", "←", "←" },
        { "zi", "", "じ", "ジ", "ｼﾞ" },
        { "zj", "", "↓", "↓", "↓" },
        { "zk", "", "↑", "↑", "↑" },
        { "zl", "", "→", "→", "→" },
        { "zo", "", "ぞ", "ゾ", "ｿﾞ" },
        { "zu", "", "ず", "ズ", "ｽﾞ" },
        { "zya", "", "じゃ", "ジャ", "ｼﾞｬ" },
        { "zye", "", "じぇ", "ジェ", "ｼﾞｪ" },
        { "zyi", "", "じぃ", "ジィ", "ｼﾞｨ" },
        { "zyo", "", "じょ", "ジョ", "ｼﾞｮ" },
        { "zyu", "", "じゅ", "ジュ", "ｼﾞｭ" },
        { "-", "", "ー", "ー", "ｰ" },
        { ":", "", "：", "：", ":" },
        { ";", "", "；", "；", ";" },
        { "?", "", "？", "？", "?" },
        { "[", "", "「", "「", "｢" },
        { "]", "", "」", "」", "｣" }
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

        public RomKanaConverter () {
            root_node = new RomKanaNode (null);
            foreach (var entry in ROM_KANA_RULE) {
                root_node.insert (entry.rom, entry);
            }
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
