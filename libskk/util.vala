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
    class Util {
        static const string[] WideLatinTable = {
            "　", "！", "”", "＃", "＄", "％", "＆", "’", 
            "（", "）", "＊", "＋", "，", "−", "．", "／", 
            "０", "１", "２", "３", "４", "５", "６", "７", 
            "８", "９", "：", "；", "＜", "＝", "＞", "？", 
            "＠", "Ａ", "Ｂ", "Ｃ", "Ｄ", "Ｅ", "Ｆ", "Ｇ", 
            "Ｈ", "Ｉ", "Ｊ", "Ｋ", "Ｌ", "Ｍ", "Ｎ", "Ｏ", 
            "Ｐ", "Ｑ", "Ｒ", "Ｓ", "Ｔ", "Ｕ", "Ｖ", "Ｗ", 
            "Ｘ", "Ｙ", "Ｚ", "［", "＼", "］", "＾", "＿", 
            "‘", "ａ", "ｂ", "ｃ", "ｄ", "ｅ", "ｆ", "ｇ", 
            "ｈ", "ｉ", "ｊ", "ｋ", "ｌ", "ｍ", "ｎ", "ｏ", 
            "ｐ", "ｑ", "ｒ", "ｓ", "ｔ", "ｕ", "ｖ", "ｗ", 
            "ｘ", "ｙ", "ｚ", "｛", "｜", "｝", "〜"
        };

        struct MapEntry {
            string from;
            string to;
        }
        
        static const MapEntry[] ZenkakuToHankakuKatakanaTable = {
            {"ア", "ｱ"}, {"イ", "ｲ"}, {"ウ", "ｳ"}, {"エ", "ｴ"}, {"オ", "ｵ"},
            {"カ", "ｶ"}, {"キ", "ｷ"}, {"ク", "ｸ"}, {"ケ", "ｹ"}, {"コ", "ｺ"},
            {"サ", "ｻ"}, {"シ", "ｼ"}, {"ス", "ｽ"}, {"セ", "ｾ"}, {"ソ", "ｿ"},
            {"タ", "ﾀ"}, {"チ", "ﾁ"}, {"ツ", "ﾂ"}, {"テ", "ﾃ"}, {"ト", "ﾄ"},
            {"ナ", "ﾅ"}, {"ニ", "ﾆ"}, {"ヌ", "ﾇ"}, {"ネ", "ﾈ"}, {"ノ", "ﾉ"},
            {"ハ", "ﾊ"}, {"ヒ", "ﾋ"}, {"フ", "ﾌ"}, {"ヘ", "ﾍ"}, {"ホ", "ﾎ"},
            {"マ", "ﾏ"}, {"ミ", "ﾐ"}, {"ム", "ﾑ"}, {"メ", "ﾒ"}, {"モ", "ﾓ"},
            {"ヤ", "ﾔ"}, {"ユ", "ﾕ"}, {"ヨ", "ﾖ"},
            {"ラ", "ﾗ"}, {"リ", "ﾘ"}, {"ル", "ﾙ"}, {"レ", "ﾚ"}, {"ロ", "ﾛ"},
            {"ワ", "ﾜ"}, {"ヰ", "ｲ"}, {"ヱ", "ｴ"}, {"ヲ", "ｦ"},
            {"ン", "ﾝ"},
            {"ガ", "ｶﾞ"}, {"ギ", "ｷﾞ"}, {"グ", "ｸﾞ"}, {"ゲ", "ｹﾞ"}, {"ゴ", "ｺﾞ"},
            {"ザ", "ｻﾞ"}, {"ジ", "ｼﾞ"}, {"ズ", "ｽﾞ"}, {"ゼ", "ｾﾞ"}, {"ゾ", "ｿﾞ"},
            {"ダ", "ﾀﾞ"}, {"ヂ", "ﾁﾞ"}, {"ヅ", "ﾂﾞ"}, {"デ", "ﾃﾞ"}, {"ド", "ﾄﾞ"},
            {"バ", "ﾊﾞ"}, {"ビ", "ﾋﾞ"}, {"ブ", "ﾌﾞ"}, {"ベ", "ﾍﾞ"}, {"ボ", "ﾎﾞ"},
            {"パ", "ﾊﾟ"}, {"ピ", "ﾋﾟ"}, {"プ", "ﾌﾟ"}, {"ペ", "ﾍﾟ"}, {"ポ", "ﾎﾟ"},
            {"ァ", "ｧ"}, {"ィ", "ｨ"}, {"ゥ", "ｩ"}, {"ェ", "ｪ"}, {"ォ", "ｫ"},
            {"ッ", "ｯ"},
            {"ャ", "ｬ"}, {"ュ", "ｭ"}, {"ョ", "ｮ"},
            {"ヮ", "ﾜ"},
            {"ヴ", "ｳﾞ"}
        };

        static const MapEntry[] HankakuToZenkakuAsciiTable = {
            {" ", "　"},
            {":", "："}, {";", "；"}, {"?", "？"}, {"!", "！"},
            {"\'", "´"}, {"`", "｀"}, {"^", "＾"}, {"_", "＿"}, {"-", "ー"},
            {"-", "—"},
            {"-", "‐"},
            {"/", "／"}, {"\\", "＼"}, {"~", "〜"}, {"|", "｜"}, {"`", "‘"},
            {"\'", "’"}, {"\"", "“"}, {"\"", "”"},
            {"(", "（"}, {")", "）"}, {"[", "［"}, {"]", "］"}, {"{", "｛"},
            {"}", "｝"}, 
            {"<", "〈"}, {">", "〉"}, {"｢", "「"}, {"｣", "」"}, 
            {"+", "＋"}, {"-", "−"}, {"=", "＝"}, {"<", "＜"}, {">", "＞"},
            {"\'", "′"}, {"\"", "″"}, {"\\", "￥"}, {"$", "＄"}, {"%", "％"},
            {"#", "＃"}, {"&", "＆"}, {"*", "＊"},
            {"@", "＠"},
            {"0", "０"}, {"1", "１"}, {"2", "２"}, {"3", "３"}, {"4", "４"}, 
            {"5", "５"}, {"6", "６"}, {"7", "７"}, {"8", "８"}, {"9", "９"}, 
            {"A", "Ａ"}, {"B", "Ｂ"}, {"C", "Ｃ"}, {"D", "Ｄ"}, {"E", "Ｅ"}, 
            {"F", "Ｆ"}, {"G", "Ｇ"}, {"H", "Ｈ"}, {"I", "Ｉ"}, {"J", "Ｊ"}, 
            {"K", "Ｋ"}, {"L", "Ｌ"}, {"M", "Ｍ"}, {"N", "Ｎ"}, {"O", "Ｏ"}, 
            {"P", "Ｐ"}, {"Q", "Ｑ"}, {"R", "Ｒ"}, {"S", "Ｓ"}, {"T", "Ｔ"}, 
            {"U", "Ｕ"}, {"V", "Ｖ"}, {"W", "Ｗ"}, {"X", "Ｘ"}, {"Y", "Ｙ"},
            {"Z", "Ｚ"}, 
            {"a", "ａ"}, {"b", "ｂ"}, {"c", "ｃ"}, {"d", "ｄ"}, {"e", "ｅ"}, 
            {"f", "ｆ"}, {"g", "ｇ"}, {"h", "ｈ"}, {"i", "ｉ"}, {"j", "ｊ"}, 
            {"k", "ｋ"}, {"l", "ｌ"}, {"m", "ｍ"}, {"n", "ｎ"}, {"o", "ｏ"}, 
            {"p", "ｐ"}, {"q", "ｑ"}, {"r", "ｒ"}, {"s", "ｓ"}, {"t", "ｔ"}, 
            {"u", "ｕ"}, {"v", "ｖ"}, {"w", "ｗ"}, {"x", "ｘ"}, {"y", "ｙ"},
            {"z", "ｚ"}
        };

        static const MapEntry[] HankakuKatakanaSubstitutes = {
            {"ヵ", "ｶ"},
            {"ヶ", "ｹ"}
        };

        static const MapEntry[] HankakuKatakanaSonants = {
            {"ﾞ", "゙"},
            {"ﾟ", "゚"}
        };

        static HashMap<string,string> _ZenkakuToHankakuKatakanaTable =
            new HashMap<string,string> ();
        static HashMap<string,string> _HankakuToZenkakuKatakanaTable =
            new HashMap<string,string> ();
        static HashMap<string,string> _HankakuKatakanaSubstitutes =
            new HashMap<string,string> ();
        static HashMap<string,string> _HankakuKatakanaSonants =
            new HashMap<string,string> ();

        internal static unichar get_wide_latin_char (char c) {
            return WideLatinTable[c - 32].get_char ();
        }

        internal static string get_zenkaku_katakana (string kana) {
            StringBuilder builder = new StringBuilder ();
            int index = 0;
            unichar uc;
            while (kana.get_next_char (ref index, out uc)) {
                string str = uc.to_string ();
                if (_HankakuKatakanaSonants.has_key (str)) {
                    builder.append (_HankakuKatakanaSonants.get (str));
                } else if (_HankakuToZenkakuKatakanaTable.has_key (str)) {
                    builder.append (_HankakuToZenkakuKatakanaTable.get (str));
                } else {
                    builder.append (str);
                }
            }
            return builder.str;
        }

        internal static string get_hankaku_katakana (string kana) {
            StringBuilder builder = new StringBuilder ();
            int index = 0;
            unichar uc;
            while (kana.get_next_char (ref index, out uc)) {
                string str = uc.to_string ();
                if (_HankakuKatakanaSubstitutes.has_key (str)) {
                    builder.append (_HankakuKatakanaSubstitutes.get (str));
                } else if (_ZenkakuToHankakuKatakanaTable.has_key (str)) {
                    builder.append (_ZenkakuToHankakuKatakanaTable.get (str));
                } else {
                    builder.append (str);
                }
            }
            return builder.str;
        }

        static construct {
            foreach (var entry in ZenkakuToHankakuKatakanaTable) {
                _ZenkakuToHankakuKatakanaTable.set (entry.from, entry.to);
                _HankakuToZenkakuKatakanaTable.set (entry.to, entry.from);
            }
            foreach (var entry in HankakuKatakanaSonants) {
                _HankakuKatakanaSonants.set (entry.from, entry.to);
            }
            foreach (var entry in HankakuKatakanaSubstitutes) {
                _HankakuKatakanaSubstitutes.set (entry.from, entry.to);
            }
        }
    }
}
