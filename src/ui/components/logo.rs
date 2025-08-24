use dioxus::prelude::*;

const _HEADER_SVG: Asset = asset!("/assets/header.svg");

#[component]
pub fn Logo() -> Element {
    rsx! {
            img { src: _HEADER_SVG, id: "header" }
    }
}
