use dioxus::prelude::*;
mod ui;
use ui::views::auth::login::Login;
use ui::views::auth::register::Register;

#[derive(Debug, Clone, Routable, PartialEq)]
#[rustfmt::skip]
enum Route {
    #[layout(Navbar)]
    #[route("/")]
    Home {},
    #[route("/login")]
    Login {},
    #[route("/register")]
    Register {},
}

const FAVICON: Asset = asset!("/assets/favicon.ico");
const MAIN_CSS: Asset = asset!("/assets/main.css");
const TAILWIND_CSS: Asset = asset!("/assets/tailwind.css");

fn main() {
    #[cfg(feature = "web")]
    {
        // Client-side WASM launch
        server_fn::client::set_server_url("https://learningmoon.app");
        LaunchBuilder::web().launch(App);
    }

    #[cfg(feature = "api")]
    {
        use axum::Router;
        use dioxus::fullstack::ServeConfig;
        use tower_http::services::ServeDir;
        // Server-side Axum launch
        use axum::routing::get_service;

        let app = Router::new()
            // Serve /assets normally
            .nest_service("/assets", get_service(ServeDir::new("dist/assets")))
            // Fallback for everything else → serve from dist/
            .fallback_service(get_service(ServeDir::new("dist")).handle_error(
                |err: std::io::Error| async move {
                    (
                        axum::http::StatusCode::INTERNAL_SERVER_ERROR,
                        format!("Unhandled internal error: {}", err),
                    )
                },
            ))
            // Dioxus SPA hydration
            .serve_dioxus_application(ServeConfig::builder().build().unwrap(), App);
    }
}

#[component]
fn App() -> Element {
    rsx! {
        document::Link { rel: "icon", href: FAVICON }
        document::Link { rel: "stylesheet", href: MAIN_CSS } document::Link { rel: "stylesheet", href: TAILWIND_CSS }
        Router::<Route> {}
    }
}

/// Home page
#[component]
fn Home() -> Element {
    rsx! {
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
