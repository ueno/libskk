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
    errordomain SkkServError {
        NOT_READABLE,
        INVALID_RESPONSE
    }

    /**
     * An implementation of Dict which talks the skkserv protocol.
     */
    public class SkkServ : Dict {
        SocketConnection? connection;
        uint8 buffer[4096];
        string host;
        uint16 port;

        /**
         * {@inheritDoc}
         */
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
            while (builder.str.index_of_char ('\n') < 0) {
                ssize_t len = connection.input_stream.read (buffer);
                if (len < 0) {
                    throw new SkkServError.NOT_READABLE ("read error");
                }
                else if (len == 0) {
                    break;
                }
                else if (len > 0) {
                    if (buffer[0] != '1') {
                        throw new SkkServError.INVALID_RESPONSE (
                            "invalid response code");
                    }
                    uint8[] _buffer = buffer[0:len];
                    builder.append ((string)_buffer);
                }
            }
            var index = builder.str.index_of_char ('\n');
            if (index < 0) {
                throw new SkkServError.INVALID_RESPONSE ("missing newline");
            }
            return builder.str[0:index];
        }

        /**
         * {@inheritDoc}
         */
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

        /**
         * {@inheritDoc}
         */
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
                    response[2:response.length]).split ("/");
            } catch (SkkServError e) {
                warning ("server completion failed %s", e.message);
                return new string[0];
            } catch (GLib.Error e) {
                warning ("server completion failed %s", e.message);
                return new string[0];
            }
        }

        /**
         * {@inheritDoc}
         */
        public override bool read_only {
            get {
                return true;
            }
        }

        EncodingConverter converter;

        /**
         * Create a new SkkServ.
         *
         * @param host host to connect
         * @param port port at the host
         * @param encoding encoding to convert text over network traffic
         *
         * @return a new SkkServ.
         * @throws GLib.Error if opening a connection is failed
         */
        public SkkServ (string host, uint16 port = 1178, string encoding = "EUC-JP") throws GLib.Error {
            this.host = host;
            this.port = port;
            this.converter = new EncodingConverter (encoding);
            reload ();
        }
    }
}
