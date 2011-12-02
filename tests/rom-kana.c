#include <libskk/libskk.h>

static void
rom_kana (void)
{
  SkkRomKanaConverter *converter = skk_rom_kana_converter_new ();
  const gchar *preedit, *output;

  skk_rom_kana_converter_append_text (converter, "m");
  preedit = skk_rom_kana_converter_get_preedit (converter);
  g_assert_cmpstr (preedit, ==, "m");
  output = skk_rom_kana_converter_get_output (converter);
  g_assert_cmpstr (output, ==, "");

  skk_rom_kana_converter_append_text (converter, "u");
  preedit = skk_rom_kana_converter_get_preedit (converter);
  g_assert_cmpstr (preedit, ==, "");
  output = skk_rom_kana_converter_get_output (converter);
  g_assert_cmpstr (output, ==, "む");

  skk_rom_kana_converter_reset (converter);
  skk_rom_kana_converter_set_kana_mode (converter, SKK_KANA_MODE_KATAKANA);
  skk_rom_kana_converter_append_text (converter, "min");
  skk_rom_kana_converter_output_nn_if_any (converter);
  output = skk_rom_kana_converter_get_output (converter);
  g_assert_cmpstr (output, ==, "ミン");

  skk_rom_kana_converter_reset (converter);
  skk_rom_kana_converter_set_kana_mode (converter, SKK_KANA_MODE_HIRAGANA);
  skk_rom_kana_converter_append_text (converter, "desu.");
  skk_rom_kana_converter_output_nn_if_any (converter);
  output = skk_rom_kana_converter_get_output (converter);
  g_assert_cmpstr (output, ==, "です。");

  skk_rom_kana_converter_reset (converter);
  skk_rom_kana_converter_set_kana_mode (converter, SKK_KANA_MODE_HIRAGANA);
  skk_rom_kana_converter_append_text (converter, "ww");
  preedit = skk_rom_kana_converter_get_preedit (converter);
  g_assert_cmpstr (preedit, ==, "w");
  output = skk_rom_kana_converter_get_output (converter);
  g_assert_cmpstr (output, ==, "っ");

  g_object_unref (converter);
}

int
main (int argc, char **argv) {
  g_type_init ();
  skk_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/rom-kana", rom_kana);
  return g_test_run ();
}
