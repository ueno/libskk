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
    errordomain SkkFileDictParseError {
        FAILED
    }

    /**
     * A file based implementation of Dict.
     */
    public class FileDict : Dict {
        void remap () {
            if (memory != null) {
                Posix.munmap (memory, memory_length);
                memory = null;
            }

            int fd = Posix.open (file.get_path (), Posix.O_RDONLY, 0);
            return_if_fail (fd >= 0);

            Posix.Stat stat;
            int retval = Posix.fstat (fd, out stat);
            return_if_fail  (retval == 0);

            memory = Posix.mmap (null,
                                 stat.st_size,
                                 Posix.PROT_READ,
                                 Posix.MAP_SHARED,
                                 fd,
                                 0);
            return_if_fail (memory != Posix.MAP_FAILED);
            memory_length = stat.st_size;
        }

        // Read a line near offset and move offset to the beginning of
        // the line.  After the call, to fetch the previous line, do
        //
        //  offset -= 2; // place the cursor at the end of the previous line
        //  line = read_line (ref offset);
        //
        // to fetch the next line, do:
        //  offset += line.length + 1; // place the cursor at "\n"
        //  line = read_line (ref offset);
        string read_line (ref long offset) {
            return_val_if_fail (offset < memory_length, null);
            char *p = ((char *)memory + offset);
            for (; offset > 0; offset--, p--) {
                if (*p == '\n')
                    break;
            }

            if (offset > 0) {
                offset++;
                p++;
            }

            var builder = new StringBuilder ();
            long _offset = offset;
            for (; _offset < memory_length; _offset++, p++) {
                if (*p == '\n')
                    break;
                builder.append_c (*p);
            }
            return builder.str;
        }

        // Skip until the first occurrence of line.  This moves offset
        // at the beginning of the next line.
        bool read_until (ref long offset, string line) {
            return_val_if_fail (offset < memory_length, null);
            while (offset + line.length < memory_length) {
                char *p = ((char *)memory + offset);
                if (*p == '\n' &&
                    Memory.cmp (p + 1, (void *)line, line.length) == 0) {
                    offset += line.length;
                    return true;
                }
                offset++;
            }
            return false;
        }

        void load () throws GLib.IOError, SkkFileDictParseError {
            remap ();

            long offset = 0;
            if (!read_until (ref offset, ";; okuri-ari entries.\n")) {
                throw new SkkFileDictParseError.FAILED (
                    "no okuri-ari boundary");
            }
            okuri_ari_offset = offset;
            
            if (!read_until (ref offset, ";; okuri-nasi entries.\n")) {
                throw new SkkFileDictParseError.FAILED (
                    "no okuri-nasi boundary");
            }
            okuri_nasi_offset = offset;
        }

        /**
         * {@inheritDoc}
         */
        public override void reload () throws GLib.Error {
            FileInfo info = file.query_info (FILE_ATTRIBUTE_ETAG_VALUE,
                                             FileQueryInfoFlags.NONE);
            if (info.get_etag () != etag) {
                this.midasi_strings.clear ();
                try {
                    load ();
                    etag = info.get_etag ();
                } catch (SkkFileDictParseError e) {
                    warning ("error parsing file dictionary %s %s",
                             file.get_path (), e.message);
                }
            }
        }

        bool search_pos (string midasi,
                         long start_offset,
                         long end_offset,
                         CompareFunc<string> cmp,
                         out long pos,
                         out string? line,
                         int direction) {
            long offset = start_offset + (end_offset - start_offset) / 2;
            while (start_offset <= end_offset) {
                assert (offset < memory_length);

                string _line = read_line (ref offset);
                int index = _line.index_of (" ");
                if (index < 1) {
                    warning ("corrupted dictionary entry: %s", _line);
                    break;
                }

                int r = cmp (_line[0:index], midasi);
                if (r == 0) {
                    pos = offset;
                    line = _line;
                    return true;
                }

                if (r * direction > 0) {
                    end_offset = offset - 2;
                } else {
                    start_offset = offset + _line.length + 1;
                }
                offset = start_offset + (end_offset - start_offset) / 2;
            }
            pos = -1;
            line = null;
            return false;
        }

        /**
         * {@inheritDoc}
         */
        public override Candidate[] lookup (string midasi, bool okuri = false) {
            long start_offset, end_offset;
            if (okuri) {
                start_offset = okuri_ari_offset;
                end_offset = okuri_nasi_offset;
            } else {
                start_offset = okuri_nasi_offset;
                end_offset = (long) memory_length;
            }
            string _midasi;
            try {
                _midasi = converter.encode (midasi);
            } catch (GLib.Error e) {
                warning ("can't encode %s: %s", midasi, e.message);
                return new Candidate[0];
            }

            long pos;
            string line;
            if (search_pos (_midasi,
                            start_offset,
                            end_offset,
                            strcmp,
                            out pos,
                            out line,
                            okuri ? -1 : 1)) {
                int index = line.index_of (" ");
                string _line;
                if (index > 0) {
                    try {
                        _line = converter.decode (line[index:line.length]);
                    } catch (GLib.Error e) {
                        warning ("can't decode line %s: %s",
                                 line, e.message);
                        return new Candidate[0];
                    }
                    return split_candidates (_line);
                }
            }
            return new Candidate[0];
        }

        static int strcmp_prefix (string a, string b) {
            if (a.has_prefix (b))
                return 0;
            return strcmp (a, b);
        }

        /**
         * {@inheritDoc}
         */
        public override string[] complete (string midasi) {
            var completion = new ArrayList<string> ();

            long start_offset, end_offset;
            start_offset = okuri_nasi_offset;
            end_offset = (long) memory_length;

            string _midasi;
            try {
                _midasi = converter.encode (midasi);
            } catch (GLib.Error e) {
                warning ("can't decode %s: %s", midasi, e.message);
                return completion.to_array ();
            }

            long pos;
            string line;
            if (search_pos (_midasi,
                            start_offset,
                            end_offset,
                            strcmp_prefix,
                            out pos,
                            out line,
                            1)) {
                long _pos = pos + line.length + 1;
                while (pos >= 0 && line.has_prefix (_midasi)) {
                    int index = line.index_of (" ");
                    if (index < 0) {
                        warning ("corrupted dictionary entry: %s",
                                 line);
                    } else {
                        try {
                            completion.add (converter.decode (line[0:index]));
                        } catch (GLib.Error e) {
                            warning ("can't decode line %s: %s",
                                     line, e.message);
                            return completion.to_array ();
                        }
                    }
                    pos -= 2;
                    line = read_line (ref pos);
                }

                pos = _pos;
                line = read_line (ref pos);
                while (pos <= memory_length && line.has_prefix (_midasi)) {
                    int index = line.index_of (" ");
                    if (index < 0) {
                        warning ("corrupted dictionary entry: %s",
                                 line);
                    } else {
                        try {
                            completion.add (converter.decode (line[0:index]));
                        } catch (GLib.Error e) {
                            warning ("can't decode line %s: %s",
                                     line, e.message);
                            return completion.to_array ();
                        }
                    }
                    pos += line.length + 1;
                    line = read_line (ref pos);
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

        File file;
        string etag;
        EncodingConverter converter;
        void *memory = null;
        size_t memory_length = 0;
        long okuri_ari_offset;
        long okuri_nasi_offset;
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
            this.file = File.new_for_path (path);
            this.etag = "";
            this.converter = new EncodingConverter (encoding);
            reload ();
        }
    }
}
