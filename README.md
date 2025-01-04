# Bevy Catppuccin

A soothing pastel plugin for Bevy.

## Bevy Compatibility

| Bevy | Bevy Catppuccin |
| ---- | --------------- |
| 0.15 | 0.1             |

## Usage

Add the plugin to your Bevy app:

```rust
use bevy_catppuccin::CatppuccinPlugin;

fn main() {
    App::new().add(CatppuccinPlugin).run();
}
```

This adds a `CatppuccinTheme` resource to your app, which you can use to get catppuccin colors in your systems.

```rust
use bevy_catppuccin::CatppuccinTheme;

// Accessing the theme via the resource
fn system(commands: Commands, theme: Res<CatppuccinTheme>) {
    println!("The lavender color is {:?}", theme.flavor.lavender);

    // Spawn a camera with the clear color set to the base color
    commands.spawn(
        Camera2d,
        Camera {
            clear_color: ClearColorConfig::Custom(theme.flavor.base),
            ..default()
        }
    );

    // Spawn a sprite with the lavender color.
    // Note that if you wanna tint a sprite,
    // your base sprite should be white, in
    // order to get the expected color
    commands.spawn(
        Sprite {
            color: theme.flavor.lavender,
            ..default()
        },
    );
}
```

Or change the theme:

```rust
use bevy_catppuccin::{CatppuccinTheme, Flavor};

fn setup(mut theme: ResMut<CatppuccinTheme>) {
    theme.flavor = Flavor::LATTE;
}
```

The default theme is `Flavor::MOCHA`.

## License

Dual licensed under MIT or Apache 2.0.

- [LICENSE-MIT](http://opensource.org/licenses/MIT)
- [LICENSE-APACHE](http://www.apache.org/licenses/LICENSE-2.0)
