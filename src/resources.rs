use bevy::prelude::*;

use crate::Flavor;

#[derive(Resource, Debug, Clone, Copy)]
pub struct CatppuccinTheme {
    pub flavor: Flavor,
}

impl Default for CatppuccinTheme {
    fn default() -> Self {
        Self {
            flavor: Flavor::MOCHA,
        }
    }
}
