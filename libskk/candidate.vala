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

        int _cursor_pos;
        /**
         * Current cursor position.
         */
        public int cursor_pos {
            get {
                return _cursor_pos;
            }
            set {
                assert (value >= 0 && value < _candidates.size);
                _cursor_pos = value;
            }
        }

        /**
         * Get the current candidate at the given index.
         *
         * @param index candidate position (-1 for the current cursor position)
         *
         * @return a Candidate
         */
        public new Candidate @get (int index = -1) {
            if (index < 0)
                index = _cursor_pos;
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
            _cursor_pos = -1;
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
            if (_candidates.size > 0) {
                _cursor_pos = 0;
            }
            notify_property ("cursor-pos");
            populated ();
        }

        /**
         * Create a new CandidateList.
         *
         * @param page_start page starting index of the candidate list
         * @param page_size page size of the candidate list
         *
         * @return a new CandidateList.
         */
        public CandidateList (uint page_start = 4, uint page_size = 7) {
            _page_start = (int) page_start;
            _page_size = (int) page_size;
        }

        /**
         * Move cursor to the previous candidate.
         *
         * @return `true` if cursor position has changed, `false` otherwise.
         */
        public bool cursor_up () {
            assert (_cursor_pos >= 0);
            if (_cursor_pos > 0) {
                _cursor_pos--;
                notify_property ("cursor-pos");
                return true;
            }
            return false;
        }

        /**
         * Move cursor to the next candidate.
         *
         * @return `true` if cursor position has changed, `false` otherwise
         */
        public bool cursor_down () {
            assert (_cursor_pos >= 0);
            if (_cursor_pos < _candidates.size - 1) {
                _cursor_pos++;
                notify_property ("cursor-pos");
                return true;
            }
            return false;
        }

        /**
         * Move cursor to the previous page.
         *
         * @return `true` if cursor position has changed, `false` otherwise
         */
        public bool page_up () {
            assert (_cursor_pos >= 0);
            if (_cursor_pos >= _page_start + _page_size) {
                _cursor_pos -= _page_size;
                _cursor_pos = (int) get_page_start_cursor_pos ();
                notify_property ("cursor-pos");
                return true;
            }
            return false;
        }

        /**
         * Move cursor to the next page.
         *
         * @return `true` if cursor position has changed, `false` otherwise
         */
        public bool page_down () {
            assert (_cursor_pos >= 0);
            if (_cursor_pos < _candidates.size - _page_size) {
                _cursor_pos += _page_size;
                _cursor_pos = (int) get_page_start_cursor_pos ();
                notify_property ("cursor-pos");
                return true;
            }
            return false;
        }

        /**
         * Move cursor forward.
         *
         * @return `true` if cursor position has changed, `false` otherwise
         */
        public bool next () {
            if (_cursor_pos < _page_start) {
                return cursor_down ();
            } else {
                return page_down ();
            }
        }

        /**
         * Move cursor backward.
         *
         * @return `true` if cursor position has changed, `false` otherwise
         */
        public bool previous () {
            if (_cursor_pos <= _page_start) {
                return cursor_up ();
            } else {
                return page_up ();
            }
        }

        int _page_start;
        public uint page_start {
            get {
                return (uint) _page_start;
            }
            set {
                _page_start = (int) value;
            }
        }

        int _page_size;
        public uint page_size {
            get {
                return (uint) _page_size;
            }
            set {
                _page_size = (int) value;
            }
        }

        public bool page_visible {
            get {
                return _cursor_pos >= _page_start;
            }
        }

        public uint get_page_start_cursor_pos () {
            var pages = (_cursor_pos - _page_start) / _page_size;
            return pages * _page_size + _page_start;
        }

        /**
         * Select the current candidate.
         */
        public void select (int index = -1) {
            if (index >= 0) {
                _cursor_pos = index;
                notify_property ("cursor-pos");
            }
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