use dioxus::prelude::*;
/*
const _HEADER_SVG: Asset = asset!(); 
*/


#[component]
pub fn Logo() -> Element {
    rsx! {
            img { src: "/assets/header.svg", id: "header" }
    }
}
