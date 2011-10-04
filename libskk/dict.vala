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
    public class Candidate : Object {
        string _text;
        string? _annotation;

        public string text {
            get {
                return _text;
            }
        }
        public string? annotation {
            get {
                return _annotation;
            }
        }

        public string to_string () {
            if (_annotation != null) {
                return _text + ";" + _annotation;
            } else {
                return _text;
            }
        }

        public Candidate (string text, string? annotation) {
            _text = text;
            _annotation = annotation;
        }

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
            return string.joinv ("/", strv);
        }

        public abstract void reload ();
        public abstract Candidate[] lookup (string midasi, bool okuri = false);
        // public abstract CandidateCompleter get_completer (string midasi);
    }

    public class EmptyDict : Dict {
        public override void reload () {
        }

        public override Candidate[] lookup (string midasi, bool okuri = false) {
            return new Candidate[0];
        }
    }
}
