#include <unistd.h>
#include <libskk/libskk.h>
#include "common.h"

SkkContext *
create_context (gboolean use_user_dict,
                gboolean use_file_dict)
{
  SkkDict *dictionaries[3];
  gint n_dictionaries = 0;
  SkkEmptyDict *empty_dict;
  SkkUserDict *user_dict = NULL;
  SkkFileDict *file_dict = NULL;
  SkkContext *context;
  GError *error;

  error = NULL;
  empty_dict = skk_empty_dict_new ();
  g_assert_no_error (error);
  dictionaries[n_dictionaries++] = SKK_DICT (empty_dict);
  
  if (use_user_dict) {
    error = NULL;
    user_dict = skk_user_dict_new ("user-dict.dat", "EUC-JP", &error);
    g_assert_no_error (error);
    dictionaries[n_dictionaries++] = SKK_DICT (user_dict);
  }

  if (use_file_dict) {
    error = NULL;
    file_dict = skk_file_dict_new (LIBSKK_FILE_DICT, "EUC-JP", &error);
    g_assert_no_error (error);
    dictionaries[n_dictionaries++] = SKK_DICT (file_dict);
  }

  context = skk_context_new (dictionaries, n_dictionaries);

  g_object_unref (empty_dict);
  if (user_dict)
    g_object_unref (user_dict);
  if (file_dict)
    g_object_unref (file_dict);

  return context;
}

void
destroy_context (SkkContext *context)
{
  unlink ("user-dict.dat");
  g_object_unref (context);
}

void
check_transitions (SkkContext    *context,
                   SkkTransition *transitions,
                   int            n_transitions)
{
  gint i;

  for (i = 0; i < n_transitions; i++) {
    const gchar *preedit;
    gchar *output;
    SkkInputMode input_mode;
    skk_context_reset (context);
    output = skk_context_poll_output (context);
    g_free (output);

    skk_context_set_input_mode (context, transitions[i].input_mode);
    skk_context_process_key_events (context, transitions[i].keys);
    preedit = skk_context_get_preedit (context);
    g_assert_cmpstr (preedit, ==, transitions[i].preedit);
    output = skk_context_poll_output (context);
    g_assert_cmpstr (output, ==, transitions[i].output);
    g_free (output);
    input_mode = skk_context_get_input_mode (context);
    g_assert_cmpint (input_mode, ==, transitions[i].next_input_mode);
  }
}
