#include <libskk/libskk.h>
#include "common.h"

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
  g_free (output);

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
  g_free (output);

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▽あい");

  retval = skk_context_process_key_events (context, "SPC");
  g_assert (retval);

  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▼愛");

  retval = skk_context_process_key_events (context, "\n");
  g_assert (!retval);

  output = skk_context_get_output (context);
  g_assert_cmpstr (output, ==, "愛");
  g_free (output);

  retval = skk_context_process_key_events (context, "\n");
  g_assert (!retval);

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
  SkkTransition transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "q", "", "", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_HIRAGANA, "C-q", "", "", SKK_INPUT_MODE_HANKAKU_KATAKANA },
    { SKK_INPUT_MODE_HIRAGANA, "l", "", "", SKK_INPUT_MODE_LATIN },
    { SKK_INPUT_MODE_HIRAGANA, "L", "", "", SKK_INPUT_MODE_WIDE_LATIN },
    { SKK_INPUT_MODE_KATAKANA, "q", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_KATAKANA, "C-q", "", "", SKK_INPUT_MODE_HANKAKU_KATAKANA },
    { SKK_INPUT_MODE_KATAKANA, "l", "", "", SKK_INPUT_MODE_LATIN },
    { SKK_INPUT_MODE_KATAKANA, "L", "", "", SKK_INPUT_MODE_WIDE_LATIN },
    { SKK_INPUT_MODE_HANKAKU_KATAKANA, "q", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HANKAKU_KATAKANA, "C-q", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HANKAKU_KATAKANA, "l", "", "", SKK_INPUT_MODE_LATIN },
    { SKK_INPUT_MODE_HANKAKU_KATAKANA, "L", "", "", SKK_INPUT_MODE_WIDE_LATIN },
    { SKK_INPUT_MODE_LATIN, "C-j", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "w w q", "", "っ", SKK_INPUT_MODE_KATAKANA }
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

