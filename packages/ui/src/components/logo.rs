use dioxus::prelude::*;

#[component]
pub fn Logo() -> Element {
    rsx! {
            img { src: "/assets/header.svg" , id: "header" }
    }
}
