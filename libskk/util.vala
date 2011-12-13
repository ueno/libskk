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
    struct Entry<K,V> {
        K key;
        V value;
    }

    enum NumericConversionType {
        LATIN,
        WIDE_LATIN,
        KANJI_NUMERAL,
        KANJI,
        RECONVERT,
        DAIJI,
        SHOGI
    }

    class Util : Object {
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

        static const Entry<string,string>[] ZenkakuToHankakuKatakanaTable = {
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

        static const Entry<string,string>[] HankakuToZenkakuAsciiTable = {
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

        static const Entry<string,string>[] HankakuKatakanaSubstitutes = {
            {"ヵ", "ｶ"},
            {"ヶ", "ｹ"}
        };

        static const Entry<string,string>[] HankakuKatakanaSonants = {
            {"ﾞ", "゙"},
            {"ﾟ", "゚"}
        };

        static const string[] KanjiNumericTable = {
            "〇", "一", "二", "三", "四", "五", "六", "七", "八", "九"
        };

        static const string[] DaijiNumericTable = {
            "零", "壱", "弐", "参", "四", "伍", "六", "七", "八", "九"
        };

        static const string?[] KanjiNumericalPositionTable = {
            null, "十", "百", "千", "万", null, null, null, "億",
            null, null, null, "兆", null, null, null, null, "京"
        };

        static const string?[] DaijiNumericalPositionTable = {
            null, "拾", "百", "阡", "萬", null, null, null, "億",
            null, null, null, "兆", null, null, null, null, "京"
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

        internal static string get_wide_latin (string latin) {
            StringBuilder builder = new StringBuilder ();
            int index = 0;
            unichar uc;
            while (latin.get_next_char (ref index, out uc)) {
                if (0x20 <= uc && uc <= 0x7E) {
                    builder.append_unichar (get_wide_latin_char ((char)uc));
                } else {
                    builder.append_unichar (uc);
                }
            }
            return builder.str;
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
            string katakana = get_katakana (kana);
            StringBuilder builder = new StringBuilder ();
            int index = 0;
            unichar uc;
            while (katakana.get_next_char (ref index, out uc)) {
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

        internal static string get_hiragana (string kana) {
            int diff = 0x30a2 - 0x3042; // ア - あ
            string str = kana.replace ("ヴ", "ウ゛");
            StringBuilder builder = new StringBuilder ();
            int index = 0;
            unichar uc;
            while (str.get_next_char (ref index, out uc)) {
                // ァ <= uc && uc <= ン
                if (0x30a1 <= uc && uc <= 0x30f3) {
                    builder.append_unichar (uc - diff);
                } else {
                    builder.append_unichar (uc);
                }
            }
            return builder.str;
        }

        internal static string get_katakana (string kana) {
            int diff = 0x30a2 - 0x3042; // ア - あ
            StringBuilder builder = new StringBuilder ();
            int index = 0;
            unichar uc;
            while (kana.get_next_char (ref index, out uc)) {
                // ぁ <= uc && uc <= ん
                if (0x3041 <= uc && uc <= 0x3093) {
                    builder.append_unichar (uc + diff);
                } else {
                    builder.append_unichar (uc);
                }
            }
            return builder.str.replace ("ウ゛", "ヴ");
        }

        static string get_kanji_numeric (int numeric,
                                         string[] num_table,
                                         string[]? num_pos_table = null)
        {
            var builder = new StringBuilder ();
            var str = numeric.to_string ();
            unichar uc;
            if (num_pos_table == null) {
                for (var index = 0; str.get_next_char (ref index, out uc); ) {
                    builder.append (num_table[uc - '0']);
                }
                return builder.str;
            }
            else {
                for (var index = 0; str.get_next_char (ref index, out uc); ) {
                    if (uc > '0') {
                        int pos_index = str.length - index;
                        if (uc != '1' || pos_index % 4 == 0)
                            builder.append (KanjiNumericTable[uc - '0']);
                        var pos = num_pos_table[pos_index];
                        if (pos == null && pos_index % 4 > 0) {
                            pos = num_pos_table[pos_index % 4];
                        }
                        if (pos != null)
                            builder.append (pos);
                    }
                }
                return builder.str;
            }
        }

        internal static string get_numeric (int numeric,
                                            NumericConversionType type)
        {
            switch (type) {
            case NumericConversionType.LATIN:
                return numeric.to_string ();
            case NumericConversionType.WIDE_LATIN:
                return get_wide_latin (numeric.to_string ());
            case NumericConversionType.KANJI_NUMERAL:
                return get_kanji_numeric (numeric, KanjiNumericTable);
            case NumericConversionType.KANJI:
                return get_kanji_numeric (numeric,
                                          KanjiNumericTable,
                                          KanjiNumericalPositionTable);
            case NumericConversionType.DAIJI:
                return get_kanji_numeric (numeric,
                                          DaijiNumericTable,
                                          DaijiNumericalPositionTable);
            default:
                break;
            }
            return "";
        }

        static construct {
            foreach (var entry in ZenkakuToHankakuKatakanaTable) {
                _ZenkakuToHankakuKatakanaTable.set (entry.key, entry.value);
                _HankakuToZenkakuKatakanaTable.set (entry.value, entry.key);
            }
            foreach (var entry in HankakuKatakanaSonants) {
                _HankakuKatakanaSonants.set (entry.key, entry.value);
            }
            foreach (var entry in HankakuKatakanaSubstitutes) {
                _HankakuKatakanaSubstitutes.set (entry.key, entry.value);
            }
        }

        internal static string[] build_data_path (string subdir) {
            ArrayList<string> dirs = new ArrayList<string> ();
            string? path = Environment.get_variable ("LIBSKK_DATA_PATH");
            if (path == null) {
                dirs.add (Path.build_filename (
                              Environment.get_user_config_dir (),
                              Config.PACKAGE_NAME,
                              subdir));
                dirs.add (Path.build_filename (Config.PKGDATADIR, subdir));
            } else {
                string[] elements = path.split (":");
                foreach (var element in elements) {
                    dirs.add (Path.build_filename (element, subdir));
                }
            }
            return dirs.to_array ();
        }
    }

    class UnicodeString : Object {
        string str;
        internal int length;

        internal UnicodeString (string str) {
            this.str = str;
            this.length = str.char_count ();
        }

        internal string substring (long offset, long len = -1) {
            long byte_offset = str.index_of_nth_char (offset);
            long byte_len;
            if (len < 0) {
                byte_len = len;
            } else {
                byte_len = str.index_of_nth_char (offset + len) - byte_offset;
            }
            return str.substring (byte_offset, byte_len);
        }
    }

    class MemoryMappedFile : Object {
        void *_memory = null;
        public void *memory {
            get {
                return _memory;
            }
        }

        size_t _length = 0;
        public size_t length {
            get {
                return _length;
            }
        }

        File file;

        public MemoryMappedFile (File file) {
            this.file = file;
        }

        public void remap () throws SkkDictError {
            if (_memory != null) {
                Posix.munmap (_memory, _length);
                _memory = null;
            }
            map ();
        }

        void map () throws SkkDictError {
            int fd = Posix.open (file.get_path (), Posix.O_RDONLY, 0);
            if (fd < 0) {
                throw new SkkDictError.NOT_READABLE ("can't open %s",
                                                     file.get_path ());
            }

            Posix.Stat stat;
            int retval = Posix.fstat (fd, out stat);
            if (retval < 0) {
                throw new SkkDictError.NOT_READABLE ("can't stat fd");
            }

            _memory = Posix.mmap (null,
                                  stat.st_size,
                                  Posix.PROT_READ,
                                  Posix.MAP_SHARED,
                                  fd,
                                  0);
            if (_memory == Posix.MAP_FAILED) {
                throw new SkkDictError.NOT_READABLE ("mmap failed");
            }
            _length = stat.st_size;
        }
    }
}
