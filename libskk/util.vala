/*
 * Copyright (C) 2011-2026 Daiki Ueno <ueno@gnu.org>
 * Copyright (C) 2011-2026 Red Hat, Inc.
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
        struct KanaTableEntry {
            unichar katakana;
            string? hiragana;
            string? hankaku_katakana;
        }

        const KanaTableEntry[] KanaTable = {
            {'ア', "あ", "ｱ"}, {'イ', "い", "ｲ"}, {'ウ', "う", "ｳ"},
            {'エ', "え", "ｴ"}, {'オ', "お", "ｵ"}, {'カ', "か", "ｶ"},
            {'キ', "き", "ｷ"}, {'ク', "く", "ｸ"}, {'ケ', "け", "ｹ"},
            {'コ', "こ", "ｺ"}, {'サ', "さ", "ｻ"}, {'シ', "し", "ｼ"},
            {'ス', "す", "ｽ"}, {'セ', "せ", "ｾ"}, {'ソ', "そ", "ｿ"},
            {'タ', "た", "ﾀ"}, {'チ', "ち", "ﾁ"}, {'ツ', "つ", "ﾂ"},
            {'テ', "て", "ﾃ"}, {'ト', "と", "ﾄ"}, {'ナ', "な", "ﾅ"},
            {'ニ', "に", "ﾆ"}, {'ヌ', "ぬ", "ﾇ"}, {'ネ', "ね", "ﾈ"},
            {'ノ', "の", "ﾉ"}, {'ハ', "は", "ﾊ"}, {'ヒ', "ひ", "ﾋ"},
            {'フ', "ふ", "ﾌ"}, {'ヘ', "へ", "ﾍ"}, {'ホ', "ほ", "ﾎ"},
            {'マ', "ま", "ﾏ"}, {'ミ', "み", "ﾐ"}, {'ム', "む", "ﾑ"},
            {'メ', "め", "ﾒ"}, {'モ', "も", "ﾓ"}, {'ヤ', "や", "ﾔ"},
            {'ユ', "ゆ", "ﾕ"}, {'ヨ', "よ", "ﾖ"}, {'ラ', "ら", "ﾗ"},
            {'リ', "り", "ﾘ"}, {'ル', "る", "ﾙ"}, {'レ', "れ", "ﾚ"},
            {'ロ', "ろ", "ﾛ"}, {'ワ', "わ", "ﾜ"}, {'ヰ', "ゐ", "ｲ"},
            {'ヱ', "ゑ", "ｴ"}, {'ヲ', "を", "ｦ"}, {'ン', "ん", "ﾝ"},
            {'ガ', "が", "ｶﾞ"}, {'ギ', "ぎ", "ｷﾞ"}, {'グ', "ぐ", "ｸﾞ"},
            {'ゲ', "げ", "ｹﾞ"}, {'ゴ', "ご", "ｺﾞ"}, {'ザ', "ざ", "ｻﾞ"},
            {'ジ', "じ", "ｼﾞ"}, {'ズ', "ず", "ｽﾞ"}, {'ゼ', "ぜ", "ｾﾞ"},
            {'ゾ', "ぞ", "ｿﾞ"}, {'ダ', "だ", "ﾀﾞ"}, {'ヂ', "ぢ", "ﾁﾞ"},
            {'ヅ', "づ", "ﾂﾞ"}, {'デ', "で", "ﾃﾞ"}, {'ド', "ど", "ﾄﾞ"},
            {'バ', "ば", "ﾊﾞ"}, {'ビ', "び", "ﾋﾞ"}, {'ブ', "ぶ", "ﾌﾞ"},
            {'ベ', "べ", "ﾍﾞ"}, {'ボ', "ぼ", "ﾎﾞ"}, {'パ', "ぱ", "ﾊﾟ"},
            {'ピ', "ぴ", "ﾋﾟ"}, {'プ', "ぷ", "ﾌﾟ"}, {'ペ', "ぺ", "ﾍﾟ"},
            {'ポ', "ぽ", "ﾎﾟ"}, {'ァ', "ぁ", "ｧ"}, {'ィ', "ぃ", "ｨ"},
            {'ゥ', "ぅ", "ｩ"}, {'ェ', "ぇ", "ｪ"}, {'ォ', "ぉ", "ｫ"},
            {'ッ', "っ", "ｯ"},
            {'ャ', "ゃ", "ｬ"}, {'ュ', "ゅ", "ｭ"}, {'ョ', "ょ", "ｮ"},
            {'ヮ', "ゎ", null},
            {'ヴ', "う゛", "ｳﾞ"}, {'ヵ', "ゕ", null}, {'ヶ', "ゖ", null},
            {'．', "．", "."},
            {'，', "，", ","},
            {'。', "。", "｡"},
            {'「', "「", "｢"},
            {'」', "」", "｣"},
            {'、', "、", "､"},
            {'・', "・", "･"},
            {'ー', "ー", "ｰ"},
            {'゛', "゛", "ﾞ"},
            {'゜', "゜", "ﾟ"}
        };

        const KanaTableEntry[] HankakuKatakanaSubstitute = {
            {'ヮ', null, "ﾜ"},
            {'ヵ', null, "ｶ"},
            {'ヶ', null, "ｹ"}
        };

        const string[] WideLatinTable = {
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

        const string[] KanaRomTable = {
            "x", "a", "x", "i", "x", "u", "x", "e", "x", "o", "k",
            "g", "k", "g", "k", "g", "k", "g", "k", "g", "s", "z",
            "s", "z", "s", "z", "s", "z", "s", "z", "t", "d", "t",
            "d", "t", "t", "d", "t", "d", "t", "d", "n", "n", "n",
            "n", "n", "h", "b", "p", "h", "b", "p", "h", "b", "p",
            "h", "b", "p", "h", "b", "p", "m", "m", "m", "m", "m",
            "x", "y", "x", "y", "x", "y", "r", "r", "r", "r", "r",
            "x", "w", "x", "x", "w", "n"
        };

        static string? get_okurigana_prefix_for_char (unichar uc) {
            if (uc == 'ん') {
                return "n";
            }
            else if (uc < 'ぁ' || uc > 'ん') {
                return null;
            }
            else {
                return KanaRomTable[uc - 'ぁ'];
            }
        }

        internal static string? get_okurigana_prefix (string okurigana) {
            var head = okurigana.get_char ();
            if (head == 'っ' && okurigana != "っ") {
                var index = okurigana.index_of_nth_char (1);
                head = okurigana.get_char (index);
            }
            return get_okurigana_prefix_for_char (head);
        }

        const string[] KanjiNumericTable = {
            "〇", "一", "二", "三", "四", "五", "六", "七", "八", "九"
        };

        const string[] DaijiNumericTable = {
            "零", "壱", "弐", "参", "四", "伍", "六", "七", "八", "九"
        };

        const string?[] KanjiNumericalPositionTable = {
            null, "十", "百", "千", "万", null, null, null, "億",
            null, null, null, "兆", null, null, null, null, "京"
        };

        const string?[] DaijiNumericalPositionTable = {
            null, "拾", "百", "阡", "萬", null, null, null, "億",
            null, null, null, "兆", null, null, null, null, "京"
        };

        // katakana to hiragana
        static Map<unichar,string> _HiraganaTable =
            new HashMap<unichar,string> ();
        // hiragana or hankaku katakana (not composed) to katakana
        static Map<unichar,unichar> _KatakanaTable =
            new HashMap<unichar,unichar> ();
        // katakana to hankaku katakana
        static Map<unichar,string> _HankakuKatakanaTable =
            new HashMap<unichar,string> ();
        static Map<unichar,Map<unichar,unichar>> _CompositionTable =
            new HashMap<unichar,HashMap<unichar,unichar>> ();
        static Map<string,char> _WideLatinToLatinTable =
            new HashMap<string,char> ();

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

#if 0
        internal static string get_latin (string wide_latin) {
            StringBuilder builder = new StringBuilder ();
            int index = 0;
            unichar uc;
            while (wide_latin.get_next_char (ref index, out uc)) {
                string str = uc.to_string ();
                if (_WideLatinToLatinTable.has_key (str)) {
                    builder.append_c (_WideLatinToLatinTable.get (str));
                } else {
                    builder.append (str);
                }
            }
            return builder.str;
        }
#endif

        static unichar get_katakana_char (unichar uc) {
            if (_KatakanaTable.has_key (uc)) {
                return _KatakanaTable.get (uc);
            }
            return uc;
        }

        static void foreach_katakana (string kana,
                                      Func<unichar> func)
        {
            int index = 0;
            unichar uc0;
            while (kana.get_next_char (ref index, out uc0)) {
                if (_CompositionTable.has_key (uc0)) {
                    var composition = _CompositionTable.get (uc0);
                    unichar uc1;
                    if (kana.get_next_char (ref index, out uc1)) {
                        if (composition.has_key (uc1))
                            func (composition.get (uc1));
                        else {
                            func (get_katakana_char (uc0));
                            func (get_katakana_char (uc1));
                        }
                    } else {
                        func (get_katakana_char (uc0));
                        break;
                    }
                } else {
                    func (get_katakana_char (uc0));
                }
            }
        }

        internal static string get_katakana (string kana) {
            StringBuilder builder = new StringBuilder ();
            foreach_katakana (kana, (uc) => {
                    builder.append_unichar (uc);
                });
            return builder.str;
        }

        internal static string get_hiragana (string kana) {
            StringBuilder builder = new StringBuilder ();
            foreach_katakana (kana, (uc) => {
                    if (_HiraganaTable.has_key (uc)) {
                        builder.append (_HiraganaTable.get (uc));
                    } else {
                        builder.append_unichar (uc);
                    }
                });
            return builder.str;
        }

        internal static string get_hankaku_katakana (string kana) {
            StringBuilder builder = new StringBuilder ();
            foreach_katakana (kana, (uc) => {
                    if (_HankakuKatakanaTable.has_key (uc)) {
                        builder.append (_HankakuKatakanaTable.get (uc));
                    } else {
                        builder.append_unichar (uc);
                    }
                });
            return builder.str;
        }

        internal static string convert_by_input_mode (string str,
                                                      InputMode input_mode)
        {
            switch (input_mode) {
            case InputMode.HIRAGANA:
                return get_hiragana (str);
            case InputMode.KATAKANA:
                return get_katakana (str);
            case InputMode.HANKAKU_KATAKANA:
                return get_hankaku_katakana (str);
#if 0
            case InputMode.LATIN:
                return get_latin (str);
#endif
            case InputMode.WIDE_LATIN:
                return get_wide_latin (str);
            default:
                return str;
            }
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
            foreach (var entry in KanaTable) {
                _HiraganaTable.set (entry.katakana,
                                    entry.hiragana);
                _HankakuKatakanaTable.set (entry.katakana,
                                           entry.hankaku_katakana);
                foreach (var substitute in HankakuKatakanaSubstitute) {
                    _HankakuKatakanaTable.set (substitute.katakana,
                                               substitute.hankaku_katakana);
                }

                if (entry.hiragana != null) {
                    if (entry.hiragana.char_count () > 1) {
                        int index = 0;
                        unichar uc0, uc1;
                        entry.hiragana.get_next_char (ref index, out uc0);
                        entry.hiragana.get_next_char (ref index, out uc1);
                        if (!_CompositionTable.has_key (uc0)) {
                            _CompositionTable.set (
                                uc0,
                                new HashMap<unichar,unichar> ());
                        }
                        var composition = _CompositionTable.get (uc0);
                        composition.set (uc1, entry.katakana);
                    } else {
                        _KatakanaTable.set (entry.hiragana.get_char (),
                                            entry.katakana);
                    }
                }

                if (entry.hankaku_katakana != null) {
                    if (entry.hankaku_katakana.char_count () > 1) {
                        int index = 0;
                        unichar uc0, uc1;
                        entry.hankaku_katakana.get_next_char (
                            ref index, out uc0);
                        entry.hankaku_katakana.get_next_char (
                            ref index, out uc1);
                        if (!_CompositionTable.has_key (uc0)) {
                            _CompositionTable.set (
                                uc0,
                                new HashMap<unichar,unichar> ());
                        }
                        var composition = _CompositionTable.get (uc0);
                        composition.set (uc1, entry.katakana);
                    } else {
                        _KatakanaTable.set (entry.hankaku_katakana.get_char (),
                                            entry.katakana);
                    }
                }
            }
            for (var i = 0; i < WideLatinTable.length; i++) {
                _WideLatinToLatinTable.set (WideLatinTable[i], i + 32);
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

    abstract class KeyEventUtils : Object {
        public static string? keyval_name (uint keyval) {
            uint8[] buffer = new uint8[64];
            int ret = -1;

            do {
                ret = Xkb.keysym_get_name ((uint32) keyval, buffer);
                if (ret == -1)
                    return null;
                if (ret < buffer.length)
                    return (string) buffer;
                buffer = new uint8[buffer.length * 2];
            } while (ret >= buffer.length);

            return null;
        }

        public static uint keyval_from_name (string name) {
            // special cases for compatibilty with older libskk
            if (name == " ")
                name = "space";
            else if (name == "\t")
                name = "Tab";
            else if (name == "\n")
                name = "Return";
            else if (name == "\b")
                name = "BackSpace";

            var keysym = Xkb.keysym_from_name (name, Xkb.KeysymFlags.NO_FLAGS);
            if (keysym == Xkb.Keysym.NoSymbol) {
                // handle ASCII keyvals with differnet name (e.g. at,
                // percent, etc.)
                if (name.char_count () == 1) {
                    unichar code = name.get_char ();
                    if (0x20 <= code && code < 0x7F)
                        return code;
                }
                return Keysyms.VoidSymbol;
            }
            return (uint) keysym;
        }

        public static unichar keyval_unicode (uint keyval) {
            // handle ASCII keyvals with differnet name (e.g. at,
            // percent, etc.)
            if (0x20 <= keyval && keyval < 0x7F)
                return keyval;

            // special case
            if (keyval == Keysyms.yen)
                return "\xc2\xa5".get_char ();

            uint8[] buffer = new uint8[8];
            int ret = -1;

            do {
                ret = Xkb.keysym_to_utf8 ((uint32) keyval, buffer);
                if (ret == 0)
                    return '\0';
                buffer = new uint8[buffer.length * 2];
            } while (ret == -1);

            return '\0';
        }
    }
}
