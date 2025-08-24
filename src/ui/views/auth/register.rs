use dioxus::prelude::*;
use crate::ui::components::register::Register as register_component;
use crate::ui::components::logo::Logo;

#[component]
pub fn Register() -> Element {
    rsx! {
        Logo { },
        register_component { }
    }
}