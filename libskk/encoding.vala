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
namespace Skk {
    // XXX: we use Vala string to represent byte array, assuming that
    // it does not contain null element
    class EncodingConverter {
        static const int BUFSIZ = 4096;
        static const string INTERNAL_ENCODING = "UTF-8";

        internal string encoding { get; private set; }

        CharsetConverter encoder;
        CharsetConverter decoder;

        internal EncodingConverter (string encoding) throws GLib.Error {
            this.encoding = encoding;
            encoder = new CharsetConverter (encoding, INTERNAL_ENCODING);
            decoder = new CharsetConverter (INTERNAL_ENCODING, encoding);
        }

        string convert (CharsetConverter converter, string str)
            throws GLib.Error {
            uint8[] buf = new uint8[BUFSIZ];
            StringBuilder builder = new StringBuilder ();
            size_t bytes_read, bytes_written;
            converter.convert (str.data,
                               buf,
                               ConverterFlags.NO_FLAGS,
                               out bytes_read,
                               out bytes_written);
            for (int i = 0; i < bytes_written; i++)
                builder.append_c ((char)buf[i]);
            return builder.str;
        }

        internal string encode (string internal_str) throws GLib.Error {
            return convert (encoder, internal_str);
        }

        internal string decode (string external_str) throws GLib.Error {
            return convert (decoder, external_str);
        }
    }
}
