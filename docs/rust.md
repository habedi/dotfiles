# Notes on Rust

Quick reference for Rust stable. Rust is a general-purpose programming language with memory and thread safety enforced at compile time via ownership and borrowing: no GC, no null, no data races. The standard toolchain is `rustup`, `cargo`, `rustc`, `rustfmt`, and `clippy`.

Each section has a core idiom; expand the _More examples_ blocks for extended snippets.

## Hello World and Toolchain

Use Cargo for almost everything. `rustc` is for one-off scripts and learning.

```rust title="src/main.rs"
fn main() {
    println!("Hello, {}!", "world");
}
```

??? example "More examples"

    | Command | Effect |
    | --- | --- |
    | `rustup update stable` | Update toolchain. |
    | `cargo new app`, `cargo new --lib mylib` | Scaffold a binary or library crate. |
    | `cargo run -- arg1 arg2` | Build and run; flags after `--` go to your binary. |
    | `cargo build --release` | Optimized build (target/release). |
    | `cargo check` | Type-check without codegen; fastest feedback loop. |
    | `cargo test`, `cargo test --lib pattern` | Run all or filtered tests. |
    | `cargo clippy --all-targets -- -D warnings` | Lint, treat warnings as errors. |
    | `cargo fmt` | Format the workspace. |
    | `cargo add serde --features derive` | Add a dependency with features. |
    | `cargo doc --open` | Build and open docs for your crate and deps. |
    | `rustc hello.rs && ./hello` | Compile a single file without Cargo. |

## Variables and Constants

Bindings are immutable by default. Shadowing lets you reuse a name with a new type.

```rust
let x = 5;                  // Immutable
let mut y: i32 = 10;        // Mutable
y += 1;
const MAX: u32 = 100;        // Compile-time constant, ALL_CAPS
static NAME: &str = "app";   // 'static lifetime, single location

let (a, b) = (1, 2);
let shadow = "42";
let shadow: i32 = shadow.parse().unwrap();
```

??? example "More examples"

    ```rust title="destructuring patterns"
    let [first, .., last] = arr;             // Fixed-size array
    let Point { x, y: yy } = p;               // Rename
    let &[first, ..] = items else { return; }; // Slice pattern + let-else
    if let Ok(42) = parse("42") { ... }      // Pattern + guard
    ```

    ```rust title="numeric suffixes & literals"
    let a = 42_i64;
    let b = 3.14_f32;
    let c = 0xFF_u8; let d = 0b1010; let e = 0o17;
    let million = 1_000_000;            // Underscores allowed
    ```

## Primitive Types

Strict, but small. The big distinction is owned vs borrowed (`String` vs `&str`, `Vec<T>`
                vs `&[T]`).

| Family | Examples |
| --- | --- |
| Signed int | `i8 i16 i32 i64 i128 isize` |
| Unsigned int | `u8 u16 u32 u64 u128 usize` |
| Float | `f32 f64` |
| Boolean, Char, Unit | `bool`, `char` (4 bytes), `()` |
| String | `&str` borrowed UTF-8 slice, `String` owned and growable |
| Sequence | `(T, U)` tuple, `[T; N]` array, `&[T]` slice, `Vec<T>` heap vec |

??? example "More examples"

    ```rust title="conversion idioms"
    let a: i32 = 100;
    let b = a as i64;                 // Widening, lossy on narrowing
    let c: i64 = a.into();              // Safe widening
    let d = i16::try_from(a).unwrap();  // Fallible narrowing

    let n: i32 = "42".parse()?;
    let s: String = 42.to_string();
    let t: &str = &s;                    // String -> &str via Deref
    ```

## Control Flow

`if`, `match`, `loop`, and blocks are all expressions.

```rust
let sign = if x > 0 { 1 } else if x < 0 { -1 } else { 0 };

loop { break; }
while i < 10 { i += 1; }

for (i, v) in items.iter().enumerate() { ... }
for n in 0..10 { ... }
for n in (0..=10).rev() { ... }
```

