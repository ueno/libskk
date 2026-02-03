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
namespace Skk {
    /**
     * CDB based implementation of Dict.
     */
    public class CdbDict : Dict {
        static uint32 hash (char[] chars) {
            uint32 h = 5381;
            foreach (var c in chars) {
                h = ((h << 5) + h) ^ ((uint8) c);
            }
            return h;
        }

        /**
         * {@inheritDoc}
         */
        public override void reload () throws GLib.Error {
#if VALA_0_16
            string attributes = FileAttribute.ETAG_VALUE;
#else
            string attributes = FILE_ATTRIBUTE_ETAG_VALUE;
#endif
            FileInfo info = file.query_info (attributes,
                                             FileQueryInfoFlags.NONE);
            if (info.get_etag () != etag) {
                try {
                    mmap.remap ();
                    etag = info.get_etag ();
                } catch (SkkDictError e) {
                    warning ("error loading file dictionary %s %s",
                             file.get_path (), e.message);
                }
            }
        }

        static uint32 read_uint32 (uint8 *p) {
            // Make sure that Q does not stride across 4-byte
            // alignment on ARM (Debian bug#674471).
            uint8 q[4] = (uint8[]) p;
            return (q[3] << 24) | (q[2] << 16) | (q[1] << 8) | q[0];
        }

        /**
         * {@inheritDoc}
         */
        public override Candidate[] lookup (string midasi, bool okuri = false) {
            if (mmap.memory == null)
                return new Candidate[0];

            string _midasi;
            try {
                _midasi = converter.encode (midasi);
            } catch (GLib.Error e) {
                warning ("can't encode %s: %s", midasi, e.message);
                return new Candidate[0];
            }

            uint32 h = hash (_midasi.to_utf8 ());
            uint8 *p = (uint8 *) mmap.memory + (h % 256) * 8;
            uint32 hash_offset = read_uint32 (p);
            uint32 hash_length = read_uint32 (p + 4);

            uint32 start = (h >> 8) % hash_length;
            p = (uint8 *) mmap.memory + hash_offset;
            for (var i = 0; i < hash_length; i++) {
                uint8 *q = p + 8 * ((i + start) % hash_length);
                uint32 _h = read_uint32 (q);
                uint32 record_offset = read_uint32 (q + 4);
                if (record_offset == 0)
                    break;
                if (_h == h) {
                    uint8 *r = (uint8 *) mmap.memory + record_offset;
                    uint32 key_length = read_uint32 (r);
                    uint32 data_length = read_uint32 (r + 4);
                    if (Memory.cmp (r + 8, _midasi, key_length) == 0) {
                        char[] data = new char[data_length + 1];
                        Memory.copy (data, r + 8 + key_length, data_length);
                        data.length--;
                        string _data;
                        try {
                            _data = converter.decode ((string) data);
                        } catch (GLib.Error e) {
                            warning ("can't decode data %s: %s",
                                     (string) data, e.message);
                            break;
                        }
                        return split_candidates (midasi, okuri, _data);
                    }
                }
            }
            return new Candidate[0];
        }

        /**
         * {@inheritDoc}
         *
         * This always returns an empty array since CDB format does
         * not provide key enumeration.
         */
        public override string[] complete (string midasi) {
            return new string[0];
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
        MemoryMappedFile mmap;
        string etag;
        EncodingConverter converter;

        /**
         * Create a new CdbDict.
         *
         * @param path a path to the file
         * @param encoding encoding of the file (default EUC-JP)
         *
         * @return a new FileDict
         * @throws GLib.Error if opening the file is failed
         */
        public CdbDict (string path,
                        string encoding = "EUC-JP") throws GLib.Error
        {
            this.file = File.new_for_path (path);
            this.mmap = new MemoryMappedFile (file);
            this.etag = "";
            this.converter = new EncodingConverter (encoding);
            reload ();
        }
    }
}

