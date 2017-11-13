#include <libskk/libskk.h>

static void
file_dict (void)
{
  GError *error = NULL;
  SkkFileDict *dict = skk_file_dict_new (LIBSKK_FILE_DICT, "EUC-JP", &error);
  g_assert_no_error (error);

  gint len;
  SkkCandidate **candidates;
  gboolean read_only;

  g_assert (skk_dict_get_read_only (SKK_DICT (dict)));
  g_object_get (dict, "read-only", &read_only, NULL);
  g_assert (read_only);

  candidates = skk_dict_lookup (SKK_DICT (dict),
                                "かんじ",
                                FALSE,
                                &len);
  g_assert_cmpint (len, ==, 2);
  while (--len >= 0) {
    g_object_unref (candidates[len]);
  }
  g_free (candidates);

  candidates = skk_dict_lookup (SKK_DICT (dict),
                                "あu",
                                TRUE,
                                &len);
  g_assert_cmpint (len, ==, 4);
  while (--len >= 0) {
    g_object_unref (candidates[len]);
  }
  g_free (candidates);

  g_object_unref (dict);
}

int
main (int argc, char **argv)
{
  skk_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/file-dict", file_dict);
  return g_test_run ();
}