??? example "More examples"

    ```rust title="loop returns a value, labels"
    let answer = loop {
        if ready() { break compute(); }
    };

    'outer: for row in &rows {
        for &cell in row {
            if cell == target { break 'outer; }
        }
    }
    ```

    ```rust title="let else"
    fn head(v: &[i32]) -> i32 {
        let [first, ..] = v else { return 0; };
        *first
    }
    ```

## Match and Patterns

Exhaustive by default; the compiler nags you about every missing case.

```rust
match n {
    0 => println!("zero"),
    1 | 2 => println!("one or two"),
    3..=9 => println!("single digit"),
    x if x < 0 => println!("negative"),
    _ => println!("other"),
}

if let Some(v) = maybe { ... }
let Some(v) = maybe else { return; };
while let Some(item) = it.next() { ... }
```

??? example "More examples"

    ```rust title="binding sub-patterns with @"
    match n {
        x @ 1..=9     => println!("single digit {x}"),
        x @ 10..=99   => println!("two digits {x}"),
        _ => {}
    }
    ```

    ```rust title="struct/enum destructuring"
    match shape {
        Shape::Circle { r } if r > 0.0 => ...,
        Shape::Rect { w, h: 0.0 } => ...,
        Shape::Rect { w, h }            => ...,
        Shape::Point                 => ...,
    }
    ```

    ```rust title="matches! macro for booleans"
    if matches!(token, Token::Number(_) | Token::Ident(_)) {
        // ...
    }
    ```

## Ownership and Borrowing

Every value has exactly one owner. Borrows are checked at compile time. Either many `&T` readers or one
                `&mut T` writer, never both.

```rust
let s = String::from("hi");
let t = s;            // Move; s no longer usable

let a = String::from("hi");
let r = &a;            // Shared borrow
println!("{a} {r}");

let mut v = vec![1, 2, 3];
let m = &mut v;       // Exclusive borrow
m.push(4);

let c = a.clone();      // Deep copy when needed
```

??? example "More examples"

    ```rust title="Copy vs Move"
    // Primitives (i32, bool, char, &T, etc) implement Copy: assignment copies.
    // Most struct/enum types do not implement Copy: assignment moves.
    #[derive(Clone, Copy)]
    struct Pixel(u8, u8, u8);

    let p = Pixel(1, 2, 3);
    let q = p;        // P still usable, value was Copy
    ```

    ```rust title="taking &[T] not &Vec<T>"
    // Prefer slice arguments: they accept Vec, [T; N], or any slice
    fn sum(items: &[i32]) -> i32 { items.iter().sum() }

    sum(&vec![1, 2]);
    sum(&[1, 2, 3]);
    ```

    ```rust title="reborrowing"
    fn work(b: &mut Vec<i32>) {
        helper(b);            // Implicit reborrow: b still usable after
        b.push(42);
    }
    ```

## Functions and Closures

Last expression is the return value. Closures are lambdas that capture their environment.

```rust
fn add(a: i32, b: i32) -> i32 {
    a + b   // No semicolon = return
}

let sq = |x: i32| x * x;
let inc = |x| x + 1;
let mut count = 0;
let mut counter = || { count += 1; };  // FnMut
let own = move || data.clone();        // Captures by move
```

??? example "More examples"

    ```rust title="three closure traits"
    // Fn:      reads captures, can be called many times concurrently
    // FnMut:   mutates captures, can be called many times sequentially
    // FnOnce:  consumes captures, can be called only once

    // Generic over closure traits
    fn apply<F: Fn(i32) -> i32>(f: F, x: i32) -> i32 { f(x) }

    // Returning closures: use impl Trait or Box<dyn>
    fn make_adder(n: i32) -> impl Fn(i32) -> i32 {
        move |x| x + n
    }
    ```

## Structs and Enums

Structs hold named or positional fields. Enums are sum types where each variant can carry data.

```rust
struct Point { x: f32, y: f32 }
struct Pair(i32, i32);             // Tuple struct
struct Marker;                    // Unit struct

impl Point {
    fn new(x: f32, y: f32) -> Self { Self { x, y } }
    fn length(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}

enum Shape {
    Circle(f32),
    Rect { w: f32, h: f32 },
    Point,
}
```

