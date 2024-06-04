module vvatch

#flag -I@VMODROOT/src/dmon -DDMON_IMPL
#flag darwin -framework CoreServices -framework CoreFoundation
#include "@VMODROOT/src/dmon/dmon.h"

@[typedef]
struct C.dmon_watch_id {
	id u32
}

fn C.dmon_init()

fn C.dmon_deinit()

fn C.dmon_watch(rootdir charptr, watch_cb fn (watch_id WatchID, action Action, root_dir &char, file_path &char, old_file_path &char, args voidptr), flags u32, user_data voidptr) C.dmon_watch_id

fn C.dmon_unwatch(id C.dmon_watch_id)
