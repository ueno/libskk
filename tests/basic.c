#include <libskk/libskk.h>
#include "common.h"

static SkkTransition input_mode_transitions[] =
  {
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
    { SKK_INPUT_MODE_HIRAGANA, "w w q", "", "っ", SKK_INPUT_MODE_KATAKANA },
    /* Issue#10 */
    { SKK_INPUT_MODE_HIRAGANA, "l Q", "", "Q", SKK_INPUT_MODE_LATIN },
    /* Issue#15 */
    { SKK_INPUT_MODE_HIRAGANA, "n q", "", "ん", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_KATAKANA, "n q", "", "ン", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "n l", "", "ん", SKK_INPUT_MODE_LATIN },
    { 0, NULL }
  };

static SkkTransition rom_kana_transitions[] =
  {
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
    { SKK_INPUT_MODE_HIRAGANA, "A i q", "", "アイ", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_KATAKANA, "A i q", "", "あい", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_HIRAGANA, "V u", "▽う゛", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "V u q", "", "ヴ", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_KATAKANA, "V u", "▽ヴ", "", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_KATAKANA, "V u q", "", "う゛", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q n q", "", "ン", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q Q", "▽", "", SKK_INPUT_MODE_HIRAGANA },
    /* Issue#9 */
    { SKK_INPUT_MODE_HIRAGANA, "n SPC", "", "ん ", SKK_INPUT_MODE_HIRAGANA },
    /* ibus-skk Issue#36 */
    { SKK_INPUT_MODE_HIRAGANA, "W o", "▽を", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "\t K a", "▽か", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_LATIN, "a \t", "", "a", SKK_INPUT_MODE_LATIN },
    /* Issue#11 */
    { SKK_INPUT_MODE_HIRAGANA, "q s a n S y a", "▽シャ", "サン", SKK_INPUT_MODE_KATAKANA },
    { 0, NULL }
  };

static SkkTransition okuri_nasi_transitions[] =
  {
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
    { SKK_INPUT_MODE_HIRAGANA, "K a n j i SPC q", "", "漢字", SKK_INPUT_MODE_KATAKANA },
    { SKK_INPUT_MODE_KATAKANA, "K a n j i SPC q", "", "漢字", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "N A N A", "▼な*んあ【】", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "N A N a", "▼な*な【】", "", SKK_INPUT_MODE_HIRAGANA },
    { 0, NULL }
  };

