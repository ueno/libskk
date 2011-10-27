#include <libskk/libskk.h>

static SkkContext *
create_context (void)
{
  GError *error = NULL;
  SkkFileDict *dict = skk_file_dict_new ("/usr/share/skk/SKK-JISYO.S",
                                         "EUC-JP",
                                         &error);
  g_assert_no_error (error);

  SkkDict *dictionaries[1];
  dictionaries[0] = SKK_DICT (dict);
  return skk_context_new (dictionaries, 1);
}

static void
context (void)
{
  SkkContext *context = create_context ();
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

  g_object_unref (context);
}

static void
input_mode (void)
{
  SkkContext *context;
  struct {
    SkkInputMode input_mode;
    const gchar *keys;
    SkkInputMode next_input_mode;
    const gchar *output;
  } transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "q", SKK_INPUT_MODE_KATAKANA, "" },
    { SKK_INPUT_MODE_HIRAGANA, "C-q", SKK_INPUT_MODE_HANKAKU_KATAKANA, "" },
    { SKK_INPUT_MODE_HIRAGANA, "l", SKK_INPUT_MODE_LATIN, "" },
    { SKK_INPUT_MODE_HIRAGANA, "L", SKK_INPUT_MODE_WIDE_LATIN, "" },
    { SKK_INPUT_MODE_KATAKANA, "q", SKK_INPUT_MODE_HIRAGANA, "" },
    { SKK_INPUT_MODE_KATAKANA, "C-q", SKK_INPUT_MODE_HANKAKU_KATAKANA, "" },
    { SKK_INPUT_MODE_KATAKANA, "l", SKK_INPUT_MODE_LATIN, "" },
    { SKK_INPUT_MODE_KATAKANA, "L", SKK_INPUT_MODE_WIDE_LATIN, "" },
    { SKK_INPUT_MODE_HANKAKU_KATAKANA, "q", SKK_INPUT_MODE_HIRAGANA, "" },
    { SKK_INPUT_MODE_HANKAKU_KATAKANA, "C-q", SKK_INPUT_MODE_HIRAGANA, "" },
    { SKK_INPUT_MODE_HANKAKU_KATAKANA, "l", SKK_INPUT_MODE_LATIN, "" },
    { SKK_INPUT_MODE_HANKAKU_KATAKANA, "L", SKK_INPUT_MODE_WIDE_LATIN, "" },
    { SKK_INPUT_MODE_LATIN, "C-j", SKK_INPUT_MODE_HIRAGANA, "" },
    { SKK_INPUT_MODE_HIRAGANA, "w w q", SKK_INPUT_MODE_KATAKANA, "っ" }
  };
  gint i;

  context = create_context ();
  for (i = 0; i < G_N_ELEMENTS (transitions); i++) {
    SkkInputMode input_mode;
    const gchar *output;
    skk_context_set_input_mode (context, transitions[i].input_mode);
    skk_context_process_key_events (context, transitions[i].keys);
    input_mode = skk_context_get_input_mode (context);
    g_assert_cmpint (input_mode, ==, transitions[i].next_input_mode);
    output = skk_context_get_output (context);
    g_assert_cmpstr (output, ==, transitions[i].output);
  }
  g_object_unref (context);
}

int
main (int argc, char **argv) {
  g_type_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/context", context);
  g_test_add_func ("/libskk/input-mode", input_mode);
  return g_test_run ();
}
