#include <libskk/libskk.h>
#include "common.h"

static void
list (void) {
  SkkRuleMetadata *rules;
  gint len;

  rules = skk_rule_list (&len);
  g_assert_cmpint (len, >, 0);
  while (--len >= 0) {
    skk_rule_metadata_destroy (&rules[len]);
  }
  g_free (rules);
}

static void
kzik (void)
{
  SkkContext *context;
  GError *error;
  SkkRule *rule;
  SkkTransition transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "b g d", "", "びぇん", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "s q", "", "さい", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "d l", "", "どん", SKK_INPUT_MODE_HIRAGANA },
    { 0, NULL }
  };

  context = create_context (TRUE, TRUE);
  error = NULL;
  rule = skk_rule_new ("kzik", &error);
  g_assert_no_error (error);
  skk_context_set_typing_rule (context, rule);
  g_object_unref (rule);
  check_transitions (context, transitions);
  destroy_context (context);
}

static void
nicola (void)
{
  SkkContext *context;
  SkkRule *rule;
  SkkTransition transitions[] = {
    /* single key - timeout */
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 200000)", "", "う", SKK_INPUT_MODE_HIRAGANA },
    /* single key - release */
    { SKK_INPUT_MODE_HIRAGANA, "a (release a)", "", "う", SKK_INPUT_MODE_HIRAGANA },
    /* single key - overlap */
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 50000) b", "", "う", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 50000) b (usleep 200000)", "", "うへ", SKK_INPUT_MODE_HIRAGANA },
    /* double key - shifted */
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 10000) (lshift) (usleep 200000)", "", "を", SKK_INPUT_MODE_HIRAGANA },
    /* double key - shifted reverse */
    { SKK_INPUT_MODE_HIRAGANA, "(lshift) (usleep 10000) a (usleep 200000)", "", "を", SKK_INPUT_MODE_HIRAGANA },
    /* double key - shifted expired */
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 60000) (lshift)", "", "う", SKK_INPUT_MODE_HIRAGANA },
    /* double key - skk-nicola */
    { SKK_INPUT_MODE_HIRAGANA, "f (usleep 30000) j", "▽", "", SKK_INPUT_MODE_HIRAGANA },
    /* double key - skk-nicola reverse */
    { SKK_INPUT_MODE_HIRAGANA, "j (usleep 30000) f", "▽", "", SKK_INPUT_MODE_HIRAGANA },
    /* double key - skk-nicola (shift only) */
    { SKK_INPUT_MODE_HIRAGANA, "(lshift) (usleep 30000) (rshift)", "", "", SKK_INPUT_MODE_LATIN },
    /* triple key t1 <= t2 */
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 10000) (lshift) (usleep 20000) b", "", "を", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 20000) (lshift) (usleep 10000) b", "", "うぃ", SKK_INPUT_MODE_HIRAGANA },
    /* preedit */
    { SKK_INPUT_MODE_HIRAGANA, "f (usleep 30000) j a (release a)", "▽う", "", SKK_INPUT_MODE_HIRAGANA },
    /* preedit */
    { SKK_INPUT_MODE_HIRAGANA, "f (usleep 30000) j a (release a) f (usleep 30000) j", "▽う*", "", SKK_INPUT_MODE_HIRAGANA },
    /* preedit */
    { SKK_INPUT_MODE_HIRAGANA, "f (usleep 30000) j a (release a) f (usleep 30000) j i (release i)", "▼受く", "", SKK_INPUT_MODE_HIRAGANA },
    /* hiragana -> katakana */
    { SKK_INPUT_MODE_HIRAGANA, "d (usleep 30000) k a (release a)", "", "ウ", SKK_INPUT_MODE_KATAKANA },
    /* hiragana -> latin */
    { SKK_INPUT_MODE_HIRAGANA, "A (release A)", "", "", SKK_INPUT_MODE_LATIN },
    /* hiragana -> wide latin */
    { SKK_INPUT_MODE_HIRAGANA, "Z (release Z)", "", "", SKK_INPUT_MODE_WIDE_LATIN },
    { 0, NULL }
  };
  GError *error;

  context = create_context (TRUE, TRUE);
  error = NULL;
  rule = skk_rule_new ("nicola", &error);
  g_assert_no_error (error);
  skk_context_set_typing_rule (context, rule);
  g_object_unref (rule);
  check_transitions (context, transitions);
  destroy_context (context);
}

int
main (int argc, char **argv) {
  g_type_init ();
  skk_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/list", list);
  g_test_add_func ("/libskk/kzik", kzik);
  g_test_add_func ("/libskk/nicola", nicola);
  return g_test_run ();
}
