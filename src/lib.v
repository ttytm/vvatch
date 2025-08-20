module vvatch

import os

pub enum Action {
	create = C.DMON_ACTION_CREATE
	delete = C.DMON_ACTION_DELETE
	modify = C.DMON_ACTION_MODIFY
	move   = C.DMON_ACTION_MOVE
}

pub enum WatchFlag {
	recursive       = C.DMON_WATCHFLAGS_RECURSIVE
	follow_symlinks = C.DMON_WATCHFLAGS_FOLLOW_SYMLINKS
}

pub type WatchFlags = WatchFlag | u32

pub type WatchID = u32

fn init() {
	C.dmon_init()
}

// watch starts to monitor the specified directory.
// It receives the directory path, a callback that is executed on directory actions,
// watch flags and a voidptr for additional user arguments.
pub fn watch(path string, cb fn (watch_id WatchID, action Action, root_dir string, file_path string, old_file_path string, args voidptr), flags WatchFlags, user_args voidptr) !WatchID {
	if !os.is_dir(path) {
		return error('${@MOD}.${@FN}: `${path}` is not a directory')
	}
	c_cb := fn [cb] (watch_id WatchID, action Action, root_dir &char, file_path &char, old_file_path &char, args voidptr) {
		unsafe {
			rd := if isnil(root_dir) { '' } else { cstring_to_vstring(root_dir) }
			fp := if isnil(file_path) { '' } else { cstring_to_vstring(file_path) }
			op := if isnil(old_file_path) { '' } else { cstring_to_vstring(old_file_path) }
			dbg('watch_cb', '
	watcher: #${watch_id}
	action: ${action}
	root_dir: `${rd}`
	file_path: `${fp}`
	old_file_path: `${op}`
				')
			cb(watch_id, action, rd, fp, op, args)
		}
	}
	id := C.dmon_watch(&char(path.str), c_cb, match flags {
		WatchFlag { u32(flags) }
		u32 { flags }
	}, user_args).id
	if id == 0 {
		return error('${@MOD}.${@FN}: failed to watch `${path}`')
	}
	dbg(@FN, 'starting watcher #${id} at `${path}`')
	return id
}

// unwatch stops to monitor a directory.
pub fn (id WatchID) unwatch() {
	dbg(@FN, 'stopping watcher #${id}')
	C.dmon_unwatch(C.dmon_watch_id{u32(id)})
}

// clean frees allocated resources and should be called when all watching is finished.
pub fn clean() {
	C.dmon_deinit()
}

@[if debug]
fn dbg(func string, msg string) {
	println('vvatch.${func}${if msg == '' { '' } else { ': ' + msg }}')
}
