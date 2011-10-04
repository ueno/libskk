#include <libskk/libskk.h>

static void
file_dict (void)
{
  GError *error = NULL;
  SkkFileDict *dict = skk_file_dict_new ("/usr/share/skk/SKK-JISYO.S",
                                         "EUC-JP",
                                         &error);
  g_assert_no_error (error);

  gint len;
  SkkCandidate **candidates = skk_dict_lookup (SKK_DICT (dict),
                                               "かんじ",
                                               FALSE,
                                               &len);
  g_assert_cmpint (len, ==, 2);

  g_object_unref (dict);
}

int
main (int argc, char **argv)
{
  g_type_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/file-dict", file_dict);
  return g_test_run ();
}
