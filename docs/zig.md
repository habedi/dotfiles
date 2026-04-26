# Zig 0.16.0 Cheatsheet

Quick reference for **Zig 0.16.0**: a small, explicit systems language. The 0.16 release introduces I/O as an Interface (`std.Io`) and rewires `main` to take a `std.process.Init`. No hidden control flow, no hidden allocations, no preprocessor; `comptime` replaces macros and generics; errors are values; allocators are explicit and passed in.

Each section has a core idiom; expand the **More examples** blocks for extended snippets.

## Hello World and Toolchain

Compile a single file, scaffold a project, run tests: the three things you do constantly.

```zig title="hello.zig"
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    try std.Io.File.stdout().writeStreamingAll(init.io, "Hello, world!\n");
    std.debug.print("formatted: {d}\n", .{42}); // debug.print still works (stderr)
}
```

??? example "More examples"

    | Command | Effect |
    | --- | --- |
    | `zig run hello.zig` | Build and run in one step. |
    | `zig build-exe hello.zig -O ReleaseFast` | Optimized native binary. |
    | `zig build-exe hello.zig -target x86_64-linux-musl` | Cross-compile to musl Linux. |
    | `zig init` | Scaffold `build.zig` + `src/main.zig`. |
    | `zig build run` | Build and run via `build.zig`. |
    | `zig test file.zig` | Run all `test "..." {}` blocks. |
    | `zig fmt src/` | Auto-format sources. |
    | `zig env` | Show toolchain paths and target info. |

    ```zig title="formatted output"
    // 0.16: I/O is an interface; pass an Io and a buffer to get a Writer.
    var buf: [256]u8 = undefined;
    var w = std.Io.File.stdout().writer(init.io, &buf);
    try w.interface.print("value={d}\n", .{42});
    try w.interface.flush();

    // Quick stderr debug print (no buffer or Io needed):
    std.debug.print("err: {s}\n", .{msg});
    ```

## Variables, Constants, and Literals

`const` by default; `var` only when you need to mutate. Numeric literals are untyped until used.

```zig
const pi: f64 = 3.14159;        // immutable, typed
var count: u32 = 0;             // mutable
count += 1;

const inferred = 42;            // comptime_int, coerces to any int
const hex = 0xFF; const bin = 0b1010; const oct = 0o17;
const million = 1_000_000;       // underscores allowed
```

??? example "More examples"

    ```zig title="strings & chars"
    const name: []const u8 = "Zig";     // string = []const u8 (slice of bytes)
    const raw  = \\multi-line
    \\raw string
    ;
    const nl: u8 = '\n';
    const emoji = "\u{1F600}";          // UTF-8 sequence
    const joined = "hello " ++ "world";  // compile-time concat
    const repeated = "-" ** 10;          // "----------"
    ```

    ```zig title="block expressions"
    const result = blk: {
        var x: u32 = 0;
        for (0..10) |i| x += @as(u32, @intCast(i));
        break :blk x;       // labeled break yields value
    };
    ```

## Primitive Types

Arbitrary-width integers, explicit numeric conversions, and a few special types you’ll meet early.

| Family | Examples | Notes |
| --- | --- | --- |
| Signed int | `i8 i16 i32 i64 i128 isize` | Plus arbitrary `iN` up to `i65535`. |
| Unsigned int | `u8 u16 u32 u64 u128 usize` | `usize` is pointer-sized. |
| Float | `f16 f32 f64 f80 f128` | IEEE-754. |
| Bool, Unit | `bool`, `void`, `noreturn` | `noreturn` for fns that never return. |
| Meta | `type`, `anytype`, `anyopaque` | Used in generics and FFI. |
| String | `[]const u8`, `[*:0]const u8` | Slices and null-terminated for C. |

??? example "More examples"

    ```zig title="explicit conversions"
    const a: i32 = 100;
    const b: i64 = a;                       // widening: implicit
    const c: i16 = @intCast(a);             // narrowing: explicit, panic on overflow
    const d: u32 = @bitCast(@as(i32, -1));   // reinterpret bits
    const e: f32 = @floatFromInt(a);
    const f: i32 = @intFromFloat(3.7);       // truncates toward zero
    const g: u8  = @truncate(0x1FF);          // keeps low 8 bits
    ```

    ```zig title="arbitrary-width ints & overflow"
    const tiny: u3 = 5;          // 3-bit unsigned, 0..=7
    const sum = 200 +% @as(u8, 100);   // +%  wrapping add
    const sat = 200 +| @as(u8, 100);   // +|  saturating add
    ```

## Control Flow

Everything is an expression: `if`, `switch`, blocks, even loops yield values.

