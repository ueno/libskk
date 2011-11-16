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
    public errordomain SkkServError {
        INVALID_RESPONSE
    }

    public class SkkServ : Dict {
        SocketConnection? connection;
        uint8 buffer[4096];
        string host;
        uint16 port;

        public override void reload () {
            // this will cause connection close
            if (connection != null)
                connection = null;
            try {
                var client = new SocketClient ();
                connection = client.connect_to_host (host, port);
                buffer[0] = '2';
                size_t bytes_written;
                connection.output_stream.write_all (buffer[0:1],
                                                    out bytes_written);
                connection.output_stream.flush ();
                ssize_t len = connection.input_stream.read (buffer);
                if (len <= 0) {
                    connection = null;
                }
            } catch (GLib.Error e) {
                connection = null;
            }
        }

        string read_response () throws SkkServError, GLib.IOError {
            StringBuilder builder = new StringBuilder ();
            // skksearch does not terminate the line with LF on
            // error (Issue#30)
            while (builder.str.last_index_of_char ('\n') < 0) {
                ssize_t len = connection.input_stream.read (buffer);
                // skksearch does not terminate the line with LF on
                // error (Issue#30)
                if (len > 0 && buffer[0] != '1') {
                    throw new SkkServError.INVALID_RESPONSE ("");
                }
                builder.append ((string)buffer[0:len]);
            }
            return builder.str;
        }

        public override Candidate[] lookup (string midasi, bool okuri = false) {
            if (connection == null)
                return new Candidate[0];
            string _midasi;
            try {
                _midasi = converter.encode (midasi);
            } catch (GLib.Error e) {
                return new Candidate[0];
            }
            try {
                size_t bytes_written;
                connection.output_stream.write_all (
                    "1%s ".printf (_midasi).data, out bytes_written);
                connection.output_stream.flush ();
                var response = read_response ();
                if (response.length == 0)
                    return new Candidate[0];
                return split_candidates (
                    converter.decode (response[1:response.length]));
            } catch (SkkServError e) {
                return new Candidate[0];
            } catch (GLib.Error e) {
                return new Candidate[0];
            }
        }

        public override string[] complete (string midasi) {
            if (connection == null)
                return new string[0];
            string _midasi;
            try {
                _midasi = converter.encode (midasi);
            } catch (GLib.Error e) {
                return new string[0];
            }
            try {
                size_t bytes_written;
                connection.output_stream.write_all (
                    "4%s ".printf (_midasi).data, out bytes_written);
                connection.output_stream.flush ();
                var response = read_response ();
                if (response.length < 2)
                    return new string[0];
                return converter.decode (
                    response[2:response.length]).split (" ");
            } catch (SkkServError e) {
                return new string[0];
            } catch (GLib.Error e) {
                return new string[0];
            }
        }

        public override bool read_only {
            get {
                return true;
            }
        }

        EncodingConverter converter;

        public SkkServ (string host, uint16 port = 1178, string encoding = "EUC-JP") throws GLib.Error {
            this.host = host;
            this.port = port;
            this.converter = new EncodingConverter (encoding);
            reload ();
        }
    }
}