static void
rom_kana (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "k", "k", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "k a", "", "か", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "m", "m", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "m y", "my", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "m y o", "", "みょ", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "q", "", "", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_KATAKANA, "k", "k", "", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_KATAKANA, "k a", "", "カ", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_KATAKANA, "n .", "", "ン。", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_HIRAGANA, "z l", "", "→", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "m y C-g", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "m y a C-g", "", "みゃ", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i q", "", "アイ", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_KATAKANA, "A i q", "", "あい", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "V u", "▽う゛", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "V u q", "", "ヴ", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_KATAKANA, "V u", "▽ヴ", "", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_KATAKANA, "V u q", "", "う゛", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q n q", "", "ン", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q Q", "▽", "", SKK_INPUT_MODE_HIRAGANA },
    /* Issue#36 */
    { SKK_INPUT_MODE_HIRAGANA, "W o", "▽を", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "\t K a", "▽か", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_LATIN, "a \t", "", "a", SKK_INPUT_MODE_LATIN }
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

static void
okuri_nasi (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "A", "▽あ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i", "▽あい", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i SPC", "▼愛", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i SPC SPC", "▼哀", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i SPC SPC \n", "", "哀", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_KATAKANA, "A i SPC", "▼哀", "", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_HIRAGANA, "N A", "▽な", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "N A N", "▽な*n", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "I z e n SPC", "▼以前", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a n j i SPC C-j", "", "漢字", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a n j i SPC C-g", "▽かんじ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HANKAKU_KATAKANA, "K a n j i SPC", "▼漢字", "", SKK_INPUT_MODE_HANKAKU_KATAKANA },
    //{ SKK_INPUT_MODE_HIRAGANA, "K a n j i SPC q", "", "漢字", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_KATAKANA, "K a n j i SPC q", "", "漢字", SKK_INPUT_MODE_HIRAGANA },
    /* FIXME */
    // { SKK_INPUT_MODE_HIRAGANA, "A", "[DictEdit] な*んあ ", "", SKK_INPUT_MODE_HIRAGANA },
    // { SKK_INPUT_MODE_HIRAGANA, "A C-g\n", "", "", SKK_INPUT_MODE_HIRAGANA },
    // { SKK_INPUT_MODE_HIRAGANA, "N A N a", "[DictEdit] な*な ", "", SKK_INPUT_MODE_HIRAGANA },
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

static void
okuri_ari (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "K a n g a E", "▼考え", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a n g a E r", "r", "考え", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "H a Z", "▽は*z", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "H a Z u", "▼恥ず", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "T u k a T t", "▽つか*っt", "", SKK_INPUT_MODE_HIRAGANA },
    // Debian Bug#591052
    { SKK_INPUT_MODE_HIRAGANA, "K a n J", "▽かん*j", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a n J i", "▼感じ", "", SKK_INPUT_MODE_HIRAGANA },
    // Issue#10
    { SKK_INPUT_MODE_HIRAGANA, "F u N d a", "▼踏んだ", "", SKK_INPUT_MODE_HIRAGANA },
    // Issue#18
    { SKK_INPUT_MODE_HIRAGANA, "S a S s", "▽さ*っs", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "S a s S", "▽さっ*s", "", SKK_INPUT_MODE_HIRAGANA },
    // Issue#19
    { SKK_INPUT_MODE_HIRAGANA, "A z u m a SPC", "▼東", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A z u m a SPC >", "▽>", "東", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A z u m a SPC > s h i SPC", "▼氏", "東", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "T y o u >", "▼超", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "O K i C-g", "▽おき", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "O K C-g", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A o i O C-g", "▽あおいお", "", SKK_INPUT_MODE_HIRAGANA },
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

static void
_abort (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    // back to select state if candidate list is not empty
    { SKK_INPUT_MODE_HIRAGANA, "A k a SPC SPC SPC C-g", "▼垢", "", SKK_INPUT_MODE_HIRAGANA },
    // back to preedit state if candidate list is empty
    { SKK_INPUT_MODE_HIRAGANA, "A p a SPC C-g", "▽あぱ", "", SKK_INPUT_MODE_HIRAGANA },
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

static void
delete (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "A DEL", "▽", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A DEL DEL", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i s a t s u SPC DEL", "", "挨", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A C-h", "▽", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A C-h C-h", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "E B DEL", "▽え", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "E B DEL r a B", "▽えら*b", "", SKK_INPUT_MODE_HIRAGANA },
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

static void
hankaku_katakana (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "C-q Z e n k a k u", "▽ｾﾞﾝｶｸ", "", SKK_INPUT_MODE_HANKAKU_KATAKANA },
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

static void
completion (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    // midasi word (= "あ") exists in the dictionary
    { SKK_INPUT_MODE_HIRAGANA, "A \t", "▽あい", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A \t \t", "▽あいさつ", "", SKK_INPUT_MODE_HIRAGANA },
    // midasi word (= "あか") exists in the dictionary
    { SKK_INPUT_MODE_HIRAGANA, "A k a \t", "▽あかつき", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A k a \t \t", "▽あかね", "", SKK_INPUT_MODE_HIRAGANA },
    // no more match for midasi word (= "あか")
    { SKK_INPUT_MODE_HIRAGANA, "A k a \t \t \t", "▽あかね", "", SKK_INPUT_MODE_HIRAGANA },
    // midasi word (= "こうこ") does not exist in the dictionary
    { SKK_INPUT_MODE_HIRAGANA, "K o u k o \t", "▽こうこう", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K o u k o \t \t", "▽こうこく", "", SKK_INPUT_MODE_HIRAGANA },
    // no match for midasi word (= "あぱ")
    { SKK_INPUT_MODE_HIRAGANA, "A p a \t", "▽あぱ", "", SKK_INPUT_MODE_HIRAGANA },
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

static void
abbrev (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    // We choose "request" since it contains "q", which normally
    // triggers input mode change
    { SKK_INPUT_MODE_HIRAGANA, "/ r e q u e s t", "▽request", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "/ r e q u e s t SPC", "▼リクエスト", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "z /", "", "・", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "/ ]", "▽]", "", SKK_INPUT_MODE_HIRAGANA },
    // Ignore "" in abbrev mode (Issue#16).
    { SKK_INPUT_MODE_HIRAGANA, "/ \\(", "▽(", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "/ A", "▽A", "", SKK_INPUT_MODE_HIRAGANA },
    // Convert latin to wide latin with ctrl+q (Issue#17).
    { SKK_INPUT_MODE_HIRAGANA, "/ a a C-q", "", "ａａ", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "/ d o s v SPC", "▼DOS/V", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "/ b s d 3 SPC", "▼BSD/3", "", SKK_INPUT_MODE_HIRAGANA },
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

static void
dict_edit (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC", "[DictEdit] かぱ ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC a", "[DictEdit] かぱ あ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a", "[DictEdit] かぱ ▽か", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a p a SPC", "[[DictEdit]] かぱ ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a p a SPC C-g", "[DictEdit] かぱ ▽かぱ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a p a SPC C-g C-g", "[DictEdit] かぱ ", "", SKK_INPUT_MODE_HIRAGANA },
    // Don't register empty string (Debian Bug#590191)
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC \n", "▽かぱ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a SPC", "[DictEdit] かぱ ▼下", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a SPC H a SPC C-j", "[DictEdit] かぱ 下破", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a SPC H a SPC \n", "", "下破", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC", "▼下破", "", SKK_INPUT_MODE_HIRAGANA },
    // Purge "下破" from the user dictionary (Debian Bug#590188).
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC X", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC", "[DictEdit] かぱ ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a n g a E SPC", "[DictEdit] かんが*え ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a t a k a n a SPC SPC K a t a k a n a q", "[DictEdit] かたかな カタカナ", "", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a t a k a n a SPC SPC K a t a k a n a q l n a", "[DictEdit] かたかな カタカナna", "", SKK_INPUT_MODE_LATIN },
    { SKK_INPUT_MODE_HIRAGANA, "K a t a k a n a SPC SPC K a t a k a n a q C-m", "", "カタカナ", SKK_INPUT_MODE_HIRAGANA },
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

static void
kuten (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "\\\\", "Kuten([MM]KKTT) ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "\\\\ a DEL", "Kuten([MM]KKTT) ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "\\\\ a 1 a 2 \n", "", "、", SKK_INPUT_MODE_HIRAGANA },
    // Don't start KUTEN input on latin input modes.
    { SKK_INPUT_MODE_LATIN, "\\\\", "", "\\", SKK_INPUT_MODE_LATIN },
    { SKK_INPUT_MODE_WIDE_LATIN, "\\\\", "", "＼", SKK_INPUT_MODE_WIDE_LATIN },
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

static void
auto_conversion (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "A i ,", "▼愛、", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i , SPC", "▼哀、", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i w o", "▼愛を", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i SPC \\(", "", "愛(", SKK_INPUT_MODE_HIRAGANA },
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
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
  };

  context = create_context ();
  error = NULL;
  rule = skk_rule_new ("kzik", &error);
  g_assert_no_error (error);
  skk_context_set_typing_rule (context, rule);
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
  g_object_unref (rule);
}

static void
numeric (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "Q 5 / 1 SPC", "▼5月1日", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 5 h i k i SPC", "▼５匹", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 5 h i k i SPC SPC", "▼五匹", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 5 h i k i SPC SPC C-j", "", "五匹", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 1 h i k i SPC", "▼一匹", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 5 0 0 0 0 h i k i SPC", "▼五万匹", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 1 0 h i k i SPC", "▼十匹", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 1 1 1 1 1 h i k i SPC", "▼一万千百十一匹", "", SKK_INPUT_MODE_HIRAGANA },
  };

  context = create_context ();
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

static void
nicola (void)
{
  SkkContext *context;
  SkkRule *rule;
  SkkTransition transitions[] = {
    // single key - timeout
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 200000)", "", "う", SKK_INPUT_MODE_HIRAGANA },
    // single key - release
    { SKK_INPUT_MODE_HIRAGANA, "a (release a)", "", "う", SKK_INPUT_MODE_HIRAGANA },
    // single key - overlap
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 50000) b", "", "う", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 50000) b (usleep 200000)", "", "うへ", SKK_INPUT_MODE_HIRAGANA },
    // double key - shifted
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 10000) (lshift) (usleep 200000)", "", "を", SKK_INPUT_MODE_HIRAGANA },
    // double key - shifted reverse
    { SKK_INPUT_MODE_HIRAGANA, "(lshift) (usleep 10000) a (usleep 200000)", "", "を", SKK_INPUT_MODE_HIRAGANA },
    // double key - shifted expired
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 60000) (lshift)", "", "う", SKK_INPUT_MODE_HIRAGANA },
    // double key - skk-nicola
    { SKK_INPUT_MODE_HIRAGANA, "f (usleep 30000) j", "▽", "", SKK_INPUT_MODE_HIRAGANA },
    // double key - skk-nicola reverse
    { SKK_INPUT_MODE_HIRAGANA, "j (usleep 30000) f", "▽", "", SKK_INPUT_MODE_HIRAGANA },
    // double key - skk-nicola (shift only)
    { SKK_INPUT_MODE_HIRAGANA, "(lshift) (usleep 30000) (rshift)", "", "", SKK_INPUT_MODE_LATIN },
    // triple key t1 <= t2
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 10000) (lshift) (usleep 20000) b", "", "を", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "a (usleep 20000) (lshift) (usleep 10000) b", "", "うぃ", SKK_INPUT_MODE_HIRAGANA },
    // preedit
    { SKK_INPUT_MODE_HIRAGANA, "f (usleep 30000) j a (release a)", "▽う", "", SKK_INPUT_MODE_HIRAGANA },
    // preedit
    { SKK_INPUT_MODE_HIRAGANA, "f (usleep 30000) j a (release a) f (usleep 30000) j", "▽う*", "", SKK_INPUT_MODE_HIRAGANA },
    // preedit
    { SKK_INPUT_MODE_HIRAGANA, "f (usleep 30000) j a (release a) f (usleep 30000) j i (release i)", "▼受く", "", SKK_INPUT_MODE_HIRAGANA },
    // hiragana -> katakana
    { SKK_INPUT_MODE_HIRAGANA, "d (usleep 30000) k a (release a)", "", "ウ", SKK_INPUT_MODE_KATAKANA },
    // hiragana -> latin
    { SKK_INPUT_MODE_HIRAGANA, "A (release A)", "", "", SKK_INPUT_MODE_LATIN },
    // hiragana -> wide latin
    { SKK_INPUT_MODE_HIRAGANA, "Z (release Z)", "", "", SKK_INPUT_MODE_WIDE_LATIN },
  };
  GError *error;

  context = create_context ();
  error = NULL;
  rule = skk_rule_new ("nicola", &error);
  g_assert_no_error (error);
  skk_context_set_typing_rule (context, rule);
  g_object_unref (rule);
  check_transitions (context, transitions, G_N_ELEMENTS (transitions));
  g_object_unref (context);
}

int
main (int argc, char **argv) {
  g_type_init ();
  skk_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/context", context);
  g_test_add_func ("/libskk/input-mode", input_mode);
  g_test_add_func ("/libskk/rom-kana", rom_kana);
  g_test_add_func ("/libskk/okuri-nasi", okuri_nasi);
  g_test_add_func ("/libskk/okuri-ari", okuri_ari);
  g_test_add_func ("/libskk/abort", _abort);
  g_test_add_func ("/libskk/delete", delete);
  g_test_add_func ("/libskk/hankaku-katakana", hankaku_katakana);
  g_test_add_func ("/libskk/completion", completion);
  g_test_add_func ("/libskk/abbrev", abbrev);
  g_test_add_func ("/libskk/dict-edit", dict_edit);
  g_test_add_func ("/libskk/kuten", kuten);
  g_test_add_func ("/libskk/auto-conversion", auto_conversion);
  g_test_add_func ("/libskk/kzik", kzik);
  g_test_add_func ("/libskk/numeric", numeric);
  g_test_add_func ("/libskk/nicola", nicola);
  return g_test_run ();
}
