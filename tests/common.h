#ifndef __COMMON_H__
#define __COMMON_H__ 1

#include <libskk/libskk.h>

struct _SkkTransition {
  SkkInputMode input_mode;
  const gchar *keys;
  const gchar *preedit;
  const gchar *output;
  SkkInputMode next_input_mode;
};
typedef struct _SkkTransition SkkTransition;

SkkContext *create_context    (gboolean       use_user_dict,
                               gboolean       use_file_dict);
void        destroy_context   (SkkContext    *context);
void        check_transitions (SkkContext    *context,
                               SkkTransition *transitions,
                               int            n_transitions);

#endif  /* __COMMON_H__ */
