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
     * SkkCandidate:
     *
     * Candidate word in dictionaries.
     */
    public class Candidate : Object {
        string _text;
        string? _annotation;

        /**
         * SkkCandidate:text:
         *
         * Base string value of the candidate.
         */
        public string text {
            get {
                return _text;
            }
        }

        /**
         * SkkCandidate:annotation:
         *
         * Optional annotation text to the candidate.
         */
        public string? annotation {
            get {
                return _annotation;
            }
        }

        /**
         * skk_candidate_to_string:
         * @self: an #SkkCandidate
         *
         * Returns a string representing the candidate.
         */
        public string to_string () {
            if (_annotation != null) {
                return _text + ";" + _annotation;
            } else {
                return _text;
            }
        }

        /**
         * skk_candidate_new:
         * @text: base string value of the candidate
         * @annotation: optional annotation text to the candidate
         *
         * Create a new #SkkCandidate.
         */
        public Candidate (string text, string? annotation) {
            _text = text;
            _annotation = annotation;
        }

        /**
         * skk_candidate_new_from_string:
         * @str: a string representation of a candidate
         *
         * Create a new #SkkCandidate from a text representation
         * (i.e. text and annotation are separated by ";").
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
     * SkkDict:
     *
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
         * skk_dict_reload:
         * @self: an #SkkDict
         *
         * Reload the dictionary.
         */
        public abstract void reload ();

        /**
         * skk_dict_lookup:
         * @self: an #SkkDict
         * @midasi: a midasi (title) string to lookup
         * @okuri: whether to search okuri-ari entries or okuri-nasi entries
         *
         * Lookup candidates in the dictionary.
         * Returns: an array of #SkkCandidate
         */
        public abstract Candidate[] lookup (string midasi, bool okuri = false);
        // public abstract CandidateCompleter get_completer (string midasi);

        public abstract bool read_only { get; }

        /**
         * skk_dict_select_candidate:
         * @self: an #SkkDict
         * @midasi: a midasi (title) string
         * @candidate: an #SkkCandidate
         * @okuri: whether to select okuri-ari entries or okuri-nasi entries
         *
         * Select a candidate in the dictionary.
         * Returns: %TRUE if the dictionary is modified, %FALSE otherwise.
         */
        public virtual bool select_candidate (string midasi,
                                              Candidate candidate,
                                              bool okuri = false)
        {
            // FIXME: throw an error when the dictionary is read only
            return false;
        }

        /**
         * skk_dict_purge_candidate:
         * @self: an #SkkDict
         * @midasi: a midasi (title) string
         * @candidate: an #SkkCandidate
         * @okuri: whether to purge okuri-ari entries or okuri-nasi entries
         *
         * Purge a candidate in the dictionary.
         * Returns: %TRUE if the dictionary is modified, %FALSE otherwise.
         */
        public virtual bool purge_candidate (string midasi,
                                             Candidate candidate,
                                             bool okuri = false)
        {
            // FIXME: throw an error when the dictionary is read only
            return false;
        }

        /**
         * skk_dict_save:
         * @self: an #SkkDict
         *
         * Update the dictionary on disk.
         */
        public virtual void save () {
            // FIXME: throw an error when the dictionary is read only
        }
    }

    /**
     * SkkEmptyDict:
     *
     * Null implementation of #SkkDict.
     */
    public class EmptyDict : Dict {
        public override void reload () {
        }

        public override Candidate[] lookup (string midasi, bool okuri = false) {
            return new Candidate[0];
        }

        public override bool read_only {
            get {
                return true;
            }
        }
    }
}
