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

/*const FAVICON: Asset = asset!("/assets/favicon.ico");
const MAIN_CSS: Asset = asset!("/assets/main.css");
const TAILWIND_CSS: Asset = asset!("/assets/tailwind.css");*/

fn main() {
    #[cfg(feature = "web")]
    {
        // Client-side WASM launch
        server_fn::client::set_server_url("https://learningmoon.app");
        LaunchBuilder::web().launch(App);
    }

    #[cfg(feature = "api")]
    {
        use axum::{routing::get_service, Router};
        use dioxus::logger::tracing::*;
        use tower_http::services::ServeDir;

        tokio::runtime::Runtime::new().unwrap().block_on(async {
            let addr = dioxus::cli_config::fullstack_address_or_localhost();
            info!("🚀 Starting web server on http://{}", addr);

            // --- Build Axum Router ---
            let app = Router::new()
                // Serve static assets from public/assets (matches your bundle structure)
                .nest_service("/assets", get_service(ServeDir::new("public/assets")))
                // IMPORTANT: Dioxus needs to handle all routes for SPA
                .serve_dioxus_application(
                    ServeConfig::builder()
                        .build()
                        .expect("Failed to build serve config"),
                    App,
                );

            // --- Start server ---
            if let Err(e) =
                axum::serve(tokio::net::TcpListener::bind(addr).await.unwrap(), app).await
            {
                error!("🔥 Server error: {}", e);
            }
        });
    }
}

#[component]
fn App() -> Element {
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