??? example "More examples"

    ```rust title="builder pattern via &mut Self"
    struct Config { retries: u32, verbose: bool }

    impl Config {
        fn new() -> Self { Self { retries: 0, verbose: false } }
        fn retries(mut self, n: u32) -> Self { self.retries = n; self }
        fn verbose(mut self) -> Self { self.verbose = true; self }
    }

    let cfg = Config::new().retries(3).verbose();
    ```

    ```rust title="impl blocks per behavior"
    impl Shape {
        fn area(&self) -> f32 {
            match self {
                Shape::Circle(r) => std::f32::consts::PI * r * r,
                Shape::Rect { w, h } => w * h,
                Shape::Point => 0.0,
            }
        }
    }
    ```

## Option and Result

Two enums that replace null and exceptions. The `?` operator propagates errors or absence cleanly.

```rust
fn first(v: &[i32]) -> Option<i32> {
    if v.is_empty() { None } else { Some(v[0]) }
}

fn parse(s: &str) -> Result<i32, std::num::ParseIntError> {
    s.parse::<i32>()
}

let n = parse("42")?;             // Propagate
let n = parse("x").unwrap_or(0);
let n = first(&v).map(|x| x + 1);
```

??? example "More examples"

    | Combinator | What it does |
    | --- | --- |
    | `map / map_err` | Transform the inner value or error. |
    | `and_then` | Chain another fallible operation. |
    | `ok_or / ok_or_else` | `Option` → `Result` with an error. |
    | `ok()` | `Result` → `Option`, discarding the error. |
    | `unwrap_or / unwrap_or_else / unwrap_or_default` | Eager, lazy, or Default::default fallback. |
    | `expect("...")` | Panic with a message; better than `unwrap` in production. |

    ```rust title="? + custom error"
    fn load(path: &str) -> Result<u32, AppError> {
        let body = std::fs::read_to_string(path)?;     // Io::Error -> AppError via From
        let n: u32 = body.trim().parse()?;             // ParseIntError -> AppError
        Ok(n)
    }
    ```

## Traits and Generics

Traits define behavior; generics let you write code over many types. `impl Trait` for static dispatch, `dyn
                Trait` for dynamic.

```rust
trait Greet {
    fn hello(&self) -> String;
    fn shout(&self) -> String { self.hello().to_uppercase() }
}

struct En;
impl Greet for En { fn hello(&self) -> String { "hi".into() } }

fn say<G: Greet>(g: &G)        { println!("{}", g.hello()); }
fn say_dyn(g: &dyn Greet)       { println!("{}", g.hello()); }
fn make() -> impl Greet { En }
```

??? example "More examples"

    ```rust title="bounds & where clauses"
    fn longest<T>(items: &[T]) -> &T
    where
        T: Ord,
    {
        items.iter().max().unwrap()
    }
    ```

    ```rust title="associated types vs generics"
    trait Iterator2 {
        type Item;                            // Associated type
        fn next(&mut self) -> Option<Self::Item>;
    }

    // Vs. generic: caller picks the type instead of the impl
    trait From2<T> { fn from2(t: T) -> Self; }
    ```

    ```rust title="object safety quick rules"
    // Dyn Trait works only if the trait has no generic methods,
    // No Self in return position by value, and no associated consts.
    ```

## Common Derives

Auto-implement standard traits. Reach for these in this order: `Debug`, `Clone`,
                `PartialEq`, `Eq`, `Hash`, `Default`.

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct Id(u64);

#[derive(Default)]
struct Config { retries: u32, verbose: bool }

