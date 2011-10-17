#include <libskk/libskk.h>

static void
context (void)
{
  SkkDict *dictionaries[1];
  dictionaries[0] = SKK_DICT (skk_empty_dict_new ());
  SkkContext *context = skk_context_new (dictionaries, 1);
  gboolean retval;
  const gchar *output, *preedit;

  retval = skk_context_append_text (context, "air");
  g_assert (retval);

  output = skk_context_get_output (context);
  g_assert_cmpstr (output, ==, "あい");

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "r");

  skk_context_reset (context);
  retval = skk_context_append_text (context, "Ai");

  output = skk_context_get_output (context);
  g_assert_cmpstr (output, ==, "");

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▽あい");
}

int
main (int argc, char **argv) {
  g_type_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/context", context);
  return g_test_run ();
}
