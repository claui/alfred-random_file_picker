# Random File Picker

**Random File Picker** is an [Alfred](https://www.alfredapp.com/) workflow.

It adds a file action called _Pick random files_ to Alfred. The file action allows the user to enter a number, then it picks that exact number of files randomly from the chosen folder. It then copies that random set of files to a chosen destination folder.

This workflow was inspired by Sr_Navarre’s posts on [Reddit](https://www.reddit.com/r/Alfred/comments/86aztk/could_someone_who_knows_about_writing_scripts/) and [the Alfred forum](https://www.alfredforum.com/topic/11363-how-can-i-use-alfred-to-choose-a-random-selection-from-a-large-group-of-files/).


## Release history

- Current version: v0.1


## Requirements

Random File Picker has the following requirements:

- Alfred&nbsp;3.5 or newer (including the **Alfred&nbsp;Powerpack**) by Andrew and Vero Pepperrell of Running&nbsp;with&nbsp;Crayons Ltd.

- macOS 10.12 Sierra or newer


## Main features

This workflow lets the user choose a number of files per file type, for example:

- PNG file × 50
- MPEG-4 file × 3

It also allows the user to pick a destination folder, for example `~/Downloads`. This specifies the location where the random set of files will be copied.

For each selected file type, the workflow then picks the specified number of random files (per file type) and copies those files to the chosen destination folder.


## Example

1. Open Alfred and type `~/Pictures`.
2. Press the right arrow key (`→`), or whatever key you have configured to invoke Alfred’s list of file actions.
3. Choose the file action _Pick random files._
4. Choose one or more file types and specify the quantities.
5. Choose a destination folder.
6. Hit _Submit and copy random files._


## Acknowledgements

Random File Picker depends on (and could not been have made without):

- [alfred2-ruby-framework](https://github.com/canadaduane/alfred2-ruby-framework) by Zhao Cai, and

- of course, [Alfred](https://www.alfredapp.com/) by Andrew and Vero Pepperrell of Running&nbsp;with&nbsp;Crayons Ltd.


# Legal notice

Random File Picker is in no way affiliated with, nor has it any connection to, nor is it endorsed by, Andrew and Vero Pepperrell or their company Running with Crayons Ltd., or Zhao Cai.


# License

Copyright (c) 2018 Claudia <clau@tiqua.de>

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