let c = Config::default();
println!("{c:?}");
println!("{c:#?}");     // Pretty
```

??? example "More examples"

    | Derive | Adds |
    | --- | --- |
    | `Debug` | `{:?}`, `{:#?}` formatting. |
    | `Clone`, `Copy` | Deep clone or bitwise copy. `Copy` requires `Clone`. |
    | `PartialEq`, `Eq` | `==`, total equality (no NaN-like values). |
    | `PartialOrd`, `Ord` | `< >`, total ordering. |
    | `Hash` | Use as a HashMap key or HashSet member. |
    | `Default` | `Type::default()`. |
    | `serde::Serialize`, `Deserialize` | JSON, YAML, etc., via the `serde` crate. |

## Collections

Most code uses `Vec`, `HashMap`, and `HashSet`. `BTreeMap` for ordered keys,
                `VecDeque` for queues.

```rust
use std::collections::{HashMap, HashSet, BTreeMap, VecDeque};

let mut v: Vec<i32> = vec![1, 2, 3];
v.push(4);

let mut m: HashMap<&str, i32> = HashMap::new();
m.insert("a", 1);
*m.entry("a").or_insert(0) += 1;

let s: HashSet<_> = [1, 2, 3].into_iter().collect();
```

??? example "More examples"

    ```rust title="Vec essentials"
    let mut v = Vec::with_capacity(100);
    v.extend([1, 2, 3]);
    v.retain(|&x| x > 0);
    v.sort();
    v.dedup();
    let last = v.pop();          // Option<T>
    let idx  = v.iter().position(|&x| x == 2);
    ```

    ```rust title="HashMap counting"
    let mut counts: HashMap<&str, u32> = HashMap::new();
    for w in words {
        *counts.entry(w).or_insert(0) += 1;
    }
    ```

    ```rust title="ordered map"
    let mut bm: BTreeMap<&str, i32> = BTreeMap::new();
    bm.insert("b", 2); bm.insert("a", 1);
    for (k, v) in &bm { println!("{k}={v}"); }     // Sorted
    ```

## Iterators

Lazy by design. Build a chain of adaptors, then call a consumer (`collect`, `sum`, `for`,
                `find`, …) to drive it.

```rust
let nums = vec![1, 2, 3, 4, 5];

let sum: i32 = nums.iter().sum();
let doubled: Vec<_> = nums.iter().map(|x| x * 2).collect();
let evens: Vec<_> = nums.iter().filter(|x| **x % 2 == 0).collect();

let first_big = nums.iter().find(|x| **x > 3);
let any_neg   = nums.iter().any(|x| *x < 0);
let all_pos   = nums.iter().all(|x| *x > 0);
```

??? example "More examples"

    | Adaptor | Purpose |
    | --- | --- |
    | `map`, `filter` | Transform or keep elements. |
    | `flat_map`, `flatten` | Iterator of iterators → single iterator. |
    | `take(n)`, `skip(n)`, and `step_by(n)` | Slicing. |
    | `enumerate()` | Yields `(i, item)`. |
    | `zip(other)` | Pair up, stops at shorter. |
    | `chain(other)` | Concatenate. |
    | `peekable()` | Look at the next item without consuming. |
    | `chunks(n)` and `windows(n)` (slice) | Group elements. |

    ```rust title="grouping with fold"
    let grouped: HashMap<_, Vec<_>> = nums.iter()
        .fold(HashMap::new(), |mut acc, &x| {
            acc.entry(x % 2).or_default().push(x);
            acc
        });
    ```

    ```rust title="iter() vs into_iter() vs iter_mut()"
    // Iter()       -> &T
    // Method iter_mut()   -> &mut T
    // Method into_iter()  -> T (consumes the collection)
    for x in &v       { /* &T  */ }
    for x in &mut v   { /* &mut T */ }
    for x in v         { /* T (v is moved) */ }
    ```

## Error Handling

Use `Result<T, E>`. For libraries: define your own error enum (often via `thiserror`). For
                applications: `anyhow::Result` is fine.

```rust
use std::io::{self, Read};
use std::fs::File;

fn read_all(path: &str) -> io::Result<String> {
    let mut f = File::open(path)?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}
```

??? example "More examples"

    ```rust title="custom error enum (thiserror)"
    // Cargo.toml: thiserror = "1"
    #[derive(Debug, thiserror::Error)]
    pub enum AppError {
        #[error("io: {0}")]    Io(#[from] std::io::Error),
        #[error("parse: {0}")] Parse(#[from] std::num::ParseIntError),
        #[error("missing config: {key}")]
        Missing { key: String },
    }

    pub type Result<T> = std::result::Result<T, AppError>;
    ```

    ```rust title="anyhow for binaries"
    // Cargo.toml: anyhow = "1"
    use anyhow::{Result, Context};

    fn main() -> Result<()> {
        let body = std::fs::read_to_string("config.toml")
            .context("reading config.toml")?;
        println!("{}", body.len());
        Ok(())
    }
    ```

## Lifetimes

Lifetimes describe how long borrows are valid. Most are elided; you only annotate when the compiler can’t relate input and
                output references.

```rust
fn longest<'a>(a: &'a str, b: &'a str) -> &'a str {
    if a.len() > b.len() { a } else { b }
}

struct View<'a> { data: &'a [u8] }

impl<'a> View<'a> {
    fn new(d: &'a [u8]) -> Self { Self { data: d } }
}
```

??? example "More examples"

    ```rust title="elision rules in 30 seconds"
    // 1. Each input ref gets its own lifetime.
    // 2. If there's exactly one input lifetime, it's assigned to all output refs.
    // 3. If there are multiple inputs but one is &self / &mut self, that one is used.
    // Outside these, you must annotate.
    ```

    ```rust title="'static lives for the whole program"
    const NAME: &'static str = "app";
    fn longest_default() -> &'static str { "<none>" }
    // Boxed/leaked values can also satisfy 'static
    let leaked: &'static str = String::from("hi").leak();
    ```

## Smart Pointers

Special types with owning semantics; pick by need: heap, shared, mutable-through-shared, thread-safe.

| Pointer | Use when |
| --- | --- |
| `Box<T>` | One owner, value lives on the heap. Recursive types. |
| `Rc<T>` | Shared ownership, single-threaded. |
| `Arc<T>` | Shared ownership across threads (atomic refcount). |
| `RefCell<T>`, `Cell<T>` | Interior mutability through `&`, single-threaded. |
| `Mutex<T>`, `RwLock<T>` | Interior mutability across threads. |
| `Cow<'a, T>` | Borrow until you actually need to mutate. |

??? example "More examples"

    ```rust title="Arc<Mutex<T>>: shared mutable across threads"
    use std::sync::{Arc, Mutex};
    use std::thread;

    let data = Arc::new(Mutex::new(vec![]));
    let handles: Vec<_> = (0..4).map(|i| {
        let d = data.clone();
        thread::spawn(move || d.lock().unwrap().push(i))
    }).collect();
    for h in handles { h.join().unwrap(); }
    ```

    ```rust title="Cow for cheap-when-clean APIs"
    use std::borrow::Cow;

    fn normalize(s: &str) -> Cow<'_, str> {
        if s.contains('\t') {
            Cow::Owned(s.replace('\t', "    "))
        } else {
            Cow::Borrowed(s)
        }
    }
    ```

## Concurrency

Threads, channels, and locks. The borrow checker enforces no-data-races at compile time via `Send` and `Sync`.

```rust
use std::thread;
use std::sync::{Arc, Mutex, mpsc};

let data = Arc::new(Mutex::new(0));
let handles: Vec<_> = (0..4).map(|_| {
    let d = data.clone();
    thread::spawn(move || { *d.lock().unwrap() += 1; })
}).collect();
for h in handles { h.join().unwrap(); }

let (tx, rx) = mpsc::channel();
thread::spawn(move || tx.send("hi").unwrap());
println!("{}", rx.recv().unwrap());
```

??? example "More examples"

    ```rust title="scoped threads (no Arc needed)"
    let data = vec![1, 2, 3];
    thread::scope(|s| {
        s.spawn(|| println!("{:?}", &data));
        s.spawn(|| println!("{}", data.len()));
    });
    // Guarantees all spawned threads finish before scope returns
    ```

    ```rust title="parallel iteration with rayon"
    // Cargo.toml: rayon = "1"
    use rayon::prelude::*;

    let sum: i64 = (0..1_000_000_i64).into_par_iter().sum();
    ```

## Async and Await

Async functions return futures; you need a runtime (usually `tokio`) to drive them.

```rust
// Cargo.toml: tokio = { version = "1", features = ["full"] }
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let body = reqwest::get("https://example.com")
        .await?
        .text()
        .await?;
    println!("{}", body.len());
    Ok(())
}
```

??? example "More examples"

    ```rust title="join, select, spawn"
    async fn work() -> u32 { 42 }

    // Run concurrently, wait for all
    let (a, b) = tokio::join!(work(), work());

    // Race: first to finish wins
    tokio::select! {
        v = work() => println!("got {v}"),
        _ = tokio::time::sleep(std::time::Duration::from_secs(1)) => println!("timeout"),
    }

    // Spawn a background task
    let handle = tokio::spawn(async { work().await });
    let v = handle.await?;
    ```

    ```rust title="async traits (stable)"
    trait Loader {
        async fn load(&self, key: &str) -> Result<String, Box<dyn std::error::Error>>;
    }
    ```

## Modules and Crates

A _crate_ is a compilation unit. Inside it, `mod` creates a namespace tree. `pub` controls
                visibility.

```rust
// Src/lib.rs
pub mod math;            // Loads src/math.rs or src/math/mod.rs
pub use math::add;       // Re-export at crate root

// Src/math.rs
pub fn add(a: i32, b: i32) -> i32 { a + b }
pub(crate) fn internal() {}  // Crate-private

// Using
use mycrate::{add, math::*};
```

??? example "More examples"

    ```rust title="Cargo.toml essentials"
    [package]
    name = "app"
    version = "0.1.0"
    edition = "2024"

    [dependencies]
    serde = { version = "1", features = ["derive"] }
    tokio = { version = "1", features = ["full"] }

    [dev-dependencies]
    criterion = "0.5"

    [features]
    default = ["net"]
    net = []

    [profile.release]
    lto = true
    codegen-units = 1
    ```

    ```rust title="workspaces"
    [workspace]
    members = ["app", "libs/*"]
    resolver = "2"
    ```

## Testing

Unit tests live next to the code; integration tests live in `tests/`; doctests run from `///`
                examples.

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn adds() { assert_eq!(2 + 2, 4); }

    #[test]
    #[should_panic(expected = "oops")]
    fn panics() { panic!("oops"); }
}
```

??? example "More examples"

    ```rust title="async tests"
    // Cargo.toml: tokio = { version = "1", features = ["macros", "rt"] }
    #[tokio::test]
    async fn uses_async() {
        let v = work().await;
        assert_eq!(v, 42);
    }
    ```

    ```rust title="doctest"
    /// Adds two numbers.
    ///
    /// ```
    /// assert_eq!(mycrate::add(2, 2), 4);
    /// ```
    pub fn add(a: i32, b: i32) -> i32 { a + b }
    ```

    ```rust title="test only some helpers"
    fn helper() -> i32 { 1 }

    #[cfg(test)]
    fn dev_helper() -> i32 { 2 }   // Only compiled during tests
    ```

## Macros

Macros end with `!`. They’re how Rust handles things that need variadics or syntax extensions.

| Macro | Purpose |
| --- | --- |
| `println!`, `eprintln!`, and `print!` | Write to stdout or stderr. |
| `format!`, `write!` | Build a `String`, or write to a `fmt::Write`. |
| `vec![1, 2, 3]` | Construct a `Vec`. |
| `matches!(x, P)` | Pattern test as a `bool`. |
| `assert!`, `assert_eq!`, and `assert_ne!` | Test assertions. |
| `debug_assert!` | Compiled out in release builds. |
| `todo!()`, `unimplemented!()`, and `unreachable!()` | Placeholders that panic. |
| `dbg!(x)` | Print and pass through, like `console.log(x)`. |
| `include_str!`, `include_bytes!` | Embed file contents at compile time. |
| `env!` | Read an env var at compile time. |

??? example "More examples"

    ```rust title="format directives"
    println!("{:5}", 42);          // Width
    println!("{:0>5}", 42);        // Pad with 0
    println!("{:.3}", 3.14159);     // Precision
    println!("{:#x}", 255);          // 0xff
    println!("{name} = {val:?}", name = "x", val = &v);
    ```

## Unsafe

Five powers, used carefully. Wrap unsafe behind safe APIs and document invariants with `// SAFETY:`.

