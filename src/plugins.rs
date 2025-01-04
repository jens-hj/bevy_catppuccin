use bevy::prelude::*;

use crate::CatppuccinTheme;

pub struct CatppuccinPlugin;

impl Plugin for CatppuccinPlugin {
    fn build(&self, app: &mut App) {
        app.init_resource::<CatppuccinTheme>();
    }
}