```zig
if (x > 0) print("pos") else if (x == 0) print("zero") else print("neg");

var i: u32 = 0;
while (i < 10) : (i += 1) print("{d}\n", .{i});

for (items, 0..) |item, idx| print("{d}: {}\n", .{ idx, item });

const label = switch (color) {
    .red, .pink => "warm",
    .blue, .cyan => "cool",
    else => "other",
};
```

??? example "More examples"

    ```zig title="labeled loops"
    outer: for (rows) |row| {
        for (row) |cell| {
            if (cell == target) break :outer;
        }
    }
    ```

    ```zig title="while with else"
    // `else` runs when the condition turns false (no break)
    var n: u32 = 0;
    const idx = while (n < haystack.len) : (n += 1) {
        if (haystack[n] == needle) break n;
    } else haystack.len;
    ```

    ```zig title="switch with ranges & payload"
    switch (token) {
        .number => |v| print("num {d}\n", .{v}),
        .ident  => |s| print("id  {s}\n", .{s}),
        .symbol => |c| switch (c) {
            '+', '-' => print("add/sub\n", .{}),
            'a'...'z' => print("lower\n", .{}),
            else => {},
        },
    }
    ```

## Optionals

No null pointers in Zig. `?T` is the only way to express “maybe absent”, and the compiler forces you to handle
                it.

```zig
var maybe: ?u32 = null;
maybe = 7;

if (maybe) |val| print("got {}\n", .{val})
else          print("none\n", .{});

const x = maybe orelse 0;     // default
const y = maybe.?;             // unwrap, panic on null
```

??? example "More examples"

    ```zig title="optional pointers (zero overhead)"
    // ?*T fits in one machine word; null is the all-zeros pattern
    var head: ?*Node = null;

    while (head) |node| : (head = node.next) {
        print("{}\n", .{node.value});
    }
    ```

    ```zig title="chaining"
    fn parentName(u: ?*User) ?[]const u8 {
        const user = u orelse return null;
        const parent = user.parent orelse return null;
        return parent.name;
    }
    ```

## Errors

Errors are values from an `error` set. `!` in a return type means “may also return one of these
                errors”.

```zig
const ParseError = error{ Empty, Invalid };

fn parse(s: []const u8) ParseError!u32 {
    if (s.len == 0) return error.Empty;
    return std.fmt.parseInt(u32, s, 10) catch return error.Invalid;
}

const n = try parse("42");          // propagate
const m = parse("x") catch 0;       // default
parse("x") catch |err| log(err);   // inspect
```

??? example "More examples"

    ```zig title="merging error sets"
    const NetError = error{ Timeout, Refused };
    const AnyError = ParseError || NetError;

    fn fetchAndParse() AnyError!u32 { ... }
    ```

    ```zig title="error switch"
    const v = parse(input) catch |err| switch (err) {
        error.Empty   => 0,
        error.Invalid => @panic("bad input"),
    };
    ```

    ```zig title="error trace (debug builds)"
    // `try` and `return error.X` automatically populate a stack trace
    // the runtime prints on panic. No setup needed.
    ```

## Functions

Plain, generic, or duck-typed via `anytype`. The first parameter convention for methods is `self`.

```zig
fn add(a: i32, b: i32) i32 { return a + b; }

pub fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

fn log(comptime fmt: []const u8, args: anytype) void {
    std.debug.print(fmt, args);
}
```

??? example "More examples"

    ```zig title="function pointers & callbacks"
    const Handler = *const fn (req: *Request) void;

    fn register(path: []const u8, h: Handler) void { ... }

    register("/health", &health);
    fn health(req: *Request) void { req.write("ok"); }
    ```

    ```zig title="inline & pure-comptime"
    inline fn hot(x: u32) u32 { return x *% 0x9E3779B1; }

    // `comptime` parameter: value must be known at compile time
    fn bufferOf(comptime n: usize) [n]u8 { return std.mem.zeroes([n]u8); }
    ```

## Arrays, Slices, and Pointers

Arrays have a known length in the type; slices are pointer + length; pointers come in single-item, many-item, and slice
                flavors.

```zig
const arr = [_]i32{ 1, 2, 3, 4 };       // type [4]i32
const slice: []const i32 = arr[1..3];   // {2, 3}
const len   = slice.len;                // runtime length

var x: i32 = 10;
const p: *i32 = &x;                       // single-item pointer
p.* = 20;
```