static SkkTransition okuri_ari_transitions[] =
  {
    { SKK_INPUT_MODE_HIRAGANA, "K a n g a E", "▼考え", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a n g a E r", "r", "考え", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "H a Z", "▽は*z", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "H a Z u", "▼恥ず", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "T u k a T t", "▽つか*っt", "", SKK_INPUT_MODE_HIRAGANA },
    /* Debian Bug#591052 */
    { SKK_INPUT_MODE_HIRAGANA, "K a n J", "▽かん*j", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a n J i", "▼感じ", "", SKK_INPUT_MODE_HIRAGANA },
    /* ibus-skk Issue#10 */
    { SKK_INPUT_MODE_HIRAGANA, "F u N d a", "▼踏んだ", "", SKK_INPUT_MODE_HIRAGANA },
    /* ibus-skk Issue#18 */
    { SKK_INPUT_MODE_HIRAGANA, "S a S s", "▽さ*っs", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "S a s S", "▽さっ*s", "", SKK_INPUT_MODE_HIRAGANA },
    /* ibus-skk Issue#19 */
    { SKK_INPUT_MODE_HIRAGANA, "A z u m a SPC", "▼東", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A z u m a SPC >", "▽>", "東", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A z u m a SPC > s h i SPC", "▼氏", "東", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "T y o u >", "▼超", "", SKK_INPUT_MODE_HIRAGANA },
    /* Issue#12 */
    { SKK_INPUT_MODE_HIRAGANA, "q S i r o K u", "▼白ク", "", SKK_INPUT_MODE_KATAKANA },
    /* Issue#23 */
    { SKK_INPUT_MODE_HIRAGANA, "T e t u d a I SPC C-g", "▼手伝い", "", SKK_INPUT_MODE_HIRAGANA },
    { 0, NULL }
  };

static SkkTransition abort_transitions[] =
  {
    /* back to select state if candidate list is not empty */
    { SKK_INPUT_MODE_HIRAGANA, "A k a SPC SPC SPC C-g", "▼垢", "", SKK_INPUT_MODE_HIRAGANA },
    /* back to preedit state if candidate list is empty */
    { SKK_INPUT_MODE_HIRAGANA, "A p a SPC C-g", "▽あぱ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "O K i C-g", "▽おき", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "O K C-g", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A o i O C-g", "▽あおいお", "", SKK_INPUT_MODE_HIRAGANA },
    { 0, NULL }
  };

static SkkTransition delete_transitions[] =
  {
    { SKK_INPUT_MODE_HIRAGANA, "A DEL", "▽", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A DEL DEL", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i s a t s u SPC DEL", "", "挨", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A C-h", "▽", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A C-h C-h", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "E B DEL", "▽え", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "E B DEL r a B", "▽えら*b", "", SKK_INPUT_MODE_HIRAGANA },
    { 0, NULL }
  };

static SkkTransition hankaku_katakana_transitions[] =
  {
    { SKK_INPUT_MODE_HIRAGANA, "C-q Z e n k a k u", "▽ｾﾞﾝｶｸ", "", SKK_INPUT_MODE_HANKAKU_KATAKANA },
    { 0, NULL }
  };

static SkkTransition completion_transitions[] =
  {
    /* midasi word (= "あ") exists in the dictionary */
    { SKK_INPUT_MODE_HIRAGANA, "A \t", "▽あい", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A \t \t", "▽あいさつ", "", SKK_INPUT_MODE_HIRAGANA },
    /* midasi word (= "あか") exists in the dictionary */
    { SKK_INPUT_MODE_HIRAGANA, "A k a \t", "▽あかつき", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A k a \t \t", "▽あかね", "", SKK_INPUT_MODE_HIRAGANA },
    /* no more match for midasi word (= "あか") */
    { SKK_INPUT_MODE_HIRAGANA, "A k a \t \t \t", "▽あかね", "", SKK_INPUT_MODE_HIRAGANA },
    /* midasi word (= "こうこ") does not exist in the dictionary */
    { SKK_INPUT_MODE_HIRAGANA, "K o u k o \t", "▽こうこう", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K o u k o \t \t", "▽こうこく", "", SKK_INPUT_MODE_HIRAGANA },
    /* no match for midasi word (= "あぱ") */
    { SKK_INPUT_MODE_HIRAGANA, "A p a \t", "▽あぱ", "", SKK_INPUT_MODE_HIRAGANA },
    { 0, NULL }
  };

static SkkTransition abbrev_transitions[] =
  {
    /* We choose "request" since it contains "q", which normally
       triggers input mode change */
    { SKK_INPUT_MODE_HIRAGANA, "/ r e q u e s t", "▽request", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "/ r e q u e s t SPC", "▼リクエスト", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "z /", "", "・", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "/ ]", "▽]", "", SKK_INPUT_MODE_HIRAGANA },
    /* Ignore "" in abbrev mode (ibus-skk Issue#16). */
    { SKK_INPUT_MODE_HIRAGANA, "/ \\(", "▽(", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "/ A", "▽A", "", SKK_INPUT_MODE_HIRAGANA },
    /* Convert latin to wide latin with ctrl+q (ibus-skk Issue#17). */
    { SKK_INPUT_MODE_HIRAGANA, "/ a a C-q", "", "ａａ", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "/ d o s v SPC", "▼DOS/V", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "/ b s d 3 SPC", "▼BSD/3", "", SKK_INPUT_MODE_HIRAGANA },
    { 0, NULL }
  };

static SkkTransition dict_edit_transitions[] =
  {
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC", "▼かぱ【】", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC a", "▼かぱ【あ】", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a", "▼かぱ【▽か】", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a p a SPC", "▼かぱ【▼かぱ【】】", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a p a SPC C-g", "▼かぱ【▽かぱ】", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a p a SPC C-g C-g", "▼かぱ【】", "", SKK_INPUT_MODE_HIRAGANA },
    /* Don't register empty string (Debian Bug#590191). */
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC \n", "▽かぱ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a SPC", "▼かぱ【▼下】", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a SPC H a SPC C-j", "▼かぱ【下破】", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC K a SPC H a SPC \n", "", "下破", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC", "▼下破", "", SKK_INPUT_MODE_HIRAGANA },
    /* Purge "下破" from the user dictionary (Debian Bug#590188). */
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC X", "", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a p a SPC", "▼かぱ【】", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a n g a E SPC", "▼かんが*え【】", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a t a k a n a SPC SPC K a t a k a n a q", "▼かたかな【カタカナ】", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "K a t a k a n a SPC SPC K a t a k a n a q l n a", "▼かたかな【カタカナna】", "", SKK_INPUT_MODE_LATIN },
    { SKK_INPUT_MODE_HIRAGANA, "K a t a k a n a SPC SPC K a t a k a n a q C-m", "", "カタカナ", SKK_INPUT_MODE_HIRAGANA },
    /* Issue#11 */
    { SKK_INPUT_MODE_HIRAGANA, "t a k K u n SPC", "▼っくん【】", "た", SKK_INPUT_MODE_HIRAGANA },
    { 0, NULL }
  };

static SkkTransition kuten_transitions[] =
  {
    { SKK_INPUT_MODE_HIRAGANA, "\\\\", "Kuten([MM]KKTT) ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "\\\\ a DEL", "Kuten([MM]KKTT) ", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "\\\\ a 1 a 2 \n", "", "、", SKK_INPUT_MODE_HIRAGANA },
    /* Don't start KUTEN input on latin input modes. */
    { SKK_INPUT_MODE_LATIN, "\\\\", "", "\\", SKK_INPUT_MODE_LATIN },
    { SKK_INPUT_MODE_WIDE_LATIN, "\\\\", "", "＼", SKK_INPUT_MODE_WIDE_LATIN },
    { 0, NULL }
  };

static SkkTransition auto_conversion_transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "A i ,", "▼愛、", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i , SPC", "▼哀、", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i w o", "▼愛を", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "A i SPC \\(", "", "愛(", SKK_INPUT_MODE_HIRAGANA },
    { 0, NULL }
  };

static SkkTransition numeric_transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "Q 5 / 1 SPC", "▼5月1日", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 5 h i k i SPC", "▼５匹", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 5 h i k i SPC SPC", "▼五匹", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 5 h i k i SPC SPC C-j", "", "五匹", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 1 h i k i SPC", "▼一匹", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 5 0 0 0 0 h i k i SPC", "▼五万匹", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 1 0 h i k i SPC", "▼十匹", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "Q 1 1 1 1 1 h i k i SPC", "▼一万千百十一匹", "", SKK_INPUT_MODE_HIRAGANA },
    { 0, NULL }
  };

