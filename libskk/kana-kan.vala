// A naive kana-kanji converter based on:
// http://gihyo.jp/magazine/wdpress/archive/2011/vol64 (Japanese)
// dictionary and score map generation scripts can be found at:
// http://gihyo.jp/assets/files/magazine/wdpress/2011/64/WDB64-toku3-kanakan.zip
// See tests/kana-kan.c for example.

using Gee;

namespace Skk {
    public class KanaKanDict {
        HashMap<string,Set<string>> dict =
            new HashMap<string,Set<string>> ();
        public KanaKanDict (string path) {
            File file = File.new_for_path (path);
            DataInputStream input = new DataInputStream (file.read ());
            while (true) {
                size_t length;
                string? line = input.read_line (out length);
                if (line == null)
                    break;
                string[] a = line.chomp ().split ("\t");
                add (a[0], a[1]);
            }
        }

        public void add (string pron, string word) {
            if (!dict.has_key (pron)) {
                dict.set (pron, new HashSet<string> ());
            }
            dict.get (pron).add (word);
        }

        internal Set<string> lookup (string pron) {
            if (!dict.has_key (pron)) {
                return new HashSet<string> ();
            }
            return dict.get (pron);
        }
    }

    public class KanaKanScoreMap {
        Map<string,double?> map = new HashMap<string,double?> ();
        public KanaKanScoreMap (string path, KanaKanDict dict) {
            File file = File.new_for_path (path);
            DataInputStream input = new DataInputStream (file.read ());
            while (true) {
                size_t length;
                string? line = input.read_line (out length);
                if (line == null)
                    break;
                string[] a = line.chomp ().split ("\t\t");
                map.set (a[0], double.parse (a[1]));
                string[] b = a[0].split ("\t");
                if (b.length == 2 &&
                    b[0].has_prefix ("S") &&
                    b[1].has_prefix ("R")) {
                    var word = b[0].substring (1);
                    var pron = b[1].substring (1);
                    dict.add (pron, word);
                }
            }
        }

        double get_score (string feature) {
            if (map.has_key (feature))
                return map.get (feature);
            return 0.0;
        }

        internal double get_node_score (KanaKanNode node) {
            double score = 0.0;
            string feature;
            feature = "S%s\tR%s".printf (node.word, node.pron);
            score += get_score (feature);
            feature = "S%s".printf (node.word);
            score += get_score (feature);
            return score;
        }

        internal double get_edge_score (KanaKanNode prev_node, KanaKanNode node) {
            var feature = "S%s\tS%s".printf (prev_node.word, node.pron);
            return get_score (feature);
        }
    }

    class KanaKanNode {
        internal string word;
        internal string pron;
        internal int endpos;
        internal double score = 0.0;
        internal KanaKanNode? prev = null;

        internal KanaKanNode (string word, string pron, int endpos) {
            this.word = word;
            this.pron = pron;
            this.endpos = endpos;
        }

        internal int length {
            get {
                return pron.char_count ();
            }
        }

        internal bool is_bos () {
            return endpos == 0;
        }

        internal bool is_eos () {
            return length == 0 && endpos != 0;
        }
    }

    class KanaKanGraph {
        KanaKanDict dict;
        internal ArrayList<KanaKanNode>[] nodes;
        internal KanaKanNode bos;
        internal KanaKanNode eos;

        internal KanaKanGraph (KanaKanDict dict, string str) {
            this.dict = dict;
            UnicodeString ustr = new UnicodeString (str);
            nodes = new ArrayList<KanaKanNode>[ustr.length + 2];
            for (int i = 0; i < ustr.length + 2; i++) {
                nodes[i] = new ArrayList<KanaKanNode> ();
            }

            bos = new KanaKanNode ("", "", 0);
            nodes[0].add (bos);

            eos = new KanaKanNode ("", "", ustr.length + 1);
            nodes[ustr.length + 1].add (eos);

            for (int i = 0; i < ustr.length; i++) {
                for (int j = i + 1; j <= int.min (ustr.length, i + 16); j++) {
                    var pron = ustr.substring (i, j - i);
                    var words = dict.lookup (pron);
                    foreach (var word in words) {
                        var node = new KanaKanNode (word, pron, j);
                        nodes[j].add (node);
                    }
                }
                if (i < ustr.length) {
                    var pron = ustr.substring (i, 1);
                    var node = new KanaKanNode (pron, pron, i + 1);
                    nodes[i + 1].add (node);
                }
            }
        }

        internal ArrayList<KanaKanNode> get_prev_nodes (KanaKanNode node) {
            if (node.is_eos ()) {
                int startpos = node.endpos - 1;
                return nodes[startpos];
            } else if (node.is_bos ()) {
                return new ArrayList<KanaKanNode> ();
            } else {
                int startpos = node.endpos - node.length;
                return nodes[startpos];
            }
        }
    }

    public class KanaKanConverter {
        KanaKanDict dict;
        KanaKanScoreMap map;

        public KanaKanConverter (KanaKanDict dict, KanaKanScoreMap map) {
            this.dict = dict;
            this.map = map;
        }

        public string convert (string kana) {
            var graph = new KanaKanGraph (dict, kana);
            StringBuilder builder = new StringBuilder ();
            string[] words = viterbi (graph, map);
            foreach (var word in words) {
                builder.append (word);
            }
            return builder.str;
        }

        static string[] viterbi (KanaKanGraph graph, KanaKanScoreMap map) {
            foreach (var nodes in graph.nodes) {
                foreach (var node in nodes) {
                    if (node.is_bos ())
                        continue;
                    node.score = -1000000.0;
                    var node_score = map.get_node_score (node);
                    var prev_nodes = graph.get_prev_nodes (node);
                    foreach (var prev_node in prev_nodes) {
                        var score = prev_node.score + map.get_edge_score (prev_node, node) + node_score;
                        if (score >= node.score) {
                            node.score = score;
                            node.prev = prev_node;
                        }
                    }
                }
            }
            ArrayList<string> result = new ArrayList<string> ();
            var node = graph.eos.prev;
            while (!node.is_bos ()) {
                result.insert (0, node.word);
                node = node.prev;
            }
            return result.to_array ();
        }
    }
}
