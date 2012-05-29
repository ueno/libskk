#include <libskk/libskk.h>

static void
kana_kan (void)
{
  SkkKanaKanDict *dict;
  SkkKanaKanScoreMap *map;
  SkkKanaKanConverter *converter;
  GError *error;
  gchar *output;

  error = NULL;
  dict = skk_kana_kan_dict_new ("juman.dic", &error);
  g_assert_no_error (error);

  error = NULL;
  map = skk_kana_kan_score_map_new ("mk.model", dict, &error);
  g_assert_no_error (error);

  converter = skk_kana_kan_converter_new (dict, map);

  output = skk_kana_kan_converter_convert (converter, "かなかんじへんかんのれい");
  printf ("%s\n", output);
  g_free (output);

  output = skk_kana_kan_converter_convert (converter, "かなからかんじにへんかん");
  printf ("%s\n", output);
  g_free (output);

  g_object_unref (converter);
  g_object_unref (map);
  g_object_unref (dict);
}

int
main (int argc, char **argv) {
  g_type_init ();
  skk_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/kana-kan", kana_kan);
  return g_test_run ();
}