??? example "More examples"

    ```zig title="pointer flavors"
    // *T            single item, supports .* deref
    // [*]T          many items, unknown length; supports ptr[i]
    // [*:0]T        many items, sentinel-terminated (e.g., C strings)
    // []T           slice = pointer + length, most common
    const cstr: [*:0]const u8 = "hi";
    const as_slice = std.mem.span(cstr);   // []const u8
    ```

    ```zig title="array tricks"
    const zeros = [_]u8{0} ** 16;     // repeat literal: [16]u8 of zeros
    const table = [_]u32{ 1, 2, 4, 8, 16 };
    @compileLog(table.len);             // 5

    var buf: [256]u8 = undefined;
    const n = try std.fmt.bufPrint(&buf, "x={d}", .{42});
    // `n` is a slice of `buf` containing the formatted bytes
    ```

## Structs and Methods

Structs are types. Methods are just functions with a `self` parameter declared inside the struct.

```zig
const Vec2 = struct {
    x: f32,
    y: f32,

    pub fn init(x: f32, y: f32) Vec2 {
        return .{ .x = x, .y = y };
    }

    pub fn length(self: Vec2) f32 {
        return @sqrt(self.x * self.x + self.y * self.y);
    }
};

const v = Vec2.init(3, 4);
const n = v.length();         // 5
```

??? example "More examples"

    ```zig title="default fields, packed, extern"
    const Config = struct {
        retries: u32 = 3,           // default
        verbose: bool = false,
    };

    // packed: bit-precise layout, useful for protocols
    const Header = packed struct {
        flag: u1,
        kind: u3,
        len:  u12,
    };

    // extern: C ABI for interop with C structs
    const CTimespec = extern struct { sec: i64, nsec: i64 };
    ```

    ```zig title="anonymous struct literals"
    // type can be inferred from the destination
    fn draw(p: struct { x: i32, y: i32 }) void { ... }
    draw(.{ .x = 1, .y = 2 });
    ```

## Enums and Tagged Unions

Enums are integers with names. `union(enum)` is a discriminated union: the foundation for sum types and ASTs.

```zig
const Color = enum { red, green, blue };
const c: Color = .red;     // `.` infers enum type from context

const Shape = union(enum) {
    circle: f32,
    rect: struct { w: f32, h: f32 },
    point,
};

switch (s) {
    .circle => |r| ...,
    .rect   => |r| ...,
    .point  => ...,
}
```

??? example "More examples"

    ```zig title="enum with explicit values & methods"
    const Status = enum(u8) {
        ok = 0,
        not_found = 1,
        server_err = 2,

        pub fn isError(self: Status) bool {
            return self != .ok;
        }
    };
    const code = @intFromEnum(Status.not_found);   // 1
    const back: Status = @enumFromInt(code);
    ```

    ```zig title="non-exhaustive enum (e.g., FFI codes)"
    const SysCall = enum(u32) {
        read = 0,
        write = 1,
        _,                         // allows other values
    };
    ```

## Allocators

Memory is explicit: every allocation takes an `Allocator`. Pick the right one for the job and pair every `alloc`
                with a `free` (or use an arena).

```zig
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    // Either use the pre-set-up gpa from init...
    const alloc = init.gpa;

    // ...or build your own DebugAllocator (the GPA successor).
    var dbg = std.heap.DebugAllocator(.{}){};
    defer _ = dbg.deinit();          // reports leaks
    _ = dbg.allocator();

    const buf = try alloc.alloc(u8, 1024);
    defer alloc.free(buf);

    // ArrayList is now unmanaged: init with .empty, pass allocator each call.
    var list: std.ArrayList(u32) = .empty;
    defer list.deinit(alloc);
    try list.append(alloc, 42);
}
```

??? example "More examples"

    | Allocator | Use when… |
    | --- | --- |
    | `DebugAllocator` | App-wide, long-lived; debug mode catches leaks and double-frees. (Was `GeneralPurposeAllocator` in 0.15; alias still works.) |
    | `ArenaAllocator` | Many short-lived allocations; free everything in one shot. |
    | `FixedBufferAllocator` | You have a stack or static buffer and want zero heap. |
    | `page_allocator` | Small, infrequent, large allocations. |
    | `c_allocator` | Mixing with C code that expects malloc/free. |
    | `std.testing.allocator` | Inside `test` blocks; fails the test on leak. |

    ```zig title="arena pattern"
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();           // frees everything
    const a = arena.allocator();

    for (0..1000) |_| {
        _ = try a.alloc(u8, 64);    // no individual frees needed
    }
    ```

    ```zig title="fixed buffer (no heap)"
    var stack_buf: [4096]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&stack_buf);
    const a = fba.allocator();
    const mem = try a.alloc(u8, 512);
    defer a.free(mem);
    ```

## Comptime and Generics

