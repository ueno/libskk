/*
 * Copyright (C) 2011 Daiki Ueno <ueno@unixuser.org>
 * Copyright (C) 2011 Red Hat, Inc.
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
using Gee;

namespace Skk {
    /**
     * Object representing a candidate in dictionaries.
     */
    public class Candidate : Object {
        /**
         * Midasi word which generated this candidate.
         */
        public string midasi { get; private set; }

        /**
         * Flag to indicate whether this candidate is generated as a
         * result of okuri-ari conversion.
         */
        public bool okuri { get; private set; }

        /**
         * Base string value of the candidate.
         */
        public string text { get; set; }

        /**
         * Optional annotation text associated with the candidate.
         */
        public string? annotation { get; set; }

        /**
         * Output string shown instead of text.
         *
         * This is particularly useful to display a candidate of
         * numeric conversion.
         */
        public string output { get; set; }

        /**
         * Convert the candidate to string.
         * @return a string representing the candidate
         */
        public string to_string () {
            if (annotation != null) {
                return text + ";" + annotation;
            } else {
                return text;
            }
        }

        /**
         * Create a new Candidate.
         *
         * @param midasi midasi (index) word which generate the candidate
         * @param okuri whether the candidate is a result of okuri-ari conversion
         * @param text base string value of the candidate
         * @param annotation optional annotation text to the candidate
         * @param output optional output text used instead of text
         *
         * @return a new SkkCandidate
         */
        public Candidate (string midasi,
                          bool okuri,
                          string text,
                          string? annotation = null,
                          string? output = null)
        {
            this.midasi = midasi;
            this.okuri = okuri;
            this.text = text;
            this.annotation = annotation;
            this.output = output == null ? text : output;
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

        Set<string> seen = new HashSet<string> ();

        internal void clear () {
            _candidates.clear ();
            if (cursor_pos != -1) {
                cursor_pos = -1;
            }
            seen.clear ();
        }

        internal void add_candidates_start () {
            clear ();
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