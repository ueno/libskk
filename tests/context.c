#include <libskk/libskk.h>

static void
dictionary (void)
{
  SkkContext *context = create_context (TRUE, TRUE);
  SkkEmptyDict *dict = skk_empty_dict_new ();
  SkkDict **dictionaries;
  gint n_dictionaries;

  skk_context_add_dictionary (context, SKK_DICT (dict));

  dictionaries = skk_context_get_dictionaries (context, &n_dictionaries);
  g_assert_cmpint (n_dictionaries, ==, 4);
  skk_context_set_dictionaries (context, dictionaries, n_dictionaries);
  while (--n_dictionaries >= 0) {
    g_object_unref (dictionaries[n_dictionaries]);
  }
  g_free (dictionaries);

  skk_context_remove_dictionary (context, SKK_DICT (dict));

  g_object_unref (dict);

  destroy_context (context);
}

static void
basic (void)
{
  SkkContext *context = create_context (TRUE, TRUE);
  gboolean retval;
  const gchar *preedit;
  gchar *output;
  guint offset, nchars;

  retval = skk_context_process_key_events (context, "a i r");
  g_assert (retval);

  output = skk_context_peek_output (context);
  g_assert_cmpstr (output, ==, "あい");
  g_free (output);
  skk_context_clear_output (context);

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "r");

  skk_context_get_preedit_underline (context, &offset, &nchars);
  g_assert_cmpint (offset, ==, 0);
  g_assert_cmpint (nchars, ==, 0);

  skk_context_reset (context);
  skk_context_clear_output (context);
  retval = skk_context_process_key_events (context, "A");
  g_assert (retval);

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▽あ");

  retval = skk_context_process_key_events (context, "i");
  g_assert (retval);

  output = skk_context_poll_output (context);
  g_assert_cmpstr (output, ==, "");
  g_free (output);

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▽あい");

  retval = skk_context_process_key_events (context, "SPC");
  g_assert (retval);

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▼愛");

  retval = skk_context_process_key_events (context, "\n");
  g_assert (!retval);

  output = skk_context_poll_output (context);
  g_assert_cmpstr (output, ==, "愛");
  g_free (output);

  retval = skk_context_process_key_events (context, "\n");
  g_assert (!retval);

  skk_context_reset (context);
  skk_context_clear_output (context);

  retval = skk_context_process_key_events (context, "A U");

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▼合う");

  destroy_context (context);
}

int
main (int argc, char **argv) {
  g_type_init ();
  skk_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/context/dictionary",
                   dictionary);
  g_test_add_func ("/libskk/context/basic", basic);
  return g_test_run ();
}
