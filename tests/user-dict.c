#include <libskk/libskk.h>
#include "common.h"

static void
user_dict (void)
{
  SkkContext *context;
  gboolean retval;
  const gchar *output, *preedit;
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
  SkkContext *context;
  gboolean retval;
  const gchar *output, *preedit;
  GError *error;

  /* prepare user dict with two candidates */
  context = create_context (TRUE, TRUE);

  retval = skk_context_process_key_events (context, "A i SPC RET");
  g_assert (retval);

  retval = skk_context_process_key_events (context, "A i s a t s u SPC RET");
  g_assert (retval);

  error = NULL;
  skk_context_save_dictionaries (context, &error);
  g_assert_no_error (error);

  g_object_unref (context);

  /* perform completion */
  context = create_context (TRUE, FALSE);

  retval = skk_context_process_key_events (context, "A TAB");
  g_assert (retval);

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "あい");

  retval = skk_context_process_key_events (context, "TAB");
  g_assert (retval);

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "あいさつ");

  g_object_unref (context);
}

int
main (int argc, char **argv) {
  g_type_init ();
  skk_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/user-dict", user_dict);
  return g_test_run ();
}
