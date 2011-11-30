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
     * Object maintaining the current candidates.
     */
    public class CandidateList : Object {
        ArrayList<Candidate> _candidates = new ArrayList<Candidate> ();

        /**
         * Current cursor position.
         *
         * This will be set to -1 if the candidate list is not active.
         */
        public int cursor_pos { get; set; }

        /**
         * Get the current candidate at the given index.
         *
         * @param index candidate position (-1 for the current cursor position)
         *
         * @return a Candidate
         */
        public new Candidate @get (int index = -1) {
            if (index < 0)
                index = cursor_pos;
            assert (0 <= index && index < size);
            return _candidates.get (index);
        }

        /**
         * The number of candidate in the candidate list.
         */
        public int size {
            get {
                return _candidates.size;
            }
        }

        /**
         * Whether this candidate list is generated as a result of
         * okuri-ari conversion.
         */
        public bool okuri { get; private set; }

        Set<string> seen = new HashSet<string> ();

        internal void clear () {
            _candidates.clear ();
            cursor_pos = -1;
            seen.clear ();
        }

        internal void add_candidates_start (bool okuri) {
            clear ();
            this.okuri = okuri;
        }

        internal void add_candidates (Candidate[] array) {
            foreach (var c in array) {
                if (!(c.output in seen)) {
                    _candidates.add (c);
                    seen.add (c.output);
                }
            }
        }

        internal void add_candidates_end () {
            populated ();
        }

        /**
         * Create a new CandidateList.
         *
         * @return a new CandidateList.
         */
        public CandidateList () {
            Object ();
        }

        /**
         * Select the current candidate.
         */
        public void select () {
            Candidate candidate = this.get ();
            selected (candidate);
        }

        /**
         * Signal emitted when candidates are filled and ready for traversal.
         */
        public signal void populated ();

        /**
         * Signal emitted when a candidate is selected.
         *
         * @param candidate selected candidate
         */
        public signal void selected (Candidate candidate);
    }
}