```rust
unsafe fn dangerous() { ... }

unsafe {
    let p = &x as *const i32;
    println!("{}", *p);
}

extern "C" {
    fn abs(input: i32) -> i32;
}
```

??? example "More examples"

    - Dereference a raw pointer (`*const T`, `*mut T`).
    - Call an `unsafe fn` or `extern` function.
    - Access or modify a mutable static.
    - Implement an `unsafe trait` (e.g. `Send`, `Sync`).
    - Access a field of a `union`.

    ```rust title="FFI: linking to C"
    use std::ffi::{CString, CStr};
    use std::os::raw::c_char;

    extern "C" {
        fn getenv(name: *const c_char) -> *const c_char;
    }

    fn get(key: &str) -> Option<String> {
        let cs = CString::new(key).ok()?;
        let p = unsafe { getenv(cs.as_ptr()) };
        if p.is_null() { return None; }
        Some(unsafe { CStr::from_ptr(p) }.to_string_lossy().into_owned())
    }
    ```

## Std Library Tour

A small map of where things live. The `prelude` brings `Option`, `Result`,
                `String`, `Vec`, common traits etc. into scope automatically.

| Module | What it has |
| --- | --- |
| `std::fs` | Files, directories, metadata. |
| `std::io` | `Read`, `Write`, `BufReader`, `BufWriter`, stdin, and stdout. |
| `std::path` | `Path`, `PathBuf`; OS-agnostic path manipulation. |
| `std::env` | Args, env vars, current dir. |
| `std::process` | Spawn child processes, exit. |
| `std::time` | `Duration`, `Instant`, `SystemTime`. |
| `std::thread`, `std::sync` | Threads, channels, mutexes, atomics. |
| `std::collections` | `HashMap`, `HashSet`, `BTreeMap`, `VecDeque`, `BinaryHeap`. |
| `std::fmt` | `Display`, `Debug`, custom formatters. |
| `std::num`, `std::str` | Parse errors, str ops. |

