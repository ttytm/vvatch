# vvatch

vvatch is cross-platform V module to monitor changes in directories. It utilizes the [dmon](https://github.com/septag/dmon?tab=readme-ov-file) C99 library.

> [!NOTE]\
> [vmon](https://github.com/Larpon/vmon) is an already available module.
> It is the first mover in terms of being a dmon wrapper and served as an inspiration.

<blockquote>
<sub>
vvatch is a rewrite that I'm using for a client project that makes opinionated changes. It takes a different approach on the internals to allow a clean working surface. It aims to leverage the C library, increase robustness, and allows to compile programs that use the module in strict mode and with the Clang compiler.
</sub>
</blockquote>

## Installation

```bash
v install ttytm.vvatch
```

## Usage

```v
// watch starts to watch the specified directory.
// It receives the directory path, a callback that is executed on directory actions,
// watch flags and a voidptr for additional user arguments.
pub fn watch(path string, cb fn (watch_id WatchID, action Action, root_dir string, file_path string, old_file_path string, args voidptr), flags WatchFlags, user_args voidptr) !WatchID

// unwatch stops to watch the specified directory path.
pub fn (id WatchID) unwatch()
```

_Ref.:_ [`src/lib.v`](https://github.com/ttytm/vvatch/blob/main/src/lib.v)

## Simple Example

```v
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
		.delete { println('delated `${file_path}`') }
		.modify { println('modified `${file_path}`') }
		.move { println('moved `${old_file_path}` to `${file_path}`') }
	}
	app.triggered = true
}

fn main() {
	mut app := App{}

	watcher := w.watch(os.join_path(os.home_dir(), 'Downloads'), watch_cb, w.WatchFlag.recursive,
		app)!

	// Wait until an external event is triggered in the monitored directory.
	for {
		if app.triggered {
			break
		}
		// Slow down the loop interval to reduce load.
		time.sleep(100 * time.millisecond)
	}

	watcher.unwatch()
	w.clean()
}
```

_Ref.:_ [`examples/simple.v`](https://github.com/ttytm/vvatch/blob/main/examples/simple.v)

```
v run examples/simple.v

# Run with additional debug information
v -g run examples/simple.v
```

## License

Just as with vmon, the V code written for vvatch is licensed under MIT.
The utilized [dmon](https://github.com/septag/dmon) C library is licensed under the BSD 2-clause.
