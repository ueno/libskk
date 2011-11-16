#include <libskk/libskk.h>
#include "common.h"

SkkContext *
create_context (void)
{
  SkkDict *dictionaries[1];
  SkkFileDict *file_dict;
  SkkUserDict *user_dict;
  GError *error;

  error = NULL;
  file_dict = skk_file_dict_new ("file-dict.dat", "EUC-JP", &error);
  g_assert_no_error (error);

  error = NULL;
  user_dict = skk_user_dict_new ("user-dict.dat", "EUC-JP", &error);
  g_assert_no_error (error);

  dictionaries[0] = SKK_DICT (file_dict);
  dictionaries[1] = SKK_DICT (user_dict);

  return skk_context_new (dictionaries, 2);
}

void
check_transitions (SkkContext    *context,
                   SkkTransition *transitions,
                   int            n_transitions)
{
  gint i;

  for (i = 0; i < n_transitions; i++) {
    const gchar *preedit, *output;
    SkkInputMode input_mode;
    skk_context_reset (context);
    skk_context_set_input_mode (context, transitions[i].input_mode);
    skk_context_process_key_events (context, transitions[i].keys);
    preedit = skk_context_get_preedit (context);
    g_assert_cmpstr (preedit, ==, transitions[i].preedit);
    output = skk_context_get_output (context);
    g_assert_cmpstr (output, ==, transitions[i].output);
    input_mode = skk_context_get_input_mode (context);
    g_assert_cmpint (input_mode, ==, transitions[i].next_input_mode);
  }
}
