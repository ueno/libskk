libskk -- a library to deal with Japanese kana-to-kanji conversion method
======
[![Build Status](https://travis-ci.org/ueno/libskk.svg?branch=master)](https://travis-ci.org/ueno/libskk) [![Coverage Status](https://img.shields.io/coveralls/ueno/libskk.svg)](https://coveralls.io/r/ueno/libskk)

Features
------

* Support basic features of SKK including: new word registration,
completion, numeric conversion, abbrev mode, kuten input,
hankaku-katakana input, Lisp expression evaluation (concat only),
and re-conversion.

* Support various typing rules including: romaji-to-kana, AZIK,
TUT-Code, and NICOLA.

* Support various dictionary types including: file dictionary (such as
SKK-JISYO.[SML]), user dictionary, skkserv, and CDB format
dictionary.

* GObject based API with gobject-introspection support.

Documentation
------

* [Basic usage](https://github.com/ueno/libskk/blob/master/tests/context.c)
* [Keymap and Romaji-to-Kana table customization](https://github.com/ueno/libskk/blob/master/rules/README.rules)
* [Vala binding reference](https://ueno.github.io/libskk/vala/)
* [C binding reference](https://ueno.github.io/libskk/c/)

Compile (macOS Darwin)
------
Install the build tools

```bash
brew install automake
brew install libtool
brew install gettext
brew install vala
```

and add `gettext` to the path

```bash
vi ~/.bash_profile
export PATH=${PATH}:/usr/local/opt/gettext/bin
```

Install the libraries

```bash
brew install libgee
brew install json-glib
brew install libxkbcommon
```

Now run `make`.

To execute without install, please set `LIBSKK_DATA_PATH` to the directory containing rules:

```bash
export LIBSKK_DATA_PATH=$PWD ./tools/skk
```

To install run `make install`.

Test
------
```
$ echo "A i SPC" | skk
{ "input": "A i SPC", "output": "", "preedit": "▼愛" }
$ echo "K a p a SPC K a SPC" | skk
{ "input": "K a p a SPC K a SPC", "output": "", "preedit": "▼かぱ【▼蚊】" }
$ echo "r k" | skk -r tutcode
{ "input": "r k", "output": "あ", "preedit": "" }
$ echo "a (usleep 50000) b (usleep 200000)" | skk -r nicola
{ "input": "a (usleep 50000) b (usleep 200000)", "output": "うへ", "preedit": "" }
```

License
------
```
GPLv3+

Copyright (C) 2011-2018 Daiki Ueno <ueno@gnu.org>
Copyright (C) 2011-2018 Red Hat, Inc.

This file is free software; as a special exception the author gives
unlimited permission to copy and/or distribute it, with or without
modifications, as long as this notice is preserved.

This file is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```