Run regular Zig at compile time. Types are values, so generics are just functions returning types.

```zig
fn List(comptime T: type) type {
    return struct {
        items: []T,
        len: usize,
    };
}

const IntList = List(i32);

comptime {
    const n = 10 * 10;
    @compileLog("computed at compile time", n);
}
```

??? example "More examples"

    ```zig title="comptime branch & @typeInfo"
    fn describe(comptime T: type) []const u8 {
        return switch (@typeInfo(T)) {
            .int   => "integer",
            .float => "float",
            .pointer => "pointer",
            .@"struct" => "struct",
            else => "other",
        };
    }
    ```

    ```zig title="compile-time table generation"
    const sin_table: [256]f32 = blk: {
        @setEvalBranchQuota(10000);
        var t: [256]f32 = undefined;
        for (&t, 0..) |*v, i| {
            v.* = @sin(@as(f32, @floatFromInt(i)) * std.math.pi / 128);
        }
        break :blk t;
    };
    ```

## Defer and Errdefer

Cleanup that runs on every exit (`defer`) or only on the error path (`errdefer`). Indispensable with
                allocators and resources.

```zig
fn work(alloc: std.mem.Allocator) ![]u8 {
    const buf = try alloc.alloc(u8, 64);
    errdefer alloc.free(buf);   // only on error

    try doSomething(buf);       // if this fails, buf is freed
    return buf;                 // success: caller owns it
}

defer file.close();           // runs on scope exit, always
```

??? example "More examples"

    ```zig title="LIFO order"
    defer print("1\n", .{});
    defer print("2\n", .{});
    defer print("3\n", .{});
    // prints: 3 2 1
    ```

    ```zig title="errdefer captures the error"
    errdefer |err| std.log.warn("setup failed: {s}", .{@errorName(err)});
    ```

## Builtins and Casts

Built-in functions start with `@`. They cover reflection, casting, intrinsics, and module loading.

| Group | Builtins |
| --- | --- |
| Modules | `@import`, `@cImport`, `@cInclude`, `@embedFile` |
| Casts | `@as`, `@intCast`, `@floatCast`, `@ptrCast`, `@bitCast`, `@truncate` |
| Conversions | `@intFromFloat`, `@floatFromInt`, `@intFromEnum`, `@enumFromInt`, `@intFromBool` |
| Reflection | `@sizeOf`, `@alignOf`, `@typeInfo`, `@TypeOf`, `@typeName`, `@hasDecl`,                         `@hasField` |
| Math and SIMD | `@min`, `@max`, `@abs`, `@sqrt`, `@mod`, `@rem`, `@splat`,                         `@reduce`, `@shuffle` |
| Memory | `@memcpy`, `@memset`, `@addrOf` |
| Diagnostics | `@panic`, `@compileError`, `@compileLog`, `@errorName` |

## Build System (build.zig)

A real Zig program defines its build graph in `build.zig`. Cross-compilation, optimization modes, and steps are
                first-class.

```zig title="build.zig"
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "app",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    if (b.args) |args| run.addArgs(args);
    const step = b.step("run", "Run the app");
    step.dependOn(&run.step);
}
```

??? example "More examples"

    ```zig title="adding tests & modules"
    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_tests = b.addRunArtifact(tests);
    b.step("test", "Run unit tests").dependOn(&run_tests.step);

    // Add a dependency declared in build.zig.zon
    const dep = b.dependency("zap", .{ .target = target, .optimize = optimize });
    exe.root_module.addImport("zap", dep.module("zap"));  // root_module is now built via b.createModule
    ```

    | Optimize mode | Behavior |
    | --- | --- |
    | `Debug` | Runtime safety on, no optimization. Default. |
    | `ReleaseSafe` | Optimized, runtime safety still on. |
    | `ReleaseFast` | Optimized, safety off. Smallest, fastest, riskiest. |
    | `ReleaseSmall` | Size-optimized, safety off. |

## Testing

Tests are first-class: write `test "name" { ... }` next to the code, run with `zig test` or `zig
                build test`.

```zig
const std = @import("std");
const testing = std.testing;

test "basic add" {
    try testing.expectEqual(4, 2 + 2);
}

test "slice equal" {
    try testing.expectEqualSlices(u8, "hi", "hi");
}
```

??? example "More examples"

    ```zig title="testing allocator catches leaks"
    test "no leaks" {
        const alloc = testing.allocator;
        const buf = try alloc.alloc(u8, 8);
        defer alloc.free(buf);                 // forget this and the test fails
        try testing.expect(buf.len == 8);
    }
    ```

    ```zig title="expectError & skip"
    test "errors" {
        try testing.expectError(error.Empty, parse(""));
    }

    test "slow integration" {
        if (builtin.zig_backend != .stage2_x86_64) return error.SkipZigTest;
        // `return error.SkipZigTest` is the canonical way to skip; gate on whatever you like.
        // ...
    }
    ```

