mod views;
mod components;

use dioxus::prelude::*;
use crate::views::auth::login::Login;
use crate::views::auth::register::Register;


#[derive(Debug, Clone, Routable, PartialEq)]
#[rustfmt::skip]
enum Route {
    #[route("/")]
    Home {},
    #[route("/login")]
    Login {},
    #[route("/register")]
    Register {},
}



#[component]
pub fn App() -> Element {
    rsx! {
        document::Link { rel: "icon", href: "/assets/favicon.ico" }
        document::Link { rel: "stylesheet", href: "/assets/main.css" } 
        document::Link { rel: "stylesheet", href: "/assets/tailwind.css" }
        Router::<Route> {}
    }
}

/// Home page
#[component]
fn Home() -> Element {
    rsx! {
        Navbar { }
        p { "Welcome to learningmoon !" }
    }
}

/// Shared navbar component.
#[component]
fn Navbar() -> Element {
    rsx! {
        div {
            id: "navbar",
            Link {
                to: Route::Home {},
                "Home"
            }
            Link {
                to: Route::Login {},
                "Login"
            }
            Link {
                to: Route::Register {},
                "Register"
            }
        }

        Outlet::<Route> {}
    }
}
