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
    class KeymapMapFile : MapFile {
        internal Keymap keymap;

        internal KeymapMapFile (string name, string mode) throws RuleParseError
        {
            base (name, "keymap", mode);
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

    class RomKanaMapFile : MapFile {
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

        public RomKanaMapFile (string name) throws RuleParseError {
            base (name, "rom-kana", "default");
            if (has_map ("rom-kana")) {
                root_node = parse_rule (get ("rom-kana"));
            } else {
                throw new RuleParseError.FAILED ("no rom-kana entry");
            }
        }
    }

    public errordomain RuleParseError {
        FAILED
    }

    /**
     * Object describes rule.
     */
    public struct RuleMetadata {
        string name;
        string label;
        string description;
        string filter;
    }

    // A rule is a set of MapFiles and a RuleMetadata
    public class Rule : Object {
        internal RuleMetadata metadata;
        internal KeymapMapFile[] keymaps = new KeymapMapFile[InputMode.LAST];
        internal RomKanaMapFile rom_kana;

        static const Entry<InputMode,string>[] keymap_entries = {
            { InputMode.HIRAGANA, "hiragana" },
            { InputMode.KATAKANA, "katakana" },
            { InputMode.HANKAKU_KATAKANA, "hankaku-katakana" },
            { InputMode.LATIN, "latin" },
            { InputMode.WIDE_LATIN, "wide-latin" }
        };

        static Map<string,Type> filter_types = new HashMap<string,Type> ();
        static construct {
            filter_types.set ("simple", typeof (SimpleKeyEventFilter));
            filter_types.set ("nicola", typeof (NicolaKeyEventFilter));
        }

        internal KeyEventFilter get_filter () {
            var type = filter_types.get (metadata.filter);
            return (KeyEventFilter) new Object (type);
        }

        public Rule (string name) throws RuleParseError {
            var metadata = get_metadata (name);
            if (metadata == null) {
                throw new RuleParseError.FAILED (
                    "can't find metadata for \"%s\"",
                    name);
            }
            this.metadata = metadata;

            foreach (var entry in keymap_entries) {
                keymaps[entry.key] = new KeymapMapFile (name, entry.value);
            }

            rom_kana = new RomKanaMapFile (name);
        }

        static bool load_metadata (string filename,
                                   out RuleMetadata? metadata)
        {
            Json.Parser parser = new Json.Parser ();
            try {
                if (!parser.load_from_file (filename)) {
                    metadata = null;
                    return false;
                }
                var root = parser.get_root ();
                if (root.get_node_type () != Json.NodeType.OBJECT) {
                    metadata = null;
                    return false;
                }

                var object = root.get_object ();
                Json.Node member;

                if (!object.has_member ("name")) {
                    metadata = null;
                    return false;
                }

                member = object.get_member ("name");
                var name = member.get_string ();

                if (!object.has_member ("description")) {
                    metadata = null;
                    return false;
                }

                member = object.get_member ("description");
                var description = member.get_string ();

                metadata = RuleMetadata () { label = name,
                                             description = description };

                if (object.has_member ("filter")) {
                    member = object.get_member ("filter");
                    metadata.filter = member.get_string ();
                } else {
                    metadata.filter = "simple";
                }

                return true;
            } catch (GLib.Error e) {
                metadata = null;
                return false;
            }
        }

        internal static string? get_base_dir (string name) {
            string? base_dir = null;
            RuleMetadata? metadata = null;
            if (find_rule (name, out base_dir, out metadata)) {
                return base_dir;
            }
            return null;
        }

        internal static RuleMetadata? get_metadata (string name) {
            string? base_dir = null;
            RuleMetadata? metadata = null;
            if (find_rule (name, out base_dir, out metadata)) {
                return metadata;
            }
            return null;
        }

        static bool find_rule (string name,
                               out string? base_dir,
                               out RuleMetadata? metadata)
        {
            var dirs = Util.build_data_path ("rules");
            foreach (var dir in dirs) {
                var base_dir_filename = Path.build_filename (dir, name);
                var metadata_filename = Path.build_filename (base_dir_filename,
                                                             "metadata.json");
                if (!FileUtils.test (metadata_filename, FileTest.EXISTS)) {
                    warning ("no metadata.json in %s - ignoring", 
                             base_dir_filename);
                }
                else if (!load_metadata (metadata_filename, out metadata)) {
                    warning ("can't read %s - ignoring", 
                             metadata_filename);
                }
                else {
                    base_dir = base_dir_filename;
                    return true;
                }
            }
            base_dir = null;
            metadata = null;
            return false;
        }

        internal static RuleMetadata[] list () {
            SortedSet<string> names = new TreeSet<string> ();
            RuleMetadata[] rules = {};
            var dirs = Util.build_data_path ("rules");
            foreach (var dir in dirs) {
                Dir handle;
                try {
                    handle = Dir.open (dir);
                } catch (GLib.Error e) {
                    continue;
                }
                string? name;
                while ((name = handle.read_name ()) != null) {
                    var metadata_filename =
                        Path.build_filename (dir, name, "metadata.json");
                    RuleMetadata? metadata = null;
                    if (FileUtils.test (metadata_filename, FileTest.EXISTS) &&
                        load_metadata (metadata_filename, out metadata)) {
                        if (!(metadata.name in names)) {
                            metadata.name = name;
                            rules += metadata;
                        }
                    }
                }
            }
            return rules;
        }
    }
}
