#include <libskk/libskk.h>

static void
context (void)
{
  GError *error = NULL;
  SkkFileDict *dict = skk_file_dict_new ("/usr/share/skk/SKK-JISYO.S",
                                         "EUC-JP",
                                         &error);
  g_assert_no_error (error);

  SkkDict *dictionaries[1];
  dictionaries[0] = SKK_DICT (dict);
  SkkContext *context = skk_context_new (dictionaries, 1);
  gboolean retval;
  const gchar *output, *preedit;

  retval = skk_context_process_key_events (context, "a i r");
  g_assert (retval);

  output = skk_context_get_output (context);
  g_assert_cmpstr (output, ==, "あい");

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "r");

  skk_context_reset (context);
  retval = skk_context_process_key_events (context, "A");
  g_assert (retval);

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▽あ");

  retval = skk_context_process_key_events (context, "i");
  g_assert (retval);

  output = skk_context_get_output (context);
  g_assert_cmpstr (output, ==, "");

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▽あい");

  retval = skk_context_process_key_events (context, "SPC");
  g_assert (retval);

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▼愛");

  retval = skk_context_process_key_events (context, "\n");
  g_assert (retval);

  output = skk_context_get_output (context);
  g_assert_cmpstr (output, ==, "愛");

  skk_context_reset (context);

  retval = skk_context_process_key_events (context, "A U");

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▼合う");
}

int
main (int argc, char **argv) {
  g_type_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/context", context);
  return g_test_run ();
}
