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
        unowned Posix.FILE get_fp (string mode = "r") {
            if (file == null)
                file = Posix.FILE.open (path, mode);
            return file;
        }

        static const int BUFSIZ = 4096;

        static const Entry<string,string> ENCODING_TO_CODING_SYSTEM_RULE[] = {
            { "UTF-8", "utf-8" },
            { "EUC-JP", "euc-jp" },
            { "Shift_JIS", "shift_jis" },
            { "ISO-2022-JP", "iso-2022-jp" }
        };

        void load () {
            // this will cause file close
            if (file != null)
                file = null;
            unowned Posix.FILE fp = get_fp ();
            char[] buf = new char[BUFSIZ];
            string? line = fp.gets (buf);
            if (line == null) {
                return;
            }
            MatchInfo info;
            if (coding_cookie_regex.match (line, 0, out info)) {
                string coding_system = info.fetch (1);
                foreach (var entry in ENCODING_TO_CODING_SYSTEM_RULE) {
                    if (entry.value == coding_system) {
                        try {
                            // override encoding with coding cookie
                            converter = new EncodingConverter (entry.key);
                        } catch (GLib.Error e) {
                        }
                        break;
                    }
                }
            }
            Map<string,ArrayList<Candidate>>? entries = null;
            while (true) {
                line = fp.gets (buf);
                if (line == null) {
                    break;
                }
                if (line.has_prefix (";; okuri-ari entries.")) {
                    entries = okuri_ari_entries;
                    break;
                }
            }
            if (entries != null) {
                while (true) {
                    line = fp.gets (buf);
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
                        continue;
                    }
                    int index = line.index_of (" ");
                    if (index > 0) {
                        string midasi = line[0:index];
                        var candidates = split_candidates (line[index:-1]);
                        var list = new ArrayList<Candidate> ();
                        foreach (var c in candidates) {
                            list.add (c);
                        }
                        entries.set (midasi, list);
                    }
                }
            }
        }

        public override void reload () {
            Posix.Stat buf;
            if (Posix.stat (path, out buf) < 0) {
                return;
            }

            if (buf.st_mtime > mtime) {
                this.okuri_ari_entries.clear ();
                this.okuri_nasi_entries.clear ();
                load ();
                this.mtime = buf.st_mtime;
            }
        }

        static int compare_entry (Map.Entry<string,ArrayList<Candidate>> a,
                                  Map.Entry<string,ArrayList<Candidate>> b) {
            return strcmp (a.key, b.key);
        }

        public override void save () {
            // this will cause file close
            if (file != null)
                file = null;
            unowned Posix.FILE fp = get_fp ("w+");
            foreach (var entry in ENCODING_TO_CODING_SYSTEM_RULE) {
                if (entry.key == converter.encoding) {
                    fp.printf (";;; -*- coding: %s -*-\n", entry.value);
                    break;
                }
            }
            fp.printf (";; okuri-ari entries.\n");
            var entries = new TreeSet<Map.Entry<string,ArrayList<Candidate>>> ((CompareFunc) compare_entry);
            entries.add_all (okuri_ari_entries.entries);
            if (!entries.is_empty) {
                var iter = entries.iterator_at (entries.last ());
                do {
                    var entry = iter.get ();
                    fp.printf ("%s %s\n",
                               entry.key,
                               join_candidates (entry.value.to_array ()));
                } while (iter.previous ());
            }
            fp.printf (";; okuri-nasi entries.\n");
            entries.clear ();
            entries.add_all (okuri_nasi_entries.entries);
            if (!entries.is_empty) {
                var iter = entries.iterator_at (entries.first ());
                do {
                    var entry = iter.get ();
                    fp.printf ("%s %s\n",
                               entry.key,
                               join_candidates (entry.value.to_array ()));
                } while (iter.next ());
            }
        }

        Map<string,ArrayList<Candidate>> get_entries (string midasi,
                                                      bool okuri = false) {
            if (okuri) {
                return okuri_ari_entries;
            } else {
                return okuri_nasi_entries;
            }
        }

        public override Candidate[] lookup (string midasi, bool okuri = false) {
            var entries = get_entries (midasi, okuri);
            if (entries.has_key (midasi)) {
                return entries.get (midasi).to_array ();
            } else {
                return new Candidate[0];
            }
        }

        public override string[] complete (string midasi) {
            return new string[0];
        }

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
            var entries = get_entries (midasi, okuri);
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

        public override bool purge_candidate (string midasi,
                                              Candidate candidate,
                                              bool okuri = false)
        {
            bool modified = false;
            var entries = get_entries (midasi, okuri);
            if (entries.has_key (midasi)) {
                var candidates = entries.get (midasi);
                if (candidates.size > 0) {
                    for (var iter = candidates.iterator ();
                         iter.has_next ();
                         iter.next ()) {
                        var c = iter.get ();
                        if (c.text == candidate.text) {
                            iter.remove ();
                            modified = true;
                        }
                    }
                }
            }
            return modified;
        }

        public override bool read_only {
            get {
                return false;
            }
        }

        string path;
        time_t mtime;
        EncodingConverter converter;
        Posix.FILE? file;
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
            this.mtime = 0;
            this.converter = new EncodingConverter (encoding);
            this.file = null;
            this.coding_cookie_regex =
                new Regex ("\\A\\s*;+\\s*-\\*-\\s*coding:\\s*(\\S+?)\\s*-\\*-");
            reload ();
        }
    }
}
