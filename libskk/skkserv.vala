/*
 * Copyright (C) 2011-2012 Daiki Ueno <ueno@unixuser.org>
 * Copyright (C) 2011-2012 Red Hat, Inc.
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
    errordomain SkkServError {
        NOT_READABLE,
        INVALID_RESPONSE
    }

    /**
     * Network based Implementation of Dict.
     */
    public class SkkServ : Dict {
        SocketConnection? connection;
        uint8 buffer[4096];
        string host;
        uint16 port;

        void close_connection () {
            if (connection != null) {
                try {
                    buffer[0] = '0';
                    size_t bytes_written;
                    connection.output_stream.write_all (buffer[0:1],
                                                        out bytes_written);
                    connection.output_stream.flush ();
                    connection.close ();
                } catch (GLib.Error e) {
                    warning ("can't close skkserv: %s", e.message);
                }
                connection = null;
            }
        }

        /**
         * {@inheritDoc}
         */
        public override void reload () {
            close_connection ();
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
                    close_connection ();
                }
            } catch (GLib.Error e) {
                warning ("can't open skkserv at %s:%u: %s",
                         host, port, e.message);
                close_connection ();
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
                    // make sure to null terminate the string
                    char[] data = new char[len + 1];
                    Memory.copy (data, buffer, len);
                    data.length--;
                    builder.append ((string)data);
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
                return split_candidates (midasi,
                                         okuri,
                                         converter.decode (
                                             response[1:response.length]));
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
                    response[2:-1]).split ("/");
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

        ~SkkServ () {
            close_connection ();
        }
    }
}