??? example "Crates worth knowing"

    | Crate | For |
    | --- | --- |
    | `serde` + `serde_json` | Serialization (`#[derive(Serialize, Deserialize)]`). |
    | `tokio` | Async runtime (also `async-std`, `smol`). |
    | `reqwest` | HTTP client (sync + async). |
    | `anyhow`, `thiserror` | App-level or library-level error handling. |
    | `clap` | CLI parsing with derive macros. |
    | `regex` | Regular expressions. |
    | `tracing` | Structured, async-aware logging. |
    | `rayon` | Data-parallel iterators. |
    | `once_cell`, `std::sync::OnceLock` | Lazy statics. |

## Common Gotchas

- _strings_: `String` owns; `&str` borrows. Prefer `&str` in args,                     return `String` when you build new content.
- _cloning_: `.clone()` is allowed but not free. If you’re cloning in a hot loop, reconsider                     lifetimes or `Cow`.
- _unwrap_: Avoid `.unwrap()` in production; at least use `.expect("...")` with a                     message that locates the bug.
- _borrow_: “cannot borrow as mutable because it is also borrowed as immutable” usually means you’re holding                     a `&` across a `&mut` call; split the scope.
- _async_: An `async fn` does nothing until `.await`. Forgetting `.await` is                     silently a no-op (clippy warns).
- _size_: Trait objects (`dyn Trait`) are unsized; store behind `Box`,                     `&`, `Arc`, or `Rc`.
- _orphan_: You can implement a trait for a type only if you own one of them; known as the orphan rule.
