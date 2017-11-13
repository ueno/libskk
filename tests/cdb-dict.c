#include <libskk/libskk.h>

static void
cdb_dict (void)
{
  GError *error = NULL;
  SkkCdbDict *dict = skk_cdb_dict_new (LIBSKK_CDB_DICT, "EUC-JP", &error);
  g_assert_no_error (error);

  gint len;
  SkkCandidate **candidates;
  gchar **completion;
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

  /* completion is always empty with CDB dict */
  completion = skk_dict_complete (SKK_DICT (dict), "か", &len);
  g_assert_cmpint (len, ==, 0);
  g_free (completion);

  error = NULL;
  skk_dict_save (SKK_DICT (dict), &error);
  g_assert_no_error (error);

  g_object_unref (dict);
}

int
main (int argc, char **argv)
{
  skk_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/cdb-dict", cdb_dict);
  return g_test_run ();
}
