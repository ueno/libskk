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
    /**
     * A file based implementation of Dict used for user dictionary.
     */
    public class UserDict : Dict {
        static const Entry<string,string> ENCODING_TO_CODING_SYSTEM_RULE[] = {
            { "UTF-8", "utf-8" },
            { "EUC-JP", "euc-jp" },
            { "Shift_JIS", "shift_jis" },
            { "ISO-2022-JP", "iso-2022-jp" }
        };

        void load () {
            var memory = new MemoryInputStream ();
            uint8[] contents;
            try {
                file.load_contents (null, out contents, out etag);
                memory.add_data (contents, null);
            } catch (GLib.Error e) {
                contents = null;
                etag = "";
            }
            var data = new DataInputStream (memory);

            size_t length;
            var line = data.read_line (out length);

            MatchInfo info = null;
            if (line != null && coding_cookie_regex.match (line, 0, out info)) {
                string coding_system = info.fetch (1);
                foreach (var entry in ENCODING_TO_CODING_SYSTEM_RULE) {
                    if (entry.value == coding_system) {
                        try {
                            // override encoding with coding cookie
                            converter = new EncodingConverter (entry.key);
                        } catch (GLib.Error e) {
                            warning ("can't create encoder for %s: %s",
                                     entry.key, e.message);
                        }
                        break;
                    }
                }
            }

            Map<string,ArrayList<Candidate>>? entries = null;
            while (line != null) {
                line = data.read_line (out length);
                if (line == null) {
                    break;
                }
                if (line.has_prefix (";; okuri-ari entries.")) {
                    entries = okuri_ari_entries;
                    break;
                }
            }
            if (entries != null) {
                while (line != null) {
                    line = data.read_line (out length);
                    if (line == null) {
                        break;
                    }
                    if (line.has_prefix (";; okuri-nasi entries.")) {
                        entries = okuri_nasi_entries;
                        continue;
                    }
                    try {
                        line = converter.decode (line);
                    } catch (GLib.Error e) {
                        warning ("can't decode line %s: %s", line, e.message);
                        continue;
                    }
                    int index = line.index_of (" ");
                    if (index < 1) {
                        warning ("can't extract midasi from line %s",
                                 line);
                        continue;
                    }

                    string midasi = line[0:index];
                    string candidates_str = line[index + 1:line.length];
                    if (!candidates_str.has_prefix ("/") ||
                        !candidates_str.has_suffix ("/")) {
                        warning ("can't parse candidates list %s",
                                 candidates_str);
                        continue;
                    }

                    var candidates = split_candidates (candidates_str);
                    var list = new ArrayList<Candidate> ();
                    foreach (var c in candidates) {
                        list.add (c);
                    }
                    entries.set (midasi, list);
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        public override void reload () {
            FileInfo? info = null;
            try {
                info = file.query_info (FILE_ATTRIBUTE_ETAG_VALUE,
                                        FileQueryInfoFlags.NONE);
            } catch (GLib.Error e) {
            }

            if (info == null || info.get_etag () != etag) {
                this.okuri_ari_entries.clear ();
                this.okuri_nasi_entries.clear ();
                load ();
            }
        }

        static int compare_entry (Map.Entry<string,ArrayList<Candidate>> a,
                                  Map.Entry<string,ArrayList<Candidate>> b) {
            return strcmp (a.key, b.key);
        }

        /**
         * {@inheritDoc}
         */
        public override void save () {
            var builder = new StringBuilder ();
            foreach (var entry in ENCODING_TO_CODING_SYSTEM_RULE) {
                if (entry.key == converter.encoding) {
                    builder.append (";;; -*- coding: %s -*-\n".printf (entry.value));
                    break;
                }
            }
            builder.append (";; okuri-ari entries.\n");
            var entries = new TreeSet<Map.Entry<string,ArrayList<Candidate>>> ((CompareFunc) compare_entry);
            entries.add_all (okuri_ari_entries.entries);
            if (!entries.is_empty) {
                var iter = entries.iterator_at (entries.last ());
                do {
                    var entry = iter.get ();
                    var line = "%s %s\n".printf (
                        entry.key,
                        join_candidates (entry.value.to_array ()));
                    builder.append (line);
                } while (iter.previous ());
            }
            builder.append (";; okuri-nasi entries.\n");
            entries.clear ();
            entries.add_all (okuri_nasi_entries.entries);
            if (!entries.is_empty) {
                var iter = entries.iterator_at (entries.first ());
                do {
                    var entry = iter.get ();
                    var line = "%s %s\n".printf (
                        entry.key,
                        join_candidates (
                            entry.value.to_array ()));
                    builder.append (line);
                } while (iter.next ());
            }
            try {
                var contents = converter.encode (builder.str);
                file.replace_contents (contents,
                                       contents.length,
                                       etag,
                                       false,
                                       FileCreateFlags.NONE,
                                       out etag);
            } catch (GLib.Error e) {
            }
        }

        Map<string,ArrayList<Candidate>> get_entries (bool okuri = false) {
            if (okuri) {
                return okuri_ari_entries;
            } else {
                return okuri_nasi_entries;
            }
        }

        /**
         * {@inheritDoc}
         */
        public override Candidate[] lookup (string midasi, bool okuri = false) {
            var entries = get_entries (okuri);
            if (entries.has_key (midasi)) {
                return entries.get (midasi).to_array ();
            } else {
                return new Candidate[0];
            }
        }

        /**
         * {@inheritDoc}
         */
        public override string[] complete (string midasi) {
            return new string[0];
        }

        /**
         * {@inheritDoc}
         */
        public override bool select_candidate (string midasi,
                                               Candidate candidate,
                                               bool okuri = false)
        {
            int index;

            // update midasi history
            for (index = 0;
                 index < midasi_history.length && midasi_history[index] != null;
                 index++) {
                if (midasi_history[index] == midasi) {
                    if (index > 0) {
                        var first = midasi_history[0];
                        midasi_history[0] = midasi_history[index];
                        midasi_history[index] = first;
                        break;
                    }
                }
            }
            if (index == midasi_history.length ||
                midasi_history[index] == null) {
                for (int j = 1; j < index - 1; j++) {
                    midasi_history[j] = midasi_history[j - 1];
                }
            }
            midasi_history[0] = midasi;

            // update candidates list associated with midasi
            var entries = get_entries (okuri);
            if (!entries.has_key (midasi)) {
                entries.set (midasi, new ArrayList<Candidate> ());
            }
            index = 0;
            var candidates = entries.get (midasi);
            foreach (var c in candidates) {
                if (c.text == candidate.text) {
                    if (index > 0) {
                        var first = candidates[index];
                        candidates[0] = candidates[index];
                        candidates[index] = first;
                        return true;
                    }
                    return false;
                }
                index++;
            }
            candidates.insert (0, candidate);
            return true;
        }

        /**
         * {@inheritDoc}
         */
        public override bool purge_candidate (string midasi,
                                              Candidate candidate,
                                              bool okuri = false)
        {
            bool modified = false;
            var entries = get_entries (okuri);
            if (entries.has_key (midasi)) {
                var candidates = entries.get (midasi);
                if (candidates.size > 0) {
                    var iter = candidates.iterator ();
                    iter.first ();
                    do {
                        var c = iter.get ();
                        if (c.text == candidate.text) {
                            iter.remove ();
                            modified = true;
                        }
                    } while (iter.next ());
                    if (candidates.size == 0) {
                        entries.unset (midasi);
                    }
                }
            }
            return modified;
        }

        /**
         * {@inheritDoc}
         */
        public override bool read_only {
            get {
                return false;
            }
        }

        string path;
        EncodingConverter converter;
        File file;
        string etag;
        Map<string,ArrayList<Candidate>> okuri_ari_entries =
            new HashMap<string,ArrayList<Candidate>> ();
        Map<string,ArrayList<Candidate>> okuri_nasi_entries =
            new HashMap<string,ArrayList<Candidate>> ();
        Regex coding_cookie_regex;
        string midasi_history[128];

        /**
         * Create a new UserDict.
         *
         * @param path a path to the file
         * @param encoding encoding of the file (default UTF-8)
         *
         * @return a new UserDict
         * @throws GLib.Error if opening the file is failed
         */
        public UserDict (string path, string encoding) throws GLib.Error {
            this.path = path;
            this.converter = new EncodingConverter (encoding);
            this.file = File.new_for_path (path);
            this.coding_cookie_regex =
                new Regex ("\\A\\s*;+\\s*-\\*-\\s*coding:\\s*(\\S+?)\\s*-\\*-");
            reload ();
        }
    }
}
