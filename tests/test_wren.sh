#!/bin/bash

on_exit() { [ -n "$wren_script" ] && rm -f $wren_script; }
trap on_exit EXIT
wren_script=$(mktemp 'mle.test_wren.XXXXXXXXXX')
extra_opts="-x $wren_script -K kmap_wren,,1 -k cmd_wren_test,F11, -n kmap_wren"

# mle.mark_insert_before
macro='F11'
cat >$wren_script <<"EOD"
mle.editor_register_cmd("cmd_wren_test", Fn.new {|ctx|
    mle.mark_insert_before(ctx["mark"], "hello from wren\n", 16)
})
EOD
declare -A expected
expected[simple_data]='^hello from wren$'
source 'test.sh'

# mle.editor_open_bview
macro='F11'
cat >$wren_script <<"EOD"
mle.editor_register_cmd("cmd_wren_test", Fn.new {|ctx|
    System.print("hi1")
    mle.editor_open_bview(ctx["editor"], null, 0, null, 0, 1, 0, 0, null)
    System.print("hi2")
})
EOD
declare -A expected
expected[open_data1      ]='^hi1$'
expected[open_data2      ]='^hi2$'
expected[open_bview_count]='^bview_count=2$'
source 'test.sh'

# mle.editor_prompt
macro='F11 t e s t enter . . . F11 C-c'
cat >$wren_script <<"EOD"
mle.editor_register_cmd("cmd_wren_test", Fn.new {|ctx|
    var rv = mle.editor_prompt(ctx["editor"], "input?")
    var str = ""
    if (rv[1]) {
        str = "hello %(rv[1]) from wren"
    } else {
        str = "you hit ctrl-c"
    }
    mle.mark_insert_before(ctx["mark"], str, str.bytes.count)
})
EOD
declare -A expected
expected[prompt_data]='^hello test from wren...you hit ctrl-c$'
source 'test.sh'

# mle.editor_register_observer
macro='F11'
cat >$wren_script <<"EOD"
mle.editor_register_cmd("cmd_wren_test", Fn.new {|ctx|
    System.write("ell")
})
mle.editor_register_observer("cmd_wren_test", 1, Fn.new {|ctx|
    System.write("h")
})
mle.editor_register_observer("cmd_wren_test", 0, Fn.new {|ctx|
    System.write("o")
})
EOD
declare -A expected
expected[prompt_data]='^hello$'
source 'test.sh'
