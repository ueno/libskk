#include <libskk/libskk.h>
#include "common.h"

static void
user_dict (void)
{
  SkkContext *context;
  gboolean retval;
  const gchar *output, *preedit;

  context = create_context ();

  retval = skk_context_process_key_events (context, "A i SPC RET");
  g_assert (retval);

  skk_context_save_dictionaries (context);

  g_object_unref (context);
}

int
main (int argc, char **argv) {
  g_type_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/user-dict", user_dict);
  return g_test_run ();
}