struct _SkkFixture {
  SkkContext *context;
};
typedef struct _SkkFixture SkkFixture;

static void
context_setup (SkkFixture *fixture, gconstpointer data)
{
  fixture->context = create_context (TRUE, TRUE);
}

static void
context_teardown (SkkFixture *fixture, gconstpointer data)
{
  destroy_context (fixture->context);
} 

static void
test_transitions (SkkFixture *fixture, gconstpointer data)
{
  const SkkTransition *transitions = data;
  check_transitions (fixture->context, transitions);
}

static void
candidate_list (void)
{
  SkkContext *context;
  SkkTransition transitions[] = {
    { SKK_INPUT_MODE_HIRAGANA, "I SPC SPC SPC SPC SPC", "▼唯", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "I SPC SPC SPC SPC SPC SPC", "▼違", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "I SPC SPC SPC SPC SPC SPC x x", "▼井", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "I SPC SPC SPC SPC SPC SPC SPC", "▼移", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "I SPC SPC SPC SPC SPC SPC SPC SPC", "▼委", "", SKK_INPUT_MODE_HIRAGANA },
    { SKK_INPUT_MODE_HIRAGANA, "I SPC SPC SPC SPC SPC SPC SPC SPC SPC", "▼い【】", "", SKK_INPUT_MODE_HIRAGANA },
    { 0, NULL }
  };
  SkkCandidateList *candidates;
  SkkCandidate *candidate;
  gint cursor_pos;
  gint retval;

  context = create_context (TRUE, TRUE);
  check_transitions (context, transitions);

  candidates = skk_context_get_candidates (context);
  skk_candidate_list_set_page_start (candidates, 4);
  skk_candidate_list_set_page_size (candidates, 7);

  cursor_pos = skk_candidate_list_get_cursor_pos (candidates);
  g_assert_cmpint (cursor_pos, ==, -1);

  retval = skk_context_process_key_events (context, "I SPC");
  g_assert (retval);

  cursor_pos = skk_candidate_list_get_cursor_pos (candidates);
  g_assert_cmpint (cursor_pos, ==, 0);

  skk_candidate_list_cursor_down (candidates);
  cursor_pos = skk_candidate_list_get_cursor_pos (candidates);
  g_assert_cmpint (cursor_pos, ==, 1);

  skk_candidate_list_cursor_up (candidates);
  cursor_pos = skk_candidate_list_get_cursor_pos (candidates);
  g_assert_cmpint (cursor_pos, ==, 0);

  /* page_down has no effect if cursor_pos < page_start */
  retval = skk_candidate_list_page_down (candidates);
  g_assert (!retval);
  cursor_pos = skk_candidate_list_get_cursor_pos (candidates);
  g_assert_cmpint (cursor_pos, ==, 0);

  /* page_up has no effect if cursor_pos < page_start + page_size */
  retval = skk_candidate_list_page_up (candidates);
  g_assert (!retval);
  cursor_pos = skk_candidate_list_get_cursor_pos (candidates);
  g_assert_cmpint (cursor_pos, ==, 0);

  for (cursor_pos = 0;
       cursor_pos < skk_candidate_list_get_page_start (candidates);
       cursor_pos++) {
    g_assert (!skk_candidate_list_get_page_visible (candidates));
    skk_candidate_list_next (candidates);
  }
  g_assert (skk_candidate_list_get_page_visible (candidates));

  skk_candidate_list_next (candidates);
  cursor_pos = skk_candidate_list_get_cursor_pos (candidates);
  g_assert_cmpint (cursor_pos, ==,
                   skk_candidate_list_get_page_start (candidates) +
                   skk_candidate_list_get_page_size (candidates));

  skk_candidate_list_previous (candidates);
  cursor_pos = skk_candidate_list_get_cursor_pos (candidates);
  g_assert_cmpint (cursor_pos, ==,
                   skk_candidate_list_get_page_start (candidates));

  candidate = skk_candidate_list_get (candidates, -1);
  g_assert_cmpstr (skk_candidate_get_text (candidate), ==, "唯");
  g_object_unref (candidate);

  skk_candidate_list_previous (candidates);
  cursor_pos = skk_candidate_list_get_cursor_pos (candidates);
  g_assert_cmpint (cursor_pos, ==,
                   skk_candidate_list_get_page_start (candidates) - 1);

  skk_candidate_list_select (candidates);

  destroy_context (context);
}

