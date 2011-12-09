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
    errordomain RuleParseError {
        FAILED
    }

    class Rule : Object {
        Map<string,Map<string,Json.Node>> maps =
            new HashMap<string,Map<string,Json.Node>> ();

        static string[] build_path () {
            ArrayList<string> dirs = new ArrayList<string> ();
            string? path = Environment.get_variable ("LIBSKK_DATA_PATH");
            if (path != null) {
                string[] elements = path.split (":");
                foreach (var element in elements) {
                    dirs.add (Path.build_filename (element, "rules"));
                }
            }
            dirs.add (Path.build_filename (Config.PKGDATADIR, "rules"));
            return dirs.to_array ();
        }

        static string? locate (string[] path, string type, string name) {
            string? filename = null;
            foreach (var dir in path) {
                var _filename = Path.build_filename (dir, type, name + ".json");
                if (FileUtils.test (_filename, FileTest.EXISTS)) {
                    filename = _filename;
                    break;
                }
            }
            return filename;
        }

        void load_map (Map<string,Json.Node> map, Json.Object object) {
            var keys = object.get_members ();
            foreach (var key in keys) {
                var value = object.get_member (key);
                if (value.get_node_type () == Json.NodeType.NULL) {
                    map.unset (key);
                } else {
                    map.set (key, value);
                }
            }
        }

        static string get_dirname (string name) {
            var index = name.last_index_of ("/");
            if (index < 0) {
                return name;
            }
            return name[0:index];
        }

        void load (string[] path,
                   string type,
                   string name,
                   Set<string> included) throws RuleParseError
        {
            string? filename = locate (path, type, name);
            if (filename == null) {
                warning ("can't find rule %s under %s", name, type);
                return;
            }

            Json.Parser parser = new Json.Parser ();
            try {
                if (!parser.load_from_file (filename))
                    throw new RuleParseError.FAILED ("");
            } catch (GLib.Error e) {
                throw new RuleParseError.FAILED (
                    "%s".printf (e.message));
            }
            var root = parser.get_root ();
            if (root.get_node_type () != Json.NodeType.OBJECT) {
                throw new RuleParseError.FAILED (
                    "root element must be an object");
            }
            var object = root.get_object ();

            Json.Node member;
            if (object.has_member ("include")) {
                member = object.get_member ("include");
                if (member.get_node_type () != Json.NodeType.ARRAY) {
                    throw new RuleParseError.FAILED (
                        "\"include\" element must be an array");
                }
                var dirname = get_dirname (name);
                var include = member.get_array ();
                var elements = include.get_elements ();
                foreach (var element in elements) {
                    var parent = element.get_string ();
                    if (parent in included) {
                        throw new RuleParseError.FAILED (
                            "found circular include of %s", parent);
                    }
                    var index = parent.index_of ("/");
                    if (index < 0) {
                        load (path, type, dirname + "/" + parent, included);
                    } else {
                        load (path,
                              parent[0:index],
                              dirname + "/" + parent[index + 1:parent.length],
                              included);
                    }
                    included.add (parent);
                }
            }

            if (object.has_member ("define")) {
                member = object.get_member ("define");
                if (member.get_node_type () != Json.NodeType.OBJECT) {
                    throw new RuleParseError.FAILED (
                        "\"define\" element must be an object");
                }
                var define = member.get_object ();
                var keys = define.get_members ();
                foreach (var key in keys) {
                    if (!maps.has_key (key)) {
                        var map = new HashMap<string,Json.Node> ();
                        maps.set (key, map);
                    }
                    member = define.get_member (key);
                    if (member.get_node_type () != Json.NodeType.OBJECT) {
                        throw new RuleParseError.FAILED (
                            "map element must be an object");
                    }
                    load_map (maps.get (key), member.get_object ());
                }
            }
        }

        public Rule (string type, string name) throws RuleParseError {
            string[] path = build_path ();
            Set<string> included = new HashSet<string> ();
            load (path, type, name, included);
        }

        public bool has_map (string name) {
            return maps.has_key (name);
        }

        public new Map<string,Json.Node> @get (string name) {
            return maps.get (name);
        }
    }
}
