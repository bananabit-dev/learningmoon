use dioxus::prelude::*;
use crate::ui::components::login::Login as login_component;
use crate::ui::components::logo::Logo;

#[component]
pub fn Login() -> Element {
    rsx! {
        Logo { },
        login_component { }
    }
}