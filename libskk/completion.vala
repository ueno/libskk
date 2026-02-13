using Gee;

namespace Skk {
    public abstract class CompletionSource : Object {
        public abstract string[] get_completions(string midasi);
        public int priority { get; set; }
    }

    public class DictCompletionSource : CompletionSource {
        private Dict dict;

        public DictCompletionSource(Dict dict, int priority) {
            this.dict = dict;
            this.priority = priority;
        }

        public override string[] get_completions(string midasi) {
            ArrayList<string> completions = new ArrayList<string>();
            string[] dict_completions = dict.complete(midasi);
            if (dict_completions != null && dict_completions.length > 0) {
                completions.add_all_array(dict_completions);
                completions.sort((a, b) => a.collate(b));
            }
            return completions.to_array();
        }
    }

    public class CompletionService {
        private Gee.List<CompletionSource> sources = new Gee.ArrayList<CompletionSource>();

        public CompletionService() {}

        public void add_source(Object source_object, int priority) {
            CompletionSource completion_source;
            if (source_object is Dict) {
                completion_source = new DictCompletionSource((Dict)source_object, priority);
            } else if (source_object is CompletionSource) {
                completion_source = (CompletionSource)source_object;
                completion_source.priority = priority;
            } else {
                warning("Unsupported source type: %s", source_object.get_type().name());
                return;
            }

            sources.add(completion_source);
            sources.sort((a, b) => b.priority - a.priority);
        }

        public string[] get_completions(string midasi) {
            var completions = new ArrayList<string>();
            var completion_set = new HashSet<string>();

            foreach (var source in sources) {
                var source_completions = source.get_completions(midasi);
                foreach (var completion in source_completions) {
                    if (completion_set.add(completion)) {
                        completions.add(completion);
                    }
                }
            }

            return completions.to_array();
        }
    }
}
