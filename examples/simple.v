import ttytm.vvatch as w
import time
import os

struct App {
mut:
	triggered bool
}

fn watch_cb(watch_id w.WatchID, action w.Action, root_path string, file_path string, old_file_path string, mut app App) {
	match action {
		.create { println('created `${file_path}`') }
		.delete { println('deleted `${file_path}`') }
		.modify { println('modified `${file_path}`') }
		.move { println('moved `${old_file_path}` to `${file_path}`') }
	}
	app.triggered = true
}

fn main() {
	mut app := App{}

	path := os.join_path(os.home_dir(), 'Downloads')
	watcher := w.watch(path, watch_cb, w.WatchFlag.recursive, app)!

	println('Watching `${path}`. Waiting for an event...')

	// Wait until an external event is triggered for the watched directory.
	for {
		if app.triggered {
			break
		}
		// Slow down loop interval to reduce load.
		time.sleep(100 * time.millisecond)
	}

	watcher.unwatch()
	w.clean()
}
