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
     * A file based implementation of Dict.
     */
    public class FileDict : Dict {
        unowned Posix.FILE get_fp (string mode = "r") {
            if (file == null)
                file = Posix.FILE.open (path, mode);
            return file;
        }

        static const int BUFSIZ = 4096;

        void load () {
            // this will cause file close
            if (file != null)
                file = null;
            unowned Posix.FILE fp = get_fp ();
            char[] buf = new char[BUFSIZ];
            ArrayList<long>? offsets = null;
            while (true) {
                long pos = fp.tell ();
                string line = fp.gets (buf);
                if (line == null) {
                    break;
                }
                if (line.has_prefix (";; okuri-ari entries.")) {
                    offsets = okuri_ari_offsets;
                    pos = fp.tell ();
                    break;
                }
            }
            if (offsets != null) {
                while (true) {
                    long pos = fp.tell ();
                    string line = fp.gets (buf);
                    if (line == null) {
                        break;
                    }
                    if (line.has_prefix (";; okuri-nasi entries.")) {
                        offsets = okuri_nasi_offsets;
                    } else {
                        if (offsets == okuri_nasi_offsets) {
                            int index = line.index_of (" ");
                            if (index > 0) {
                                try {
                                    midasi_strings.add (
                                        converter.decode (line[0:index]));
                                } catch (GLib.Error e) {
                                }
                            }
                            offsets.add (pos);
                        } else
                            offsets.insert (0, pos);
                    }
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        public override void reload () {
            Posix.Stat buf;
            if (Posix.stat (path, out buf) < 0) {
                return;
            }

            if (buf.st_mtime > mtime) {
                this.okuri_ari_offsets.clear ();
                this.okuri_nasi_offsets.clear ();
                this.midasi_strings.clear ();
                load ();
                this.mtime = buf.st_mtime;
            }
        }

        bool search_pos (string midasi,
                         ArrayList<long> offsets,
                         CompareFunc<string> cmp,
                         out long pos,
                         out string? line) {
            unowned Posix.FILE fp = get_fp ();
            char[] buf = new char[BUFSIZ];
            fp.seek (0, Posix.FILE.SEEK_SET);
            int begin = 0;
            int end = offsets.size - 1;
            int _pos = begin + (end - begin) / 2;
            while (begin <= end) {
                if (fp.seek (offsets.get (_pos), Posix.FILE.SEEK_SET) < 0)
                    break;

                string _line = fp.gets (buf);
                if (_line == null)
                    break;

                int index = _line.index_of (" ");
                if (index < 0)
                    break;

                int r = cmp (_line[0:index], midasi);
                if (r == 0) {
                    pos = _pos;
                    line = _line;
                    return true;
                } else if (r > 0) {
                    end = _pos - 1;
                } else {
                    begin = _pos + 1;
                }
                _pos = begin + (end - begin) / 2;
            }
            pos = -1;
            line = null;
            return false;
        }

        /**
         * {@inheritDoc}
         */
        public override Candidate[] lookup (string midasi, bool okuri = false) {
            ArrayList<long> offsets;
            if (okuri) {
                offsets = okuri_ari_offsets;
            } else {
                offsets = okuri_nasi_offsets;
            }
            if (offsets.size == 0) {
                reload ();
            }
            string _midasi;
            try {
                _midasi = converter.encode (midasi);
            } catch (GLib.Error e) {
                return new Candidate[0];
            }

            long pos;
            string line;
            if (search_pos (_midasi, offsets, strcmp, out pos, out line)) {
                int index = line.index_of (" ");
                string _line;
                if (index > 0) {
                    try {
                        _line = converter.decode (line[index:-1]);
                    } catch (GLib.Error e) {
                        return new Candidate[0];
                    }
                    return split_candidates (_line);
                }
            }
            return new Candidate[0];
        }

        /**
         * {@inheritDoc}
         */
        public override string[] complete (string midasi) {
            var completion = new ArrayList<string> ();
            foreach (var s in midasi_strings) {
                if (s.has_prefix (midasi)) {
                    completion.add (s);
                } else if (strcmp (s, midasi) > 0) {
                    break;
                }
            }
            return completion.to_array ();
        }

        /**
         * {@inheritDoc}
         */
        public override bool read_only {
            get {
                return true;
            }
        }

        string path;
        time_t mtime;
        EncodingConverter converter;
        Posix.FILE? file;
        ArrayList<long> okuri_ari_offsets = new ArrayList<long> ();
        ArrayList<long> okuri_nasi_offsets = new ArrayList<long> ();
        ArrayList<string> midasi_strings = new ArrayList<string> ();

        /**
         * Create a new FileDict.
         *
         * @param path a path to the file
         * @param encoding encoding of the file (default EUC-JP)
         *
         * @return a new FileDict
         * @throws GLib.Error if opening the file is failed
         */
        public FileDict (string path, string encoding = "EUC-JP") throws GLib.Error {
            this.path = path;
            this.mtime = 0;
            this.converter = new EncodingConverter (encoding);
            this.file = null;
            reload ();
        }
    }
}