static gboolean
retrieve_surrounding_text_cb (SkkContext* self,
                              gchar**     text,
                              guint*      cursor_pos,
                              gpointer    user_data)
{
  *text = g_strdup ("あああ");
  *cursor_pos = 0;
  return TRUE;
}

static gboolean
delete_surrounding_text_cb (SkkContext* self,
                            gint        offset,
                            guint       nchars,
                            gpointer    user_data)
{
  return TRUE;
}

static void
surrounding (void) {
  SkkContext *context = create_context (TRUE, TRUE);
  const gchar *preedit;
  g_signal_connect (context, "retrieve-surrounding-text",
                    G_CALLBACK (retrieve_surrounding_text_cb), NULL);
  g_signal_connect (context, "delete-surrounding-text",
                    G_CALLBACK (delete_surrounding_text_cb), NULL);
  skk_context_process_key_events (context, "Q Right SPC");
  preedit = skk_context_get_preedit (context);
  g_assert_cmpstr (preedit, ==, "▼阿ああ");
  destroy_context (context);
}

int
main (int argc, char **argv) {
  g_type_init ();
  skk_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add ("/libskk/input-mode",
              SkkFixture, input_mode_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add ("/libskk/rom-kana",
              SkkFixture, rom_kana_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add ("/libskk/okuri-nasi",
              SkkFixture, okuri_nasi_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add ("/libskk/okuri-ari",
              SkkFixture, okuri_ari_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add ("/libskk/abort",
              SkkFixture, abort_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add ("/libskk/delete",
              SkkFixture, delete_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add ("/libskk/hankaku-katakana",
              SkkFixture, hankaku_katakana_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add ("/libskk/completion",
              SkkFixture, completion_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add ("/libskk/abbrev",
              SkkFixture, abbrev_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add ("/libskk/dict-edit",
              SkkFixture, dict_edit_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add ("/libskk/kuten",
              SkkFixture, kuten_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add ("/libskk/auto-conversion",
              SkkFixture, auto_conversion_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add ("/libskk/numeric",
              SkkFixture, numeric_transitions,
              context_setup, test_transitions, context_teardown);
  g_test_add_func ("/libskk/candidate-list", candidate_list);
  g_test_add_func ("/libskk/surrounding", surrounding);
  return g_test_run ();
}
