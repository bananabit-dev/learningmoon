use dioxus::prelude::*;
use crate::components::login::Login as login_component;
use crate::components::logo::Logo;

#[component]
pub fn Login() -> Element {
    rsx! {
        Logo { },
        login_component { }
    }
}