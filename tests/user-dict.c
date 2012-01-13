#include <libskk/libskk.h>
#include "common.h"

static void
user_dict (void)
{
  GError *error = NULL;
  SkkUserDict *dict = skk_user_dict_new ("user-dict.dat", "EUC-JP", &error);
  g_assert_no_error (error);
  gboolean read_only;

  g_assert (skk_dict_get_read_only (SKK_DICT (dict)) == FALSE);
  g_object_get (dict, "read-only", &read_only, NULL);
  g_assert (read_only == FALSE);
  g_object_unref (dict);
}

static void
save (void)
{
  SkkContext *context;
  gboolean retval;
  GError *error;

  context = create_context (TRUE, TRUE);

  retval = skk_context_process_key_events (context, "A i SPC RET");
  g_assert (retval);

  error = NULL;
  skk_context_save_dictionaries (context, &error);
  g_assert_no_error (error);

  g_object_unref (context);
}

static void
completion (void)
{
  SkkContext *context0, *context;
  gboolean retval;
  const gchar *preedit;
  GError *error;

  /* prepare user dict with four candidates */
  context0 = create_context (TRUE, TRUE);

  retval = skk_context_process_key_events (context0, "A i SPC RET");
  g_assert (retval);

  retval = skk_context_process_key_events (context0, "A i s a t s u SPC RET");
  g_assert (retval);

  retval = skk_context_process_key_events (context0, "A I SPC RET");
  g_assert (retval);

  retval = skk_context_process_key_events (context0, "A U SPC RET");
  g_assert (retval);

  error = NULL;
  skk_context_save_dictionaries (context0, &error);
  g_assert_no_error (error);

  /* perform completion */
  context = create_context (TRUE, FALSE);

  retval = skk_context_process_key_events (context, "A TAB");
  g_assert (retval);

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▽あい");

  retval = skk_context_process_key_events (context, "TAB");
  g_assert (retval);

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▽あいさつ");

  destroy_context (context);
  destroy_context (context0);
}

int
main (int argc, char **argv) {
  g_type_init ();
  skk_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/user-dict", user_dict);
  g_test_add_func ("/libskk/save", save);
  g_test_add_func ("/libskk/completion", completion);
  return g_test_run ();
}