## Threads and Atomics

Async/await was removed in 0.11; the current concurrency story is OS threads, mutexes, channels (in user libs), and
                atomics.

```zig
const std = @import("std");

fn worker(id: u32) void {
    std.debug.print("worker {}\n", .{id});
}

pub fn main() !void {
    const t = try std.Thread.spawn(.{}, worker, .{1});
    t.join();
}
```

??? example "More examples"

    ```zig title="mutex + condition"
    var m: std.Thread.Mutex = .{};
    var count: u32 = 0;

    fn inc() void {
        m.lock();
        defer m.unlock();
        count += 1;
    }
    ```

    ```zig title="atomics"
    var running = std.atomic.Value(bool).init(true);

    fn stop() void { running.store(false, .release); }
    fn isRunning() bool { return running.load(.acquire); }
    ```

## C Interop

First-class. Translate headers with `@cImport`, link C with `-lc`, declare `extern fn`
                for plain symbols.

```zig
const c = @cImport({
    @cInclude("stdio.h");
});

pub fn main() void {
    _ = c.printf("hello from C\n");
}
```

??? example "More examples"

    ```zig title="extern fn & passing strings"
    extern fn getenv(name: [*:0]const u8) ?[*:0]const u8;

    pub fn main() void {
        const path = getenv("PATH") orelse return;
        std.debug.print("{s}\n", .{std.mem.span(path)});
    }
    ```

    ```zig title="exporting Zig to C"
    export fn add(a: c_int, b: c_int) c_int { return a + b; }
    // Build with: zig build-lib src/lib.zig -dynamic
    ```

## Std Library Tour

The standard library is large but discoverable; here are the modules you’ll touch most.

| Module | What it has |
| --- | --- |
| `std.fmt` | `format`, `parseInt`, `parseFloat`, `bufPrint`, `allocPrint`. |
| `std.mem` | Slice ops: `eql`, `indexOf`, `split`, `tokenize`, `copy`,                         `swap`. |
| `std.fs` | `cwd()`, `openFileAbsolute`, `Dir.iterate`, `File.reader/writer`. |
| `std.io` | Generic readers and writers, buffered I/O, fixed-buffer streams. |
| `std.ArrayList(T)` | Growable array, takes an allocator. |
| `std.AutoHashMap(K,V)`, `StringHashMap` | Hash maps with sensible defaults. |
| `std.json` | Parse + stringify, with reflection-driven (de)serialize. |
| `std.http` | HTTP client and basic server. |
| `std.crypto` | Hashes, MACs, ciphers, KDFs, X25519, Ed25519. |
| `std.process` | Args, env, child processes, exit codes. |
| `std.os` | POSIX and syscall layer (per-target). |
| `std.time` | Monotonic and wall clocks, sleep, timers. |
| `std.log` | Leveled logging configurable per scope. |
| `std.testing` | Assertions and the leak-checking allocator. |

??? example "Idiomatic snippets"

    ```zig title="read entire file"
    const data = try std.fs.cwd().readFileAlloc(alloc, "input.txt", 10 * 1024 * 1024);
    defer alloc.free(data);
    ```

    ```zig title="JSON parse with reflection"
    const User = struct { name: []u8, age: u32 };
    const parsed = try std.json.parseFromSlice(User, alloc, json_text, .{});
    defer parsed.deinit();
    print("{s} is {d}\n", .{ parsed.value.name, parsed.value.age });
    ```

    ```zig title="HashMap with arena"
    var map = std.StringHashMap(u32).init(alloc);
    defer map.deinit();
    try map.put("a", 1);
    if (map.get("a")) |v| print("{d}\n", .{v});
    ```

## Common Gotchas

- **unused** Unused variables, imports, and parameters are _compile errors_. Discard with `_                     =`.
- **slices** A slice borrows; storing one outliving its backing storage is undefined behavior.
- **undefined** `= undefined` means uninitialized memory; reading before writing is UB in release                     builds.
- **comptime** Functions that take `comptime T: type` must be called with a comptime-known type.                     Usually fine, but watch for hot loops.
- **stdin** `std.io.getStdIn().reader().readUntilDelimiter…` requires a buffer you own; nothing is                     allocated implicitly.
- **error** Don’t silently `catch unreachable` for errors that _can_ happen; use `catch                     |e|` with a real branch.
