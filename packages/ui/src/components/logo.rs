use dioxus::prelude::*;


const HEADER_SVG: Asset = asset!("/assets/header.svg");



#[component]
pub fn Logo() -> Element {
    rsx! {
            img { src: HEADER_SVG, id: "header" }
    }
}
