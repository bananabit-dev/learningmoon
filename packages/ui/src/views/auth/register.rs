use dioxus::prelude::*;
use crate::components::register::Register as register_component;
use crate::components::logo::Logo;

#[component]
pub fn Register() -> Element {
    rsx! {
        Logo { },
        register_component { }
    }
}