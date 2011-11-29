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
    /**
     * Object representing a candidate in dictionaries.
     */
    public class Candidate : Object {
        string _text;
        string? _annotation;
        string? _output;

        /**
         * Base string value of the candidate.
         */
        public string text {
            get {
                return _text;
            }
            internal set {
                _text = value;
            }
        }

        /**
         * Optional annotation text to the candidate.
         */
        public string? annotation {
            get {
                return _annotation;
            }
        }

        /**
         * Output string shown instead of text.
         * This is used for numeric conversion feature.
         */
        public string output {
            get {
                return _output;
            }
            internal set {
                _output = value;
            }
        }

        /**
         * Returns a string representing the candidate.
         * @return a string representing the candidate
         */
        public string to_string () {
            if (_annotation != null) {
                return _text + ";" + _annotation;
            } else {
                return _text;
            }
        }

        /**
         * Create a new Candidate.
         *
         * @param text base string value of the candidate
         * @param annotation optional annotation text to the candidate
         * @param output optional output text used instead of text
         *
         * @return a new SkkCandidate
         */
        public Candidate (string text,
                          string? annotation = null,
                          string? output = null)
        {
            _text = text;
            _annotation = annotation;
            _output = output == null ? text : output;
        }

        /**
         * Create a new Candidate from a textual representation
         *
         * @param str a string representation of a candidate
         * (i.e. text and annotation are separated by ";").
         *
         * @return a new Candidate
         */
        public Candidate.from_string (string str) {
            var strv = str.split (";", 2);
            string t, a;
            if (strv.length == 2) {
                t = strv[0];
                a = strv[1];
            } else {
                t = str;
                a = null;
            }
            this (t, a);
        }
    }

    /**
     * Base abstract class of dictionaries.
     */
    public abstract class Dict : Object {
        protected Candidate[] split_candidates (string line) {
            var strv = line.strip ().slice (1, -1).split ("/");
            Candidate[] candidates = new Candidate[strv.length];
            for (int i = 0; i < strv.length; i++) {
                candidates[i] = new Candidate.from_string (strv[i]);
            }
            return candidates;
        }

        protected string join_candidates (Candidate[] candidates) {
            var strv = new string[candidates.length];
            for (int i = 0; i < candidates.length; i++) {
                strv[i] = candidates[i].to_string ();
            }
            return "/" + string.joinv ("/", strv) + "/";
        }

        /**
         * Reload the dictionary.
         */
        public abstract void reload () throws GLib.Error;

        /**
         * Lookup candidates in the dictionary.
         *
         * @param midasi a midasi (title) string to lookup
         * @param okuri whether to search okuri-ari entries or okuri-nasi entries
         *
         * @return an array of Candidate
         */
        public abstract Candidate[] lookup (string midasi, bool okuri = false);

        /**
         * Return an array of strings which matches midasi.
         *
         * @param midasi a midasi (title) string to lookup
         *
         * @return an array of strings
         */
        public abstract string[] complete (string midasi);

        /**
         * Flag to indicate whether the dictionary is read only.
         */
        public abstract bool read_only { get; }

        /**
         * Select a candidate in the dictionary.
         *
         * @param midasi a midasi (title) string
         * @param candidate an Candidate
         * @param okuri whether to select okuri-ari entries or okuri-nasi entries
         *
         * @return `true` if the dictionary is modified, `false` otherwise.
         */
        public virtual bool select_candidate (string midasi,
                                              Candidate candidate,
                                              bool okuri = false)
        {
            // FIXME: throw an error when the dictionary is read only
            return false;
        }

        /**
         * Purge a candidate in the dictionary.
         *
         * @param midasi a midasi (title) string
         * @param candidate an Candidate
         * @param okuri whether to purge okuri-ari entries or okuri-nasi entries
         *
         * @return `true` if the dictionary is modified, `false` otherwise.
         */
        public virtual bool purge_candidate (string midasi,
                                             Candidate candidate,
                                             bool okuri = false)
        {
            // FIXME: throw an error when the dictionary is read only
            return false;
        }

        /**
         * Save the dictionary on disk.
         */
        public virtual void save () throws GLib.Error {
            // FIXME: throw an error when the dictionary is read only
        }
    }

    /**
     * Null implementation of Dict.
     */
    public class EmptyDict : Dict {
        /**
         * {@inheritDoc}
         */
        public override void reload () throws GLib.Error {
        }

        /**
         * {@inheritDoc}
         */
        public override Candidate[] lookup (string midasi, bool okuri = false) {
            return new Candidate[0];
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
        public override bool read_only {
            get {
                return true;
            }
        }
    }
